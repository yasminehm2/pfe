package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.Station;
import org.yasmine.entity.Vehicle;
import org.yasmine.repository.RotationRepository;
import org.yasmine.repository.StationRepository;
import org.yasmine.repository.VehicleRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class RotationService {

    private final RotationRepository rotationRepository;
    private final VehicleRepository vehicleRepository;
    private final StationRepository stationRepository;
    private final StationService stationService;

    /**
     * Retrieves all currently active trips (rotations) that have not been cancelled.
     */
    public List<Rotation> getActiveRotations() {
        return rotationRepository.findAll().stream()
                .filter(r -> !r.isCancelled())
                .toList();
    }

    /**
     * Dynamically calculates the ETA for a specific bus to reach a specific station.
     * This replaces the old scheduled task and database writes.
     */
    public double calculateDynamicETA(String rotationId, String targetStationId) {
        // 1. Get the live bus position
        Vehicle vehicle = vehicleRepository.findByRotationId(rotationId).orElse(null);
        
        if (vehicle == null || vehicle.getNewlat() == null || vehicle.getNewlon() == null) {
            log.warn("Vehicle data missing for rotation: {}", rotationId);
            return 0.0; 
        }

        double busLat = stationService.parseCoordinate(vehicle.getNewlat());
        double busLon = stationService.parseCoordinate(vehicle.getNewlon());

        // 2. Get the target station's coordinates
        Station targetStation = stationRepository.findById(targetStationId)
                .orElseThrow(() -> new RuntimeException("Station not found: " + targetStationId));
        
        double sLat = stationService.parseCoordinate(targetStation.getLatitude());
        double sLon = stationService.parseCoordinate(targetStation.getLongitude());

        // 3. Calculate distance (in km)
        double distKm = stationService.calculateDistance(busLat, busLon, sLat, sLon);
        
        // 4. Calculate ETA assuming an average urban speed (e.g., 30 km/h for Sfax traffic)
        // Time = Distance / Speed. Multiply by 60 to convert hours to minutes.
        return Math.round((distKm / 30.0) * 60.0);
    }
}