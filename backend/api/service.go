package api

import (
	"encoding/json"
	"net/http"

	"github.com/Personal-kung/junko-san_project/database"
	"github.com/Personal-kung/junko-san_project/models"
)

func ServicesHandler(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	rows, err := database.DB.Query(`
		SELECT
			id,
			name,
			duration_minutes,
			price,
			active,
			display_order
		FROM services
		WHERE active = 1
		ORDER BY display_order ASC
	`)

	if err != nil {
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}

	defer rows.Close()

	services := []models.Service{}

	for rows.Next() {

		var service models.Service

		err := rows.Scan(
			&service.ID,
			&service.Name,
			&service.DurationMinutes,
			&service.Price,
			&service.Active,
			&service.DisplayOrder,
		)

		if err != nil {
			continue
		}

		services = append(services, service)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(services)
}
