package main

import (
	"net/http/httptest"
	"testing"
)

func TestRootReturnsConfiguredStatus(t *testing.T) {
	handler := newMaintenanceHandler("./static", 503)

	req := httptest.NewRequest("GET", "/", nil)
	rr := httptest.NewRecorder()

	handler.ServeHTTP(rr, req)

	if rr.Code != 503 {
		t.Errorf("expected status 503, got %d", rr.Code)
	}
}

func TestHealthzReturnsOK(t *testing.T) {
	handler := newMaintenanceHandler("./static", 503)

	req := httptest.NewRequest("GET", "/healthz", nil)
	rr := httptest.NewRecorder()

	handler.ServeHTTP(rr, req)

	if rr.Code != 200 {
		t.Errorf("expected status 200, got %d", rr.Code)
	}
	if rr.Body.String() != "ok" {
		t.Errorf("expected body 'ok', got '%s'", rr.Body.String())
	}
}
