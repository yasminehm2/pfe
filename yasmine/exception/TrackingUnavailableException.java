package org.yasmine.exception;

public class TrackingUnavailableException extends RuntimeException {
    public String getMessage() {
        return "Live tracking is currently unavailable for this vehicle.";
    }
}