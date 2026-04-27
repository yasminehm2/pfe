package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service // Tells Spring: "This is a Service class that handles business logic."
@RequiredArgsConstructor // Automatically connects (injects) the StationService.
@Slf4j // Adds a logger (so you could print "Bus is near!" to the console).
public class ArrivalNotificationService {
    
    // We need the stationService to use its math skills (calculateDistance).
    private final StationService stationService;

    /**
     * 💡 LOGIC: "Should we send a notification?"
     * This method uses two different "checks" to decide if the bus is close.
     */
    public boolean shouldNotifyPassenger(double busLat, double busLon, double statLat, double statLon, double eta) {
        
        // 1. CHECK BY TIME (ETA):
        // If the "Estimated Time of Arrival" is between 0 and 1 minute, 
        // return 'true' (Yes, notify!).
        if (eta > 0 && eta <= 1.0) return true;

        // 2. CHECK BY DISTANCE:
        // If the time check didn't trigger, we check the actual physical distance.
        double distanceKm = stationService.calculateDistance(busLat, busLon, statLat, statLon);
        
        // 0.1 kilometers is exactly 100 meters.
        // If the bus is within 100 meters of the stop, return 'true'.
        return distanceKm <= 0.1; 
    }
}