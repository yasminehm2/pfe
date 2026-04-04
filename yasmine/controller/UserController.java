package org.yasmine.controller;

import org.yasmine.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*") // Allows Flutter's http client to connect
public class UserController {

    @Autowired
    private UserRepository userRepository;

    /**
     * Updates the passenger's current position in the Sfax database.
     * Flutter must pass the dynamic userId received during login/signup.
     */
    @PatchMapping("/{id}/location")
    public ResponseEntity<?> updateLocation(
            @PathVariable String id,
            @RequestBody Map<String, Double> coords) {

        return userRepository.findById(id).map(user -> {
            // Update the lat/lon fields in the User entity
            user.setLat(coords.get("lat")); 
            user.setLon(coords.get("lon")); 
            
            // Persist the changes to MySQL
            userRepository.save(user);
            
            return ResponseEntity.ok("Passenger position updated successfully.");
        }).orElse(ResponseEntity.notFound().build());
    }
}