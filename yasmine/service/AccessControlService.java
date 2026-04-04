package org.yasmine.service;

import org.springframework.stereotype.Service;
import org.yasmine.entity.UserRole;
import org.yasmine.exception.RegistrationRequiredException;

@Service
public class AccessControlService {

    public void validateAction(UserRole role, String action) {
        if (role == UserRole.GUEST && action.equals("LIVE_TRACKING")) {
            throw new RegistrationRequiredException("Please sign up to activate live bus tracking.");
        }
    }
}