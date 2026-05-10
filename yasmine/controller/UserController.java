package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.UserDTO;
import org.yasmine.service.UserService;

import java.util.Map;

@RestController 
@RequestMapping("/api/users") // 🚀 All endpoints now start with /api/users
@RequiredArgsConstructor 
@CrossOrigin(origins = "*") 
public class UserController {

    // We only need AuthService now, as it securely handles all user and location logic!
    private final UserService userService;

    /**
     * 🔎 QUICK CHECK: "Is this email already registered?"
     * GET /api/users/check-email?email=test@mail.com
     */
    @GetMapping("/check-email")
    public ResponseEntity<Map<String, Boolean>> checkEmail(@RequestParam String email) {
        boolean exists = userService.isEmailTaken(email);
        return ResponseEntity.ok(Map.of("exists", exists));
    }

    /**
     * 📝 SIGNUP: "Create a new account"
     * POST /api/users/signup
     */
    @PostMapping("/signup")
    public ResponseEntity<UserDTO> signup(@RequestBody UserDTO userData) {
        UserDTO result = userService.register(userData);
        return ResponseEntity.ok(result);
    }

    /**
     * 🔑 LOGIN: "Check my credentials"
     * POST /api/users/login
     */
    @PostMapping("/login")
    public ResponseEntity<UserDTO> login(@RequestBody UserDTO credentials) {
        return ResponseEntity.ok(userService.authenticate(
            credentials.getEmail(), 
            credentials.getPassword()
        ));
    }

    /**
     * 🚪 GUEST: "Let me in without an account"
     * POST /api/users/guest
     */
    @PostMapping("/guest")
    public ResponseEntity<UserDTO> enterAsGuest() {
        return ResponseEntity.ok(userService.createGuestSession());
    }

    /**
     * 📍 COORDINATES: "Update passenger location"
     * POST /api/users/update-location
     * Replaces the old PATCH method. Uses email and DTO for clean architecture.
     */
    @PostMapping("/update-location")
    public ResponseEntity<Map<String, String>> updateLocation(@RequestBody UserDTO locationData) {
        userService.updateUserCoordinates(
            locationData.getEmail(),
            locationData.getLat(),
            locationData.getLon()
        );
        return ResponseEntity.ok(Map.of("status", "Location updated successfully"));
    }
}