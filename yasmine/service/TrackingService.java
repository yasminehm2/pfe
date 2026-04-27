package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.dto.LiveTrackingDTO;
import org.yasmine.dto.StationDTO;
import org.yasmine.entity.Station;
import org.yasmine.entity.User;
import org.yasmine.entity.Vehicle;
import org.yasmine.repository.DisplayInfoRepository;
import org.yasmine.repository.StationRepository;
import org.yasmine.repository.UserRepository;
import org.yasmine.repository.VehicleRepository;

import java.util.List;

@Service // Tells Spring: "This is a Service class for Live Tracking logic."
@RequiredArgsConstructor // Automatically connects the Repositories.
@Slf4j // Allows us to print "Log messages" to the console.
public class TrackingService {

    private final DisplayInfoRepository displayInfoRepository;
    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;
    
    // 🚀 ADDED INJECTIONS FOR ETA CALCULATIONS
    private final StationService stationService;
    private final StationRepository stationRepository;
    private final RotationService rotationService;

    /**
     * 💡 LOGIC: "Find the bus on the map"
     */
    public Vehicle getLiveBusPosition(String rotationId) {
        return displayInfoRepository.findById(Long.parseLong(rotationId))
                .map(display -> vehicleRepository.findById(display.getVehicule()).orElse(null))
                .orElse(null);
    }

    /**
     * 💡 LOGIC: "Start the Tracking Session"
     */
    @Transactional
    public void activateLiveTracking(String userId, String rotationId) {
        if (userId != null && userId.startsWith("GUEST-")) {
            log.info("🚀 Guest session tracking trip ID: {}", rotationId);
            return; 
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
        
        log.info("👤 Registered User {} tracking trip ID: {}", userId, rotationId);
    }

    /**
     * 🚀 NEW LOGIC: "The Live Master Feed"
     * Packages the bus location, the target ETA, and the entire cascading itinerary map.
     */
    public LiveTrackingDTO getLiveTrackingUpdate(String rotationId, String targetStationId) {
        
        // 1. Fetch the bus location (from VehicleRepository)
        Vehicle vehicle = vehicleRepository.findByRotationId(rotationId).orElse(null);
        double busLat = (vehicle != null && vehicle.getNewlat() != null) ? stationService.parseCoordinate(vehicle.getNewlat()) : 0;
        double busLon = (vehicle != null && vehicle.getNewlon() != null) ? stationService.parseCoordinate(vehicle.getNewlon()) : 0;

        // 2. Fetch the target station
        Station targetStation = stationRepository.findById(targetStationId).orElse(null);
        double sLat = (targetStation != null) ? stationService.parseCoordinate(targetStation.getLatitude()) : 0;
        double sLon = (targetStation != null) ? stationService.parseCoordinate(targetStation.getLongitude()) : 0;

        // 3. Calculate distance to the main target station
        double distKm = stationService.calculateDistance(busLat, busLon, sLat, sLon);
        
        // 4. Determine Status & Alert
        boolean isArriving = distKm < 0.1; // Less than 100 meters away!
        String status = (busLat == 0) ? "OFFLINE" : (isArriving ? "ARRIVING" : "MOVING");

        // 🚀 5. Get the FULL cascade of ETAs for the entire route
        List<StationDTO> fullItinerary = rotationService.getFullItineraryWithLiveETAs(rotationId);
        
        // 6. Extract the ETA specifically for the target station so the big UI banner can use it
        Integer mainEta = null;
        for (StationDTO stop : fullItinerary) {
            if (stop.getId().equals(targetStationId)) {
                mainEta = stop.getLiveEtaMinutes();
                break;
            }
        }

        // 7. Package it all up for Flutter!
        return LiveTrackingDTO.builder()
                .rotationId(rotationId)
                .vehicleLat(busLat)
                .vehicleLon(busLon)
                .etaMinutes(mainEta)
                .status(status)
                .arrivalAlert(isArriving)
                .itinerary(fullItinerary) // 🚀 Attach the full map data here!
                .build();
    }
}