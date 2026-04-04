package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProximityAlertService {

    private final StationService stationService;

    public boolean shouldNotifyPassenger(double busLat, double busLon, double statLat, double statLon, double eta) {
        // Condition 1: ETA drops below 1 minute 
        if (eta > 0 && eta <= 1.0) return true;

        // Condition 2: Bus enters 100m (0.1km) station radius 
        double distanceKm = stationService.calculateDistance(busLat, busLon, statLat, statLon);
        return distanceKm <= 0.1;
    }
}