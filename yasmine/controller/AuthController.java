package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.GuestAccessDTO;
import org.yasmine.service.AuthService;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") 
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody Map<String, Object> userData) {
        Map<String, Object> registrationResult = authService.register(userData);
        return ResponseEntity.ok(registrationResult);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        return ResponseEntity.ok(authService.authenticate(
            credentials.get("email"), 
            credentials.get("password")
        ));
    }

    @PatchMapping("/update-location")
    public ResponseEntity<?> updateLocation(@RequestBody Map<String, Object> locationData) {
        try {
            String email = (String) locationData.get("email");
            Double lat = Double.valueOf(locationData.get("lat").toString());
            Double lon = Double.valueOf(locationData.get("lon").toString());

            authService.updateUserCoordinates(email, lat, lon);
            return ResponseEntity.ok(Map.of("message", "Location synced to database"));
        } catch (Exception e) {
            return ResponseEntity.status(400).body("Failed to update location: " + e.getMessage());
        }
    }

    @PostMapping("/guest")
    public ResponseEntity<GuestAccessDTO> enterAsGuest() {
        return ResponseEntity.ok(authService.createGuestSession());
    }
}