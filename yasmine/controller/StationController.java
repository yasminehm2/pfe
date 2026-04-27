package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.DisplayInfoDTO;
import org.yasmine.dto.StationDTO;
import org.yasmine.service.DisplayInfoService;
import org.yasmine.service.StationService;
import java.util.List;

@RestController // Tells Spring: "This class creates the web endpoints for station data."
@RequestMapping("/api/stations") // Base URL: http://your-ip:8080/api/stations
@RequiredArgsConstructor // Automatically connects (injects) the required services.
@CrossOrigin(origins = "*") // Allows your Flutter app to talk to this controller.
public class StationController {

    private final StationService stationService;
    private final DisplayInfoService displayInfoService;

    /**
     * 📍 RADIUS SEARCH: "Find stops near me"
     * URL: GET /api/stations/nearby?lat=34.7&lon=10.7&radius=2.0
     */
    @GetMapping("/nearby")
    public ResponseEntity<List<StationDTO>> getNearbyStations(
            @RequestParam double lat, 
            @RequestParam double lon,
            @RequestParam(defaultValue = "10.0") double radius) {
        // Asks the service to find all stations within the 'radius' (default 10km).
        return ResponseEntity.ok(stationService.getNearbyStations(lat, lon, radius));
    }

    /**
     * 🚌 STATION SCHEDULE: "What buses stop at this station?"
     * URL: GET /api/stations/{id}/trips
     */
    @GetMapping("/{stationId}/trips")
    public ResponseEntity<List<DisplayInfoDTO>> getTripsForStation(@PathVariable String stationId) {
        // Uses the "Bridge Search" in DisplayInfoService to find all 
        // active trips passing through this specific station.
        List<DisplayInfoDTO> rotations = displayInfoService.getAvailableRotations(stationId);
        return ResponseEntity.ok(rotations);
    }
    
    /**
     * 🗺️ ITINERARY: "Show the full route of this specific bus trip"
     * URL: GET /api/stations/trips/{id}/itinerary
     */
    @GetMapping("/trips/{rotationId}/itinerary")
    public ResponseEntity<List<StationDTO>> getTripItinerary(@PathVariable String rotationId) {
        // Returns the list of all stops in order (1st stop, 2nd stop, etc.) 
        // so the Flutter app can draw the line on the map.
        List<StationDTO> itinerary = stationService.getItineraryByRotation(rotationId);
        return ResponseEntity.ok(itinerary);
    }
}