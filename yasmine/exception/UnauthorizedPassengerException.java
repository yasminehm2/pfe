package org.yasmine.exception;

public class UnauthorizedPassengerException extends RuntimeException {
    public String getMessage() {
        return "Please log in to access live tracking features.";
    }
}