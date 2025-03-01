package db

import (
	"database/sql"
	_ "github.com/lib/pq"
	"log"
)

var DB *sql.DB

func InitDB() {
	connStr := "postgres://zamemo_user:z1a4m4e8t8k!@localhost:5432/zamemo_db?sslmode=disable"
	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Ошибка подключения к базе:", err)
	}
	err = DB.Ping()
	if err != nil {
		log.Fatal("Ошибка проверки соединения:", err)
	}
	log.Println("Успешно подключились к PostgreSQL!")
	createTables()
}

func createTables() {
	queries := []string{
		`CREATE TABLE IF NOT EXISTS users (
			id SERIAL PRIMARY KEY,
			username VARCHAR(50) UNIQUE NOT NULL,
			password VARCHAR(255) NOT NULL
		)`,
		`CREATE TABLE IF NOT EXISTS notes (
			id SERIAL PRIMARY KEY,
			user_id INT REFERENCES users(id),
			title VARCHAR(100) NOT NULL,
			content TEXT,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			reminder_at TIMESTAMP
		)`,
		`CREATE TABLE IF NOT EXISTS categories (
			id SERIAL PRIMARY KEY,
			name VARCHAR(50) NOT NULL,
			user_id INT REFERENCES users(id),
			UNIQUE (name, user_id)
		)`,
		`CREATE TABLE IF NOT EXISTS note_categories (
			note_id INT REFERENCES notes(id) ON DELETE CASCADE,
			category_id INT REFERENCES categories(id) ON DELETE CASCADE,
			PRIMARY KEY (note_id, category_id)
		)`,
	}

	for _, query := range queries {
		_, err := DB.Exec(query)
		if err != nil {
			log.Printf("Ошибка выполнения запроса '%s': %v", query, err)
		}
	}
	log.Println("Таблицы успешно созданы!")
}
