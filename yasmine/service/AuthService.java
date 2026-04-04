package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.dto.GuestAccessDTO;
import org.yasmine.entity.User;
import org.yasmine.entity.UserRole;
import org.yasmine.repository.UserRepository;

import java.util.UUID;
import java.util.Map;
import java.util.HashMap;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;

    /**
     * Registers a new passenger with specific coordinates from Flutter.
     * Changed input to Map<String, Object> to handle numeric GPS data.
     */
    @Transactional
    public Map<String, Object> register(Map<String, Object> userData) { // ✅ Fixed: Map type
        String email = ((String) userData.get("email")).trim().toLowerCase();

        if (userRepository.findByEmail(email).isPresent()) {
            throw new RuntimeException("Email already exists in the Sfax database");
        }

        // Extract and parse coordinates safely
        double latitude = 0.0;
        double longitude = 0.0;

        try {
            if (userData.get("lat") != null) {
                // Safely convert Object to Double regardless of if it's String or Number
                latitude = Double.parseDouble(userData.get("lat").toString());
            }
            if (userData.get("lon") != null) {
                longitude = Double.parseDouble(userData.get("lon").toString());
            }
        } catch (Exception e) {
            System.out.println("GPS Parsing failed: " + e.getMessage());
        }

        // Build the User entity
        User newUser = User.builder()
                .id(UUID.randomUUID().toString()) 
                .name((String) userData.get("name"))
                .email(email)
                .password((String) userData.get("password")) 
                .lat(latitude)
                .lon(longitude)
                .role(UserRole.PASSENGER)
                .build();

        User savedUser = userRepository.save(newUser);

        Map<String, Object> response = new HashMap<>();
        response.put("userId", savedUser.getId());
        response.put("name", savedUser.getName());
        response.put("message", "User registered successfully");
        return response;
    }

    /**
     * Validates credentials and returns the User profile.
     */
    public Map<String, Object> authenticate(String email, String password) {
        return userRepository.findByEmail(email.trim().toLowerCase())
            .filter(user -> user.getPassword().equals(password))
            .map(user -> {
                Map<String, Object> response = new HashMap<>();
                response.put("userId", user.getId()); 
                response.put("email", user.getEmail()); // Added for the Flutter location sync
                response.put("name", user.getName());
                response.put("role", user.getRole());
                response.put("message", "Login successful");
                return response;
            })
            .orElseThrow(() -> new RuntimeException("Invalid email or password"));
    }

    /**
     * Updates an existing user's location (Used on Login).
     */
    public void updateUserCoordinates(String email, Double lat, Double lon) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
        
        user.setLat(lat);
        user.setLon(lon);
        
        userRepository.save(user);
    }

    public GuestAccessDTO createGuestSession() {
        return GuestAccessDTO.builder()
                .tempId("GUEST-" + UUID.randomUUID().toString())
                .role(UserRole.GUEST)
                .message("Guest access granted.")
                .build();
    }
}