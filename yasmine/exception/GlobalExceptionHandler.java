package org.yasmine.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(TripCancelledException.class)
    public ResponseEntity<?> handleCancellation(TripCancelledException ex) {
        return ResponseEntity.status(HttpStatus.GONE)
            .body(Map.of("error", "TRIP_CANCELLED", "message", ex.getMessage()));
    }

    @ExceptionHandler(TrackingUnavailableException.class)
    public ResponseEntity<?> handleTrackingError(TrackingUnavailableException ex) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
            .body(Map.of("error", "GPS_OFFLINE", "message", ex.getMessage()));
    }
}