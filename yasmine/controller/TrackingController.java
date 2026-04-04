package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.LiveTrackingDTO;
import org.yasmine.entity.Vehicle;
import org.yasmine.exception.TrackingUnavailableException;
import org.yasmine.service.ETAService;
import org.yasmine.service.TrackingService;

@RestController
@RequestMapping("/api/tracking")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") 
public class TrackingController {

    private final TrackingService trackingService;
    private final ETAService etaService;

    /**
     * Poll this endpoint every 5-10 seconds from Flutter.
     * It fulfills the requirement of updating the bus icon from gps_vehic data.
     */
    @GetMapping("/{rotationId}/live")
    public ResponseEntity<LiveTrackingDTO> getLiveUpdate(
            @PathVariable String rotationId, 
            @RequestParam String stationId) {
        
        // 1. Retrieve the vehicle from the central database (gps_vehic) [cite: 40]
        Vehicle vehicle = trackingService.getLiveBusPosition(rotationId);
        
        if (vehicle == null || vehicle.getNewlat() == null) {
            throw new TrackingUnavailableException();
        }

        // 2. Intelligent Processing: Recalculate ETA at stops [cite: 26]
        double eta = etaService.calculateDynamicETA(rotationId, stationId);

        // 3. Prepare the data package for the Information Dissemination Module [cite: 49]
        LiveTrackingDTO response = LiveTrackingDTO.builder()
                .rotationId(rotationId)
                .vehicleLat(Double.parseDouble(vehicle.getNewlat()))
                .vehicleLon(Double.parseDouble(vehicle.getNewlon()))
                .etaMinutes(eta)
                .status(vehicle.getVisible() != null ? vehicle.getVisible() : "moving") // [cite: 9]
                .arrivalAlert(eta <= 1.0) // Trigger alert if ETA < 1 min [cite: 5]
                .build();

        return ResponseEntity.ok(response);
    }
}