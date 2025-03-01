package main

import (
	"html/template"
	"log"
	"net/http"
	"strings"
	"zamemo-app/db"
	"zamemo-app/handlers"

	"github.com/gorilla/mux"
)

func main() {
	db.InitDB()

	funcMap := template.FuncMap{
		"join": strings.Join,
	}
	templates := template.Must(template.New("").Funcs(funcMap).ParseGlob("templates/*.html"))

	r := mux.NewRouter()

	// Веб-маршруты
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/notes", http.StatusSeeOther)
	})
	r.HandleFunc("/register", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			handlers.RegisterPage(w, r, templates)
		} else if r.Method == http.MethodPost {
			handlers.RegisterHandler(w, r)
		}
	})
	r.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			handlers.LoginPage(w, r, templates)
		} else if r.Method == http.MethodPost {
			handlers.LoginHandler(w, r)
		}
	})
	r.HandleFunc("/logout", handlers.LogoutHandler)
	r.HandleFunc("/notes", func(w http.ResponseWriter, r *http.Request) {
		handlers.NotesPage(w, r, templates)
	})
	r.HandleFunc("/create-note", handlers.CreateNoteHandler)
	r.HandleFunc("/edit-note", func(w http.ResponseWriter, r *http.Request) {
		handlers.EditNotePage(w, r, templates)
	})
	r.HandleFunc("/update-note", handlers.UpdateNoteHandler)
	r.HandleFunc("/delete-note", handlers.DeleteNoteHandler)

	// API-маршруты
	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/notes", handlers.GetNotesAPI).Methods("GET")
	api.HandleFunc("/notes", handlers.CreateNoteAPI).Methods("POST")
	api.HandleFunc("/login", handlers.LoginAPI).Methods("POST") // Убедись, что это есть

	log.Println("Сервер запущен на :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
