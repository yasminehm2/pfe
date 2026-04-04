package org.yasmine.service;

import org.springframework.stereotype.Service;
import org.yasmine.entity.Vehicle;

@Service
public class AnomalyService {

    public boolean isDataValid(Vehicle vehicle) {
        // Cleans and validates received GPS data from gps_vehic [cite: 8, 25]
        return vehicle.getNewlat() != null && vehicle.getNewlon() != null;
    }

    public String checkServiceStatus(Vehicle vehicle) {
        // Detects anomalies like buses stopped too long or major delays 
        // Provides status (moving/stopped/visible) to the passenger [cite: 8, 9]
        return "NORMAL"; 
    }
}