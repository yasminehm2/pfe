package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.RotationStation;
import org.yasmine.entity.Vehicle;
import org.yasmine.repository.RotationStationRepository;
import org.yasmine.repository.VehicleRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ETAService {

    private final StationService stationService;
    private final RotationStationRepository rotationStationRepository;
    private final VehicleRepository vehicleRepository; // Injected to fix the error

    /**
     * Recalculates ETAs for all stops in a rotation using live GPS.
     */
    @Transactional
    public void updateRotationETAs(Rotation rotation) {
        // Fetch vehicle using the corrected repository method
        Vehicle vehicle = vehicleRepository.findByRotationId(rotation.getId()).orElse(null);
        
        if (vehicle == null || vehicle.getNewlat() == null || vehicle.getNewlon() == null) {
            return;
        }

        double busLat = Double.parseDouble(vehicle.getNewlat()); //
        double busLon = Double.parseDouble(vehicle.getNewlon()); //

        List<RotationStation> stops = rotationStationRepository
                .findByRotationIdOrderByStationOrderAsc(rotation.getId());

        for (RotationStation stop : stops) {
            double statLat = Double.parseDouble(stop.getStation().getLatitude());
            double statLon = Double.parseDouble(stop.getStation().getLongitude());

            double distance = stationService.calculateDistance(busLat, busLon, statLat, statLon);
            
            // ETA based on 30 km/h average speed in Sfax traffic
            int eta = (int) ((distance / 30.0) * 60);
            
            stop.setEtaMinutes(eta);
            rotationStationRepository.save(stop);
        }
    }

    /**
     * Fetches a single dynamic ETA for the TrackingController.
     */
    public double calculateDynamicETA(String rotationId, String stationId) {
        return rotationStationRepository.findByRotationIdOrderByStationOrderAsc(rotationId).stream()
                .filter(rs -> rs.getStation().getId().equals(stationId))
                .findFirst()
                .map(rs -> (double) rs.getEtaMinutes())
                .orElse(0.0);
    }
}