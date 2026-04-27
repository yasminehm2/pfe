package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.GuestAccessDTO;
import org.yasmine.service.AuthService;

import java.util.Map;

@RestController // Tells Spring: "This class handles web requests and sends back JSON data."
@RequestMapping("/api/auth") // Every URL in this file starts with http://your-ip:8080/api/auth
@RequiredArgsConstructor // Automatically connects the AuthService.
@CrossOrigin(origins = "*") // Allows your Flutter app (even from a different device) to talk to this server.
public class AuthController {

    private final AuthService authService;

    /**
     * 📝 SIGNUP: "Create a new account"
     * Accessed via POST to /api/auth/signup
     */
    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody Map<String, Object> userData) {
        // Takes the JSON sent by the phone, passes it to the service, and returns the result.
        Map<String, Object> registrationResult = authService.register(userData);
        return ResponseEntity.ok(registrationResult);
    }

    /**
     * 🔑 LOGIN: "Check my credentials"
     * Accessed via POST to /api/auth/login
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        // Extracts email and password from the phone's request and checks if they are valid.
        return ResponseEntity.ok(authService.authenticate(
            credentials.get("email"), 
            credentials.get("password")
        ));
    }

    /**
     * 🚪 GUEST: "Let me in without an account"
     * Accessed via POST to /api/auth/guest
     */
    @PostMapping("/guest")
    public ResponseEntity<GuestAccessDTO> enterAsGuest() {
        // Asks the service to create a temporary session and sends it back to the phone.
        return ResponseEntity.ok(authService.createGuestSession());
    }
}