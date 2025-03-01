// Логика регистрации и логина
package handlers

import (
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"zamemo-app/models"
)

// RegisterPage отображает страницу регистрации
func RegisterPage(w http.ResponseWriter, r *http.Request, templates *template.Template) {
	err := templates.ExecuteTemplate(w, "register.html", nil)
	if err != nil {
		http.Error(w, "Ошибка рендеринга шаблона", http.StatusInternalServerError)
		log.Println("Ошибка шаблона:", err)
	}
}

// RegisterHandler обрабатывает POST-запрос для регистрации
func RegisterHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/register", http.StatusSeeOther)
		return
	}

	username := r.FormValue("username")
	password := r.FormValue("password")

	if username == "" || password == "" {
		http.Error(w, "Логин и пароль обязательны", http.StatusBadRequest)
		return
	}

	err := models.CreateUser(username, password)
	if err != nil {
		http.Error(w, "Ошибка регистрации: возможно, логин уже занят", http.StatusInternalServerError)
		log.Println("Ошибка создания пользователя:", err)
		return
	}

	http.Redirect(w, r, "/", http.StatusSeeOther)
}

// LoginPage отображает страницу входа
func LoginPage(w http.ResponseWriter, r *http.Request, templates *template.Template) {
	err := templates.ExecuteTemplate(w, "login.html", nil)
	if err != nil {
		http.Error(w, "Ошибка рендеринга шаблона", http.StatusInternalServerError)
		log.Println("Ошибка шаблона:", err)
	}
}

func LogoutHandler(w http.ResponseWriter, r *http.Request) {
	http.SetCookie(w, &http.Cookie{
		Name:   "user_id",
		Value:  "",
		Path:   "/",
		MaxAge: -1, // Удаляет cookie
	})
	http.Redirect(w, r, "/login", http.StatusSeeOther)
}

func LoginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}

	username := r.FormValue("username")
	password := r.FormValue("password")

	if username == "" || password == "" {
		http.Error(w, "Логин и пароль обязательны", http.StatusBadRequest)
		return
	}

	user, err := models.AuthenticateUser(username, password)
	if err != nil {
		http.Error(w, "Ошибка входа: неверный логин или пароль", http.StatusUnauthorized)
		log.Println("Ошибка аутентификации:", err)
		return
	}

	http.SetCookie(w, &http.Cookie{
		Name:  "user_id",
		Value: fmt.Sprintf("%d", user.ID),
		Path:  "/",
	})

	log.Printf("Пользователь %s (ID: %d) успешно вошел", user.Username, user.ID)
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

// LoginAPI для мобильного приложения
func LoginAPI(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	username := r.FormValue("username")
	password := r.FormValue("password")

	if username == "" || password == "" {
		http.Error(w, "Username and password are required", http.StatusBadRequest)
		return
	}

	user, err := models.AuthenticateUser(username, password)
	if err != nil {
		http.Error(w, "Invalid username or password", http.StatusUnauthorized)
		return
	}

	http.SetCookie(w, &http.Cookie{
		Name:  "user_id",
		Value: fmt.Sprintf("%d", user.ID),
		Path:  "/",
	})

	log.Printf("Пользователь %s (ID: %d) успешно вошел через API", user.Username, user.ID)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]int{"user_id": user.ID})
}
