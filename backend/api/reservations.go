package api

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/Personal-kung/junko-san_project/database"
	"github.com/Personal-kung/junko-san_project/models"
)

func ReservationHandler(w http.ResponseWriter, r *http.Request) {

	switch r.Method {

	case http.MethodGet:
		getReservations(w, r)

	case http.MethodPost:
		createReservation(w, r)

	case http.MethodPatch:
		updateReservationStatus(w, r)

	default:
		http.Error(
			w,
			"Method not allowed",
			http.StatusMethodNotAllowed,
		)
	}
}

func createReservation(w http.ResponseWriter, r *http.Request) {

	var reservation models.Reservation

	err := json.NewDecoder(r.Body).Decode(&reservation)

	if err != nil {
		http.Error(
			w,
			"Invalid request",
			http.StatusBadRequest,
		)
		return
	}

	query := `
	INSERT INTO reservations
	(
		customer_name,
		phone,
		service,
		reservation_date
	)
	VALUES (?, ?, ?, ?)
	`

	result, err := database.DB.Exec(
		query,
		reservation.CustomerName,
		reservation.Phone,
		reservation.Service,
		reservation.ReservationDate,
	)

	if err != nil {
		http.Error(
			w,
			"Database error",
			http.StatusInternalServerError,
		)
		return
	}

	id, _ := result.LastInsertId()

	reservation.ID = int(id)
	reservation.Status = "pending"

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)

	json.NewEncoder(w).Encode(reservation)
}

func getReservations(w http.ResponseWriter, r *http.Request) {

	rows, err := database.DB.Query(`
		SELECT
			id,
			customer_name,
			phone,
			service,
			reservation_date,
			status,
			created_at
		FROM reservations
		ORDER BY reservation_date ASC
	`)

	if err != nil {
		http.Error(
			w,
			"Database error",
			http.StatusInternalServerError,
		)
		return
	}

	defer rows.Close()

	reservations := []models.Reservation{}

	for rows.Next() {

		var reservation models.Reservation

		err := rows.Scan(
			&reservation.ID,
			&reservation.CustomerName,
			&reservation.Phone,
			&reservation.Service,
			&reservation.ReservationDate,
			&reservation.Status,
			&reservation.CreatedAt,
		)

		if err != nil {
			continue
		}

		reservations = append(reservations, reservation)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reservations)
}

func updateReservationStatus(w http.ResponseWriter, r *http.Request) {

	idString := r.URL.Query().Get("id")

	if idString == "" {
		http.Error(w, "Missing reservation id", http.StatusBadRequest)
		return
	}

	id, err := strconv.Atoi(idString)

	if err != nil {
		http.Error(w, "Invalid reservation id", http.StatusBadRequest)
		return
	}

	var body struct {
		Status string `json:"status"`
	}

	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	body.Status = strings.ToLower(body.Status)

	if body.Status != "approved" &&
		body.Status != "rejected" &&
		body.Status != "pending" {

		http.Error(w, "Invalid status", http.StatusBadRequest)
		return
	}

	_, err = database.DB.Exec(
		`UPDATE reservations SET status=? WHERE id=?`,
		body.Status,
		id,
	)

	if err != nil {
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(map[string]any{
		"id":     id,
		"status": body.Status,
	})
}
