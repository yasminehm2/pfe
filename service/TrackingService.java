package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.Vehicle;
import org.yasmine.repository.VehicleRepository;

@Service
@RequiredArgsConstructor
public class TrackingService {

    private final VehicleRepository vehicleRepository;
    private final TripService tripService;

    public Vehicle getVehicleById(String matvehicule) {
        return vehicleRepository.findById(matvehicule)
                .orElseThrow(() -> new RuntimeException("Vehicle not found with id: " + matvehicule));
    }

    public Vehicle getVehicleForTrip(String tripId) {
        Rotation rotation = tripService.getTripById(tripId);
        return getVehicleById(String.valueOf(rotation.getMatric()));
    }

    public boolean isVehicleVisible(String matvehicule) {
        Vehicle vehicle = getVehicleById(matvehicule);
        return "1".equals(vehicle.getVisible());
    }

    public boolean hasValidPosition(String matvehicule) {
        Vehicle vehicle = getVehicleById(matvehicule);
        return vehicle.getNewlat() != null
                && vehicle.getNewlon() != null
                && !"0.0".equals(vehicle.getNewlat())
                && !"0.0".equals(vehicle.getNewlon());
    }
}