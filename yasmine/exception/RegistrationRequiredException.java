package org.yasmine.exception;

public class RegistrationRequiredException extends RuntimeException {
    public RegistrationRequiredException(String message) {
        super(message);
    }
}