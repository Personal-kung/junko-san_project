package models

import "time"

type Reservation struct {
	ID              int       `json:"id"`
	CustomerName    string    `json:"customer_name"`
	Phone           string    `json:"phone"`
	Service         string    `json:"service"`
	ReservationDate string    `json:"reservation_date"`
	Status          string    `json:"status"`
	CreatedAt       time.Time `json:"created_at"`
}
