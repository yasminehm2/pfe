package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.entity.Rotation;
import org.yasmine.service.ETAService;
import org.yasmine.service.TrackingService;

import java.util.List;

@RestController
@RequestMapping("/api/trips")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") 
public class TripController {
    
    private final TrackingService trackingService;

    @GetMapping("/station/{stationId}")
    public ResponseEntity<List<Rotation>> getTripsForStation(@PathVariable String stationId) {
        // Tapping a station reveals full details of the trip 
        List<Rotation> rotations = trackingService.getAvailableRotations(stationId);
        return ResponseEntity.ok(rotations);
    }

    @PostMapping("/{rotationId}/confirm")
    public ResponseEntity<Void> confirmTrip(
            @PathVariable String rotationId, 
            @RequestParam String userId) {
        
        // Customer confirms to activate live tracking 
        trackingService.activateLiveTracking(userId, rotationId);
        return ResponseEntity.ok().build();
    }
}