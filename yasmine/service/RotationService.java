package org.yasmine.service;

import lombok.RequiredArgsConstructor;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.Vehicle;
import org.yasmine.repository.RotationRepository;
import org.yasmine.entity.RotationStation; // ✅ Added import
import org.yasmine.repository.RotationStationRepository; // ✅ Added import
import org.yasmine.repository.VehicleRepository;

import jakarta.transaction.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RotationService {
    private final RotationRepository rotationRepository;
    private final RotationStationRepository rotationStationRepository;
    private final VehicleRepository vehicleRepository;
    private final StationService stationService;

    public List<Rotation> getActiveRotations() {
        return rotationRepository.findAll().stream()
                .filter(r -> !r.isCancelled())
                .toList();
    }
    
    @Transactional
    public void updateRotationETAs(Rotation rotation) {
        Vehicle vehicle = vehicleRepository.findByRotationId(rotation.getId()).orElse(null);
        if (vehicle == null || vehicle.getNewlat() == null) return;

        double busLat = stationService.parseCoordinate(vehicle.getNewlat());
        double busLon = stationService.parseCoordinate(vehicle.getNewlon());

        List<RotationStation> stops = rotationStationRepository.findByRotationIdOrderByStationOrderAsc(rotation.getId());
        for (RotationStation stop : stops) {
            double sLat = stationService.parseCoordinate(stop.getStation().getLatitude());
            double sLon = stationService.parseCoordinate(stop.getStation().getLongitude());
            
            double dist = stationService.calculateDistance(busLat, busLon, sLat, sLon);
            int eta = (int) ((dist / 30.0) * 60); // 30km/h avg
            stop.setEtaMinutes(eta);
            rotationStationRepository.save(stop);
        }
    }

    @Scheduled(fixedRate = 10000)
    public void runLiveUpdateTask() {
        rotationRepository.findAll().stream()
            .filter(r -> !r.isCancelled())
            .forEach(this::updateRotationETAs);
    }
}