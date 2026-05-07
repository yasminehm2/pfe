package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.RotationDTO;
import org.yasmine.exception.TrackingUnavailableException;
import org.yasmine.service.RotationService;


@RestController // Tells Spring: "This class provides live data updates as JSON."
@RequestMapping("/api/tracking") // Base URL: http://your-ip:8080/api/tracking
@RequiredArgsConstructor // Connects the TrackingService automatically.
@CrossOrigin(origins = "*") // Allows the Flutter app to talk to this server.
public class RotationController {

    private final RotationService rotationService;

    /**
     * ✅ CONFIRMATION: "I am officially tracking this bus"
     */
    @PostMapping("/{rotationId}/confirm")
    public ResponseEntity<Void> confirmTrip(
            @PathVariable String rotationId, 
            @RequestParam String userId) {
        rotationService.activateLiveTracking(userId, rotationId);
        return ResponseEntity.ok().build(); 
    }

    /**
     * 📡 LIVE POLLING: "Where is the bus right now?"
     * The Flutter app calls this every few seconds.
     */
    @GetMapping("/{rotationId}/live")
    public ResponseEntity<RotationDTO> getLiveUpdate(
            @PathVariable String rotationId, 
            @RequestParam String stationId) {
        
        // 🚀 Just ask the Service for the complete tracking package!
        RotationDTO response = rotationService.getLiveTrackingUpdate(rotationId, stationId);

        // SAFETY CHECK: If the service reports the bus is offline/no GPS, throw our exception
        if (response.getStatus().equals("OFFLINE")) {
            throw new TrackingUnavailableException();
        }

        // Send the complete package back to Flutter
        return ResponseEntity.ok(response);
    }
}