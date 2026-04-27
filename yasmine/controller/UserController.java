package org.yasmine.controller;

import org.yasmine.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController // Tells Spring: "This class handles web requests for User data."
@RequestMapping("/api/users") // Base URL: http://your-ip:8080/api/users
@CrossOrigin(origins = "*") // Crucial: Allows your Flutter app to send data to the server.
public class UserController {

    @Autowired // Connects the UserRepository (The Database Gatekeeper).
    private UserRepository userRepository;

    /**
     * 📍 LOCATION PATCH: "Update where the passenger is standing"
     * URL: PATCH /api/users/{userId}/location
     * Logic: Updates ONLY the latitude and longitude without touching the password/name.
     */
    @PatchMapping("/{id}/location")
    public ResponseEntity<?> updateLocation(
            @PathVariable String id, // The unique User ID from Flutter.
            @RequestBody Map<String, Double> coords) { // The {lat, lon} sent by the phone.

        // 1. Search for the user in the database by their ID.
        return userRepository.findById(id).map(user -> {
            
            // 2. Extract coordinates from the request and update the User object.
            user.setLat(coords.get("lat")); 
            user.setLon(coords.get("lon")); 
            
            // 3. Save the updated user back to the MySQL database.
            userRepository.save(user);
            
            // 4. Send back a success message.
            return ResponseEntity.ok("Passenger position updated successfully.");
        })
        // 5. SAFETY: If the user ID doesn't exist, send a "404 Not Found" error.
        .orElse(ResponseEntity.notFound().build());
    }
}