package org.yasmine.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.Map;

/**
 * 🛡️ THE GLOBAL SAFETY NET
 * This class watches every Controller. If a specific error is thrown,
 * it "catches" it here to send a nice JSON response to the mobile app.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 🚩 CASE: Trip was cancelled (rannul = '1')
     * Returns: Status 410 (GONE)
     */
    @ExceptionHandler(TripCancelledException.class)
    public ResponseEntity<?> handleCancellation(TripCancelledException ex) {
        return ResponseEntity.status(HttpStatus.GONE) // Tells the phone: "This resource is gone forever."
            .body(Map.of(
                "error", "TRIP_CANCELLED",
                "message", ex.getMessage()
            ));
    }

    /**
     * 📡 CASE: Bus is not sending GPS signals
     * Returns: Status 503 (SERVICE UNAVAILABLE)
     */
    @ExceptionHandler(TrackingUnavailableException.class)
    public ResponseEntity<?> handleTrackingError(TrackingUnavailableException ex) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE) // Tells the phone: "Try again later."
            .body(Map.of(
                "error", "GPS_OFFLINE",
                "message", ex.getMessage()
            ));
    }
}