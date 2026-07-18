package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/Personal-kung/junko-san_project/api"
	"github.com/Personal-kung/junko-san_project/database"
)

func statusHandler(w http.ResponseWriter, r *http.Request) {

	if r.Method == http.MethodOptions {
		return
	}

	response := map[string]string{
		"status": "running",
		"system": "Junko-san project",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func withCors(handler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set(
			"Access-Control-Allow-Origin",
			"*",
		)
		w.Header().Set(
			"Access-Control-Allow-Methods",
			"GET, POST, PATCH, PUT, DELETE, OPTIONS",
		)
		w.Header().Set(
			"Access-Control-Allow-Headers",
			"Content-Type, Authorization",
		)
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		handler(w, r)
	}
}

func main() {

	database.Connect()

	http.HandleFunc("/api/status", withCors(statusHandler))
	http.HandleFunc("/api/services", withCors(api.ServicesHandler))
	http.HandleFunc("/api/reservations", withCors(api.ReservationHandler))
	http.HandleFunc("/api/business", withCors(api.BusinessHandler))

	log.Println("Server running on :8080")

	log.Fatal(http.ListenAndServe(":8080", nil))
}
