package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.dto.UserDTO;
import org.yasmine.entity.User;
import org.yasmine.entity.UserRole;
import org.yasmine.repository.UserRepository;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder; 
    private final JwtService jwtService;// 🔐 Injected via RequiredArgsConstructor

    /**
     * 🔎 QUICK CHECK: "Is this email already registered?"
     */
    public boolean isEmailTaken(String email) {
        return userRepository.existsByEmail(email.trim().toLowerCase());
    }

    /**
     * 📝 REGISTER: "Create a new account with a hashed password"
     */
    @Transactional
    public UserDTO register(UserDTO registrationData) {
        String email = registrationData.getEmail().trim().toLowerCase();

        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email already exists");
        }

        // 🛡️ Create the user and hash the password before it hits the database
        User newUser = User.builder()
                .id(UUID.randomUUID().toString())
                .name(registrationData.getName())
                .email(email)
                // 🚀 BCrypt encoding happens here
                .password(passwordEncoder.encode(registrationData.getPassword())) 
                .lat(registrationData.getLat() != null ? registrationData.getLat() : 0.0)
                .lon(registrationData.getLon() != null ? registrationData.getLon() : 0.0)
                .role(UserRole.PASSENGER)
                .build();

        userRepository.save(newUser);
        String jwtToken = jwtService.generateToken(newUser.getEmail(), newUser.getRole().name());

        return UserDTO.builder()
                .id(newUser.getId())
                .message("User registered successfully")
                .token(jwtToken)
                .build();
    }

    /**
     * 🔑 LOGIN: "Verify credentials using BCrypt matching"
     */
    public UserDTO authenticate(String email, String password) {
        // 1. Find the user by email
        User user = userRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        // 2. 🛡️ Check if the raw password matches the encoded hash in DB
        // We use .matches() because BCrypt hashes cannot be decrypted!
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }
        String jwtToken = jwtService.generateToken(user.getEmail(), user.getRole().name());
        // 3. Return the user info (without the password)
        return UserDTO.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .role(user.getRole())
                .message("Login successful")
                .token(jwtToken)
                .build();
    }

    /**
     * 🚪 GUEST: "Temporary session for quick browsing"
     */
    public UserDTO createGuestSession() {
    	String tempId = "GUEST-" + UUID.randomUUID().toString();
        // Guests need tokens too to access the system safely!
        String jwtToken = jwtService.generateToken(tempId + "@guest.com", UserRole.GUEST.name());
        return UserDTO.builder()
                .id("GUEST-" + UUID.randomUUID().toString())
                .role(UserRole.GUEST)
                .message("Welcome! You are browsing as a guest.")
                .token(jwtToken)
                .build();
    }

    /**
     * 📍 LOCATION: "Update GPS coordinates via email"
     */
    public void updateUserCoordinates(String email, Double lat, Double lon) {
        User user = userRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        user.setLat(lat);
        user.setLon(lon);
        userRepository.save(user);
    }
}