package handlers

import (
	"database/sql"
	"encoding/json"
	"html/template"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"
	"zamemo-app/db"
	"zamemo-app/models"
)

func NotesPage(w http.ResponseWriter, r *http.Request, templates *template.Template) {
	cookie, err := r.Cookie("user_id")
	if err != nil {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}

	userID, err := strconv.Atoi(cookie.Value)
	if err != nil {
		http.Error(w, "Ошибка авторизации", http.StatusUnauthorized)
		return
	}

	query := r.URL.Query().Get("q")
	notes, err := models.GetNotesByUser(userID, query)
	if err != nil {
		http.Error(w, "Ошибка получения заметок", http.StatusInternalServerError)
		log.Println("Ошибка получения заметок:", err)
		return
	}

	lang := r.URL.Query().Get("lang")
	if lang == "" {
		lang = "ru"
	}

	data := struct {
		Notes []models.Note
		Lang  string
		Query string
	}{
		Notes: notes,
		Lang:  lang,
		Query: query,
	}

	err = templates.ExecuteTemplate(w, "notes.html", data)
	if err != nil {
		http.Error(w, "Ошибка рендеринга шаблона", http.StatusInternalServerError)
		log.Println("Ошибка шаблона:", err)
	}
}

func CreateNoteHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/notes", http.StatusSeeOther)
		return
	}

	cookie, err := r.Cookie("user_id")
	if err != nil {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}

	userID, err := strconv.Atoi(cookie.Value)
	if err != nil {
		http.Error(w, "Ошибка авторизации", http.StatusUnauthorized)
		return
	}

	title := r.FormValue("title")
	content := r.FormValue("content")
	reminder := r.FormValue("reminder")
	categories := r.Form["categories"]

	var reminderAt *time.Time
	if reminder != "" {
		localTime, err := time.ParseInLocation("2006-01-02T15:04", reminder, time.Local)
		if err != nil {
			http.Error(w, "Неверный формат даты напоминания", http.StatusBadRequest)
			return
		}
		utcTime := localTime.UTC()
		reminderAt = &utcTime
	}

	if title == "" {
		http.Error(w, "Заголовок обязателен", http.StatusBadRequest)
		return
	}

	err = models.CreateNote(userID, title, content, reminderAt, categories)
	if err != nil {
		http.Error(w, "Ошибка создания заметки", http.StatusInternalServerError)
		log.Println("Ошибка создания заметки:", err)
		return
	}

	http.Redirect(w, r, "/notes", http.StatusSeeOther)
}

func EditNotePage(w http.ResponseWriter, r *http.Request, templates *template.Template) {
	cookie, err := r.Cookie("user_id")
	if err != nil {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}

	userID, _ := strconv.Atoi(cookie.Value)
	noteID, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil {
		http.Error(w, "Неверный ID заметки", http.StatusBadRequest)
		return
	}

	var note models.Note
	var reminderAt sql.NullTime
	var categories sql.NullString
	err = db.DB.QueryRow(`
		SELECT n.id, n.user_id, n.title, n.content, n.created_at, n.reminder_at, array_agg(c.name) as categories
		FROM notes n
		LEFT JOIN note_categories nc ON n.id = nc.note_id
		LEFT JOIN categories c ON nc.category_id = c.id
		WHERE n.id = $1 AND n.user_id = $2
		GROUP BY n.id`, noteID, userID).
		Scan(&note.ID, &note.UserID, &note.Title, &note.Content, &note.CreatedAt, &reminderAt, &categories)
	if err != nil {
		http.Error(w, "Заметка не найдена или доступ запрещен", http.StatusNotFound)
		return
	}
	note.CreatedAt = note.CreatedAt.In(time.Local)
	if reminderAt.Valid {
		localReminderAt := reminderAt.Time.In(time.Local)
		note.ReminderAt = &localReminderAt
	}
	if categories.Valid && categories.String != "{}" {
		note.Categories = parseCategories(categories.String)
	}

	lang := r.URL.Query().Get("lang")
	if lang == "" {
		lang = "ru"
	}

	data := struct {
		Note models.Note
		Lang string
	}{
		Note: note,
		Lang: lang,
	}

	err = templates.ExecuteTemplate(w, "edit_note.html", data)
	if err != nil {
		http.Error(w, "Ошибка рендеринга шаблона", http.StatusInternalServerError)
		log.Println("Ошибка шаблона:", err)
	}
}

func UpdateNoteHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/notes", http.StatusSeeOther)
		return
	}

	cookie, err := r.Cookie("user_id")
	if err != nil {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}

	userID, _ := strconv.Atoi(cookie.Value)
	noteID, _ := strconv.Atoi(r.FormValue("id"))
	title := r.FormValue("title")
	content := r.FormValue("content")
	reminder := r.FormValue("reminder")
	categories := r.Form["categories"]

	var reminderAt *time.Time
	if reminder != "" {
		localTime, err := time.ParseInLocation("2006-01-02T15:04", reminder, time.Local)
		if err != nil {
			http.Error(w, "Неверный формат даты напоминания", http.StatusBadRequest)
			return
		}
		utcTime := localTime.UTC()
		reminderAt = &utcTime
	}

	err = models.UpdateNote(noteID, userID, title, content, reminderAt, categories)
	if err != nil {
		http.Error(w, "Ошибка обновления заметки", http.StatusInternalServerError)
		log.Println("Ошибка обновления заметки:", err)
		return
	}

	http.Redirect(w, r, "/notes", http.StatusSeeOther)
}

func DeleteNoteHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/notes", http.StatusSeeOther)
		return
	}

	cookie, err := r.Cookie("user_id")
	if err != nil {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}

	userID, _ := strconv.Atoi(cookie.Value)
	noteID, _ := strconv.Atoi(r.FormValue("id"))

	err = models.DeleteNote(noteID, userID)
	if err != nil {
		http.Error(w, "Ошибка удаления заметки", http.StatusInternalServerError)
		log.Println("Ошибка удаления заметки:", err)
		return
	}

	http.Redirect(w, r, "/notes", http.StatusSeeOther)
}

func GetNotesAPI(w http.ResponseWriter, r *http.Request) {
	cookie, err := r.Cookie("user_id")
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	userID, err := strconv.Atoi(cookie.Value)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusUnauthorized)
		return
	}

	notes, err := models.GetNotesByUser(userID, r.URL.Query().Get("q"))
	if err != nil {
		http.Error(w, "Error fetching notes", http.StatusInternalServerError)
		log.Println("Error fetching notes:", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(notes)
}

func CreateNoteAPI(w http.ResponseWriter, r *http.Request) {
	cookie, err := r.Cookie("user_id")
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	userID, err := strconv.Atoi(cookie.Value)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusUnauthorized)
		return
	}

	var note struct {
		Title      string   `json:"title"`
		Content    string   `json:"content"`
		ReminderAt *string  `json:"reminder_at"`
		Categories []string `json:"categories"`
	}
	if err := json.NewDecoder(r.Body).Decode(&note); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		log.Println("Decode error:", err)
		return
	}

	var reminderAt *time.Time
	if note.ReminderAt != nil && *note.ReminderAt != "" {
		localTime, err := time.Parse("2006-01-02T15:04", *note.ReminderAt)
		if err != nil {
			log.Println("Reminder parse error:", err, "Value:", *note.ReminderAt)
			http.Error(w, "Invalid reminder format (use YYYY-MM-DDTHH:MM)", http.StatusBadRequest)
			return
		}
		utcTime := localTime.UTC()
		reminderAt = &utcTime
	}

	if note.Title == "" {
		http.Error(w, "Title is required", http.StatusBadRequest)
		return
	}

	err = models.CreateNote(userID, note.Title, note.Content, reminderAt, note.Categories)
	if err != nil {
		http.Error(w, "Error creating note: "+err.Error(), http.StatusInternalServerError)
		log.Println("Create note error:", err)
		return
	}

	w.WriteHeader(http.StatusCreated)
}

func parseCategories(catString string) []string {
	cleaned := catString[1 : len(catString)-1]
	if cleaned == "" {
		return []string{}
	}
	return strings.Split(cleaned, ",")
}
