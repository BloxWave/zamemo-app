// Модель пользователя
package models

import (
	"database/sql"
	"errors"
	"golang.org/x/crypto/bcrypt"
	"zamemo-app/db"
)

// User описывает пользователя
type User struct {
	ID       int
	Username string
	Password string // Хешированный пароль
}

// CreateUser создает нового пользователя в базе
func CreateUser(username, password string) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	_, err = db.DB.Exec("INSERT INTO users (username, password) VALUES ($1, $2)", username, hashedPassword)
	return err
}

// AuthenticateUser проверяет логин и пароль
func AuthenticateUser(username, password string) (*User, error) {
	user := &User{}
	err := db.DB.QueryRow("SELECT id, username, password FROM users WHERE username = $1", username).
		Scan(&user.ID, &user.Username, &user.Password)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("пользователь не найден")
		}
		return nil, err
	}

	// Сравниваем введенный пароль с хешированным
	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
	if err != nil {
		return nil, errors.New("неверный пароль")
	}

	return user, nil
}
