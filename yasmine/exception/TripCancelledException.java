package org.yasmine.exception;

// Thrown when a passenger tries to track a trip that has rannul = '1' [cite: 7]
public class TripCancelledException extends RuntimeException {
    public String getMessage() {
        return "This trip has been cancelled by the administrator.";
    }
}

