package main

import (
	"encoding/json"
	"log"
	"net/http"
)

func statusHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(w, r)

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

func main() {

	http.HandleFunc("/api/status", statusHandler)

	log.Println("Server running on :8080")

	// http.ListenAndServe(":8080", nil)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func enableCors(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "https://supreme-pancake-777gvj5rvv9hrxvw-5173.app.github.dev")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}
}
