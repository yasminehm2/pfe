package org.yasmine.exception;

/**
 * 📡 THE "NO SIGNAL" ALARM
 * Thrown when the system knows the bus exists, but can't find its live location.
 */
public class TrackingUnavailableException extends RuntimeException {
    
    // This is the message that will eventually reach the passenger's phone.
    @Override
    public String getMessage() {
        return "Live tracking is currently unavailable for this vehicle.";
    }
}