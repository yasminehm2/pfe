package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.UserDTO;
import org.yasmine.service.AuthService;

import java.util.Map;

@RestController 
@RequestMapping("/api/auth") 
@RequiredArgsConstructor 
@CrossOrigin(origins = "*") 
public class AuthController {

    private final AuthService authService;

    /**
     * 🔎 QUICK CHECK: "Is this email already registered?"
     * GET /api/auth/check-email?email=test@mail.com
     */
    @GetMapping("/check-email")
    public ResponseEntity<Map<String, Boolean>> checkEmail(@RequestParam String email) {
        boolean exists = authService.isEmailTaken(email);
        return ResponseEntity.ok(Map.of("exists", exists));
    }

    /**
     * 📝 SIGNUP: "Create a new account"
     * 🚀 Updated to use UserDTO for structured request body.
     */
    @PostMapping("/signup")
    public ResponseEntity<UserDTO> signup(@RequestBody UserDTO userData) {
        // We pass the typed DTO instead of a messy Map
        UserDTO result = authService.register(userData);
        return ResponseEntity.ok(result);
    }

    /**
     * 🔑 LOGIN: "Check my credentials"
     * 🚀 Updated to use UserDTO for email/password extraction.
     */
    @PostMapping("/login")
    public ResponseEntity<UserDTO> login(@RequestBody UserDTO credentials) {
        // authService.authenticate now returns a UserDTO instead of a Map
        return ResponseEntity.ok(authService.authenticate(
            credentials.getEmail(), 
            credentials.getPassword()
        ));
    }

    /**
     * 🚪 GUEST: "Let me in without an account"
     * 🚀 Returns a structured UserDTO for the guest session.
     */
    @PostMapping("/guest")
    public ResponseEntity<UserDTO> enterAsGuest() {
        return ResponseEntity.ok(authService.createGuestSession());
    }

    /**
     * 📍 COORDINATES: "Update passenger location"
     * 🚀 Structured update using email and coordinates from DTO.
     */
    @PostMapping("/update-location")
    public ResponseEntity<Map<String, String>> updateLocation(@RequestBody UserDTO locationData) {
        authService.updateUserCoordinates(
            locationData.getEmail(),
            locationData.getLat(),
            locationData.getLon()
        );
        return ResponseEntity.ok(Map.of("status", "Location updated"));
    }
}