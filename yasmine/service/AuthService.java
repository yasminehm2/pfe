package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.dto.GuestAccessDTO;
import org.yasmine.entity.User;
import org.yasmine.entity.UserRole;
import org.yasmine.repository.UserRepository;
import java.util.*;

@Service // Tells Spring: "This is a Service class for business logic."
@RequiredArgsConstructor // Automatically connects the UserRepository.
public class AuthService {
    private final UserRepository userRepository;

    /**
     * 💡 LOGIC: "Register a New User"
     */
    @Transactional // Ensures that if something fails during saving, no partial data is left in the DB.
    public Map<String, Object> register(Map<String, Object> userData) {
        // 1. Clean up the email (remove spaces and make lowercase) to prevent duplicates like "User@Me.com" vs "user@me.com".
        String email = ((String) userData.get("email")).trim().toLowerCase();
        
        // 2. Check if the email is already in the system.
        if (userRepository.findByEmail(email).isPresent()) {
            throw new RuntimeException("Email already exists");
        }

        // 3. Create the new User object using the Builder pattern.
        User newUser = User.builder()
                .id(UUID.randomUUID().toString()) // Give them a unique random ID.
                .name((String) userData.get("name"))
                .email(email)
                .password((String) userData.get("password")) // ⚠️ In a real app, you should encode this!
                .lat(Double.parseDouble(userData.getOrDefault("lat", "0").toString()))
                .lon(Double.parseDouble(userData.getOrDefault("lon", "0").toString()))
                .role(UserRole.PASSENGER) // New signups are set to "PASSENGER" by default.
                .build();

        // 4. Save to database and return a success message.
        userRepository.save(newUser);
        return Map.of("userId", newUser.getId(), "message", "User registered successfully");
    }

    /**
     * 💡 LOGIC: "Login Check"
     */
    public Map<String, Object> authenticate(String email, String password) {
        return userRepository.findByEmail(email.trim().toLowerCase())
            // Find the user, then check if the password matches.
            .filter(u -> u.getPassword().equals(password))
            // If it matches, build a "Welcome Package" (Response Map).
            .map(u -> {
                Map<String, Object> response = new HashMap<>();
                response.put("userId", u.getId());
                response.put("role", u.getRole());
                response.put("message", "Login successful");
                response.put("email", u.getEmail()); 
                return response;
            })
            // If the email is wrong OR the password doesn't match, throw an error.
            .orElseThrow(() -> new RuntimeException("Invalid credentials"));
    }

    /**
     * 💡 LOGIC: "Create a Guest Ticket"
     * For users who don't want to log in, give them a temporary ID and "GUEST" powers.
     */
    public GuestAccessDTO createGuestSession() {
        return GuestAccessDTO.builder()
                .tempId("GUEST-" + UUID.randomUUID())
                .role(UserRole.GUEST)
                .build();
    }

    /**
     * 💡 LOGIC: "Update GPS Location"
     * Every few seconds, the user's phone sends its coordinates to this method 
     * so the backend knows where the passenger is.
     */
    public void updateUserCoordinates(String email, Double lat, Double lon) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
        
        user.setLat(lat);
        user.setLon(lon);
        userRepository.save(user); // Save the new position.
    }
}