package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ArrivalNotificationService {

    public boolean shouldNotifyPassenger(double busLat, double busLon, double statLat, double statLon, double eta) {
        // Check if ETA < 1 min or distance < 100m radius [cite: 5]
        return eta < 1.0 || isWithinRadius(busLat, busLon, statLat, statLon, 0.1);
    }

    private boolean isWithinRadius(double lat1, double lon1, double lat2, double lon2, double radius) {
        // Logic to detect if the bus has entered the station radius [cite: 5]
        return false;
    }
}