package models

import (
	"database/sql"
	"strings"
	"time"
	"zamemo-app/db"
)

type Note struct {
	ID         int        `json:"id"`
	UserID     int        `json:"user_id"`
	Title      string     `json:"title"`
	Content    string     `json:"content"`
	CreatedAt  time.Time  `json:"created_at"`
	ReminderAt *time.Time `json:"reminder_at"`
	Categories []string   `json:"categories"`
}

func CreateNote(userID int, title, content string, reminderAt *time.Time, categories []string) error {
	tx, err := db.DB.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	var noteID int
	err = tx.QueryRow("INSERT INTO notes (user_id, title, content, reminder_at) VALUES ($1, $2, $3, $4) RETURNING id",
		userID, title, content, reminderAt).Scan(&noteID)
	if err != nil {
		return err
	}

	for _, catName := range categories {
		if catName == "" || catName == "NULL" {
			continue
		}
		var catID int
		err = tx.QueryRow("INSERT INTO categories (name, user_id) VALUES ($1, $2) ON CONFLICT (name, user_id) DO UPDATE SET name = EXCLUDED.name RETURNING id",
			catName, userID).Scan(&catID)
		if err != nil {
			return err
		}
		_, err = tx.Exec("INSERT INTO note_categories (note_id, category_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", noteID, catID)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

func GetNotesByUser(userID int, query string) ([]Note, error) {
	var rows *sql.Rows
	var err error
	if query == "" {
		rows, err = db.DB.Query(`
			SELECT n.id, n.user_id, n.title, n.content, n.created_at, n.reminder_at, array_agg(c.name) as categories
			FROM notes n
			LEFT JOIN note_categories nc ON n.id = nc.note_id
			LEFT JOIN categories c ON nc.category_id = c.id
			WHERE n.user_id = $1
			GROUP BY n.id
			ORDER BY n.created_at DESC`, userID)
	} else {
		rows, err = db.DB.Query(`
			SELECT DISTINCT n.id, n.user_id, n.title, n.content, n.created_at, n.reminder_at, array_agg(c.name) as categories
			FROM notes n
			LEFT JOIN note_categories nc ON n.id = nc.note_id
			LEFT JOIN categories c ON nc.category_id = c.id
			WHERE n.user_id = $1 
				AND (n.title ILIKE $2 
					OR n.content ILIKE $2 
					OR c.name ILIKE $2)
			GROUP BY n.id
			ORDER BY n.created_at DESC`, userID, "%"+query+"%")
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var notes []Note
	for rows.Next() {
		var n Note
		var reminderAt sql.NullTime
		var categories sql.NullString
		err := rows.Scan(&n.ID, &n.UserID, &n.Title, &n.Content, &n.CreatedAt, &reminderAt, &categories)
		if err != nil {
			return nil, err
		}
		n.CreatedAt = n.CreatedAt.In(time.Local)
		if reminderAt.Valid {
			localTime := reminderAt.Time.In(time.Local)
			n.ReminderAt = &localTime
		}
		if categories.Valid && categories.String != "{}" {
			n.Categories = ParseCategories(categories.String)
		}
		notes = append(notes, n)
	}
	return notes, nil
}

func UpdateNote(noteID, userID int, title, content string, reminderAt *time.Time, categories []string) error {
	tx, err := db.DB.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	_, err = tx.Exec("UPDATE notes SET title = $1, content = $2, reminder_at = $3 WHERE id = $4 AND user_id = $5",
		title, content, reminderAt, noteID, userID)
	if err != nil {
		return err
	}

	_, err = tx.Exec("DELETE FROM note_categories WHERE note_id = $1", noteID)
	if err != nil {
		return err
	}

	for _, catName := range categories {
		if catName == "" || catName == "NULL" {
			continue
		}
		var catID int
		err = tx.QueryRow("INSERT INTO categories (name, user_id) VALUES ($1, $2) ON CONFLICT (name, user_id) DO UPDATE SET name = EXCLUDED.name RETURNING id",
			catName, userID).Scan(&catID)
		if err != nil {
			return err
		}
		_, err = tx.Exec("INSERT INTO note_categories (note_id, category_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", noteID, catID)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

func DeleteNote(noteID, userID int) error {
	_, err := db.DB.Exec("DELETE FROM notes WHERE id = $1 AND user_id = $2", noteID, userID)
	return err
}

func ParseCategories(catString string) []string {
	cleaned := catString[1 : len(catString)-1]
	if cleaned == "" {
		return []string{}
	}
	return strings.Split(cleaned, ",")
}
