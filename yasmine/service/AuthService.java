package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.dto.GuestAccessDTO;
import org.yasmine.entity.User;
import org.yasmine.entity.UserRole;
import org.yasmine.repository.UserRepository;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;

    @Transactional
    public Map<String, Object> register(Map<String, Object> userData) {
        String email = ((String) userData.get("email")).trim().toLowerCase();
        if (userRepository.findByEmail(email).isPresent()) {
            throw new RuntimeException("Email already exists");
        }

        User newUser = User.builder()
                .id(UUID.randomUUID().toString())
                .name((String) userData.get("name"))
                .email(email)
                .password((String) userData.get("password"))
                .lat(Double.parseDouble(userData.getOrDefault("lat", "0").toString()))
                .lon(Double.parseDouble(userData.getOrDefault("lon", "0").toString()))
                .role(UserRole.PASSENGER)
                .build();

        userRepository.save(newUser);
        return Map.of("userId", newUser.getId(), "message", "User registered successfully");
    }

    public Map<String, Object> authenticate(String email, String password) {
        return userRepository.findByEmail(email.trim().toLowerCase())
            .filter(u -> u.getPassword().equals(password))
            .map(u -> {
                // Using a HashMap avoids potential type inference issues with Map.of
                Map<String, Object> response = new HashMap<>();
                response.put("userId", u.getId());
                response.put("role", u.getRole());
                response.put("message", "Login successful");
                // Optional: add email if your Flutter location sync needs it
                response.put("email", u.getEmail()); 
                return response;
            })
            .orElseThrow(() -> new RuntimeException("Invalid credentials"));
    }
    public GuestAccessDTO createGuestSession() {
        return GuestAccessDTO.builder().tempId("GUEST-"+UUID.randomUUID()).role(UserRole.GUEST).build();
    }
    public void updateUserCoordinates(String email, Double lat, Double lon) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
        user.setLat(lat);
        user.setLon(lon);
        userRepository.save(user);
    }
}