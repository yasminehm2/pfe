package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ArrivalNotificationService {
    
    private final StationService stationService;

    public boolean shouldNotifyPassenger(double busLat, double busLon, double statLat, double statLon, double eta) {
        
        // 🚀 THE FIX: Changed 1.0 to 5.0 minutes to match your thesis requirements!
        if (eta > 0 && eta <= 5.0) return true;

        double distanceKm = stationService.calculateDistance(busLat, busLon, statLat, statLon);
        
        return distanceKm <= 0.1; 
    }
}