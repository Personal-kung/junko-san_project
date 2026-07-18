package models

type Service struct {
	ID              int    `json:"id"`
	Name            string `json:"name"`
	DurationMinutes int    `json:"duration_minutes"`
	Price           int    `json:"price"`
	Active          bool   `json:"active"`
	DisplayOrder    int    `json:"display_order"`
}
