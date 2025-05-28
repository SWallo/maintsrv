package main

import (
	"log/slog"
	"net/http"
	"os"
	"strconv"
)

func newMaintenanceHandler(staticDir string, responseCode int) http.Handler {
	mux := http.NewServeMux()
	fs := http.FileServer(http.Dir(staticDir))

	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	})

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(responseCode)
		fs.ServeHTTP(w, r)
		slog.Info("access",
			"method", r.Method,
			"uri", r.RequestURI,
			"remote", r.RemoteAddr,
			"status", responseCode,
		)
	})

	return mux
}

func main() {
	staticDir := os.Getenv("STATIC_DIR")
	responseCodeArg := os.Getenv("DEFAULT_RESPONSE_CODE")

	if staticDir == "" {
		staticDir = "./static"
	}

	responseCode := http.StatusServiceUnavailable

	if responseCodeArg != "" {
		var err error
		responseCode, err = strconv.Atoi(responseCodeArg)
		if err == nil {
			slog.Info("Setting default response code", "code", responseCode)
		} else {
			slog.Info("Invalid response code provided, using default", "code", responseCode)
		}
	} else {
		slog.Info("Using default response code", "code", responseCode)
	}

	handler := newMaintenanceHandler(staticDir, responseCode)

	slog.Info("Maintenance server running", "dir", staticDir, "addr", ":8080", "status", responseCode)
	if err := http.ListenAndServe(":8080", handler); err != nil {
		slog.Error("Server error", "err", err)
		os.Exit(1)
	}
}
