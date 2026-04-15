package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.DisplayInfoDTO;
import org.yasmine.dto.StationResponseDTO;
import org.yasmine.service.StationService;
import org.yasmine.service.TrackingService;

import java.util.List;

@RestController
@RequestMapping("/api/stations")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StationController {

    private final StationService stationService;
    private final TrackingService trackingService;

    /**
     * Finds stations within a specific radius of the user.
     */
    @GetMapping("/nearby")
    public ResponseEntity<List<StationResponseDTO>> getNearbyStations(
            @RequestParam double lat, 
            @RequestParam double lon,
            @RequestParam(defaultValue = "10.0") double radius) {
        return ResponseEntity.ok(stationService.getNearbyStations(lat, lon, radius));
    }

    /**
     * Fetches available bus rotations/trips passing through a specific station.
     */
    @GetMapping("/{stationId}/trips")
    public ResponseEntity<List<DisplayInfoDTO>> getTripsForStation(@PathVariable String stationId) {
        List<DisplayInfoDTO> rotations = trackingService.getAvailableRotations(stationId);
        return ResponseEntity.ok(rotations);
    }
    
    /**
     * Fetches the itinerary for a trip. 
     * Uses DisplayInfo to identify the trip and StationResponseDTO for the stops.
     */
    @GetMapping("/trips/{rotationId}/itinerary")
    public ResponseEntity<List<StationResponseDTO>> getTripItinerary(@PathVariable String rotationId) {
        // Logic: 
        // 1. Get Line ID from LineRot where rotation_id = rotationId
        // 2. Get all LineStations for that Line ID order by rank
        // 3. Map to StationResponseDTO
        List<StationResponseDTO> itinerary = stationService.getItineraryByRotation(rotationId);
        return ResponseEntity.ok(itinerary);
    }
}