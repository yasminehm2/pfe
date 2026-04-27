package org.yasmine.exception;

/**
 * 🚩 THE CANCELLED TRIP ALARM
 * This error is triggered if a user tries to track a "ghost" trip.
 * It maps to the 'rannul' field in your Rotation entity.
 */
public class TripCancelledException extends RuntimeException {
    
    // This is the "Voice" of the error.
    // When the Flutter app hits this error, this is the text it receives.
    @Override
    public String getMessage() {
        return "This trip has been cancelled";
    }
}