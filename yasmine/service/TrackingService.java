package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.User;
import org.yasmine.entity.Vehicle;
import org.yasmine.repository.RotationRepository;
import org.yasmine.repository.UserRepository;
import org.yasmine.repository.VehicleRepository;
import org.yasmine.exception.TripCancelledException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TrackingService {

    private final RotationRepository rotationRepository;
    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository; // Added to fix GPS retrieval

    /**
     * Returns rotations for a station that are not cancelled (rannul != '1').
     */
    public List<Rotation> getAvailableRotations(String stationId) {
        return rotationRepository.findActiveRotationsByStation(stationId);
    }

    /**
     * Links a Sfax passenger to a specific bus for live tracking.
     */
    @Transactional
    public void activateLiveTracking(String userId, String rotationId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
                
        Rotation rotation = rotationRepository.findById(rotationId)
                .orElseThrow(() -> new RuntimeException("Rotation not found"));

        if (rotation.isCancelled()) {
            throw new TripCancelledException();
        }

        user.setChosenRotation(rotation);
        userRepository.save(user); 
    }

    /**
     * Retrieves the live coordinates from gps_vehic.
     */
    public Vehicle getLiveBusPosition(String rotationId) {
        // Uses the custom JOIN query to find the vehicle by rotation ID
        return vehicleRepository.findByRotationId(rotationId).orElse(null);
    }
}