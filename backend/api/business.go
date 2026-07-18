package api

import (
	"encoding/json"
	"net/http"
	"os"

	"github.com/Personal-kung/junko-san_project/models"
)

func BusinessHandler(w http.ResponseWriter, r *http.Request) {

	if r.Method != http.MethodGet {

		http.Error(
			w,
			"Method not allowed",
			http.StatusMethodNotAllowed,
		)

		return
	}

	file, err := os.ReadFile("config/business.json")

	if err != nil {

		http.Error(
			w,
			"Unable to load configuration",
			http.StatusInternalServerError,
		)

		return
	}

	var business models.Business

	if err := json.Unmarshal(file, &business); err != nil {

		http.Error(
			w,
			"Invalid configuration",
			http.StatusInternalServerError,
		)

		return
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(business)
}
