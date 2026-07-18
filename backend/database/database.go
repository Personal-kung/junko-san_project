package database

import (
	"database/sql"
	"log"

	_ "modernc.org/sqlite"
)

var DB *sql.DB

func Connect() {
	var err error

	DB, err = sql.Open("sqlite", "./junko.db")
	if err != nil {
		log.Fatal(err)
	}

	if err = DB.Ping(); err != nil {
		log.Fatal(err)
	}

	log.Println("Database connected")

	createTables()
	seedServices()
}

func createTables() {

	reservations := `
	CREATE TABLE IF NOT EXISTS reservations (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		customer_name TEXT NOT NULL,
		phone TEXT,
		service TEXT NOT NULL,
		reservation_date TEXT NOT NULL,
		status TEXT DEFAULT 'pending',
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);
	`

	if _, err := DB.Exec(reservations); err != nil {
		log.Fatal(err)
	}

	services := `
	CREATE TABLE IF NOT EXISTS services (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL UNIQUE,
		duration_minutes INTEGER NOT NULL,
		price INTEGER NOT NULL,
		active INTEGER NOT NULL DEFAULT 1,
		display_order INTEGER NOT NULL
	);
	`

	if _, err := DB.Exec(services); err != nil {
		log.Fatal(err)
	}

	log.Println("Database tables ready")
}

func seedServices() {

	var count int

	err := DB.QueryRow(
		`SELECT COUNT(*) FROM services`,
	).Scan(&count)

	if err != nil {
		log.Fatal(err)
	}

	if count > 0 {
		return
	}

	type service struct {
		Name     string
		Duration int
		Price    int
		Order    int
	}

	defaultServices := []service{
		{"Haircut", 60, 4500, 1},
		{"Hair Coloring", 120, 8000, 2},
		{"Perm", 150, 9500, 3},
		{"Treatment", 45, 3500, 4},
		{"Consultation", 30, 0, 5},
	}

	stmt := `
	INSERT INTO services
	(name, duration_minutes, price, display_order)
	VALUES (?, ?, ?, ?)
	`

	for _, s := range defaultServices {
		_, err := DB.Exec(
			stmt,
			s.Name,
			s.Duration,
			s.Price,
			s.Order,
		)

		if err != nil {
			log.Fatal(err)
		}
	}

	log.Println("Default services inserted")
}
