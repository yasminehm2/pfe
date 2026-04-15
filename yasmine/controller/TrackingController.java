package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.LiveTrackingDTO;
import org.yasmine.entity.Vehicle;
import org.yasmine.exception.TrackingUnavailableException;
import org.yasmine.service.RotationService;
import org.yasmine.service.TrackingService;

@RestController
@RequestMapping("/api/tracking")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") 
public class TrackingController {

    private final TrackingService trackingService;
    private final RotationService rotationService; // Used for dynamic calculations

    /**
     * Activates live tracking for a specific passenger on a specific trip.
     */
    @PostMapping("/{rotationId}/confirm")
    public ResponseEntity<Void> confirmTrip(
            @PathVariable String rotationId, 
            @RequestParam String userId) {
        trackingService.activateLiveTracking(userId, rotationId);
        return ResponseEntity.ok().build();
    }

    /**
     * Polling endpoint for Flutter to get the live bus position and ETA.
     */
    @GetMapping("/{rotationId}/live")
    public ResponseEntity<LiveTrackingDTO> getLiveUpdate(
            @PathVariable String rotationId, 
            @RequestParam String stationId) {
        
        Vehicle vehicle = trackingService.getLiveBusPosition(rotationId);
        
        if (vehicle == null || vehicle.getNewlat() == null) {
            throw new TrackingUnavailableException();
        }

        // Fetching ETA (Logic moved to RotationService in previous steps)
        // If you still have a separate ETAService, inject it here instead.
        double eta = 0.0; 
        try {
            // Placeholder: Call your ETA calculation logic
            // eta = rotationService.calculateDynamicETA(rotationId, stationId);
        } catch (Exception e) {
            eta = 0.0;
        }

        LiveTrackingDTO response = LiveTrackingDTO.builder()
                .rotationId(rotationId)
                .vehicleLat(Double.parseDouble(vehicle.getNewlat().replace(",", ".")))
                .vehicleLon(Double.parseDouble(vehicle.getNewlon().replace(",", ".")))
                .etaMinutes(eta)
                .status(vehicle.getVisible() != null ? vehicle.getVisible() : "moving")
                .arrivalAlert(eta <= 1.0)
                .build();

        return ResponseEntity.ok(response);
    }
}