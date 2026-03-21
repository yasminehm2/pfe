package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Station;
import org.yasmine.entity.Vehicle;

@Service
@RequiredArgsConstructor
public class AlertService {

    private final EtaService etaService;
    private final TrackingService trackingService;
    private final StationService stationService;

    public boolean shouldSendDepartureAlert(String tripId, String departureStationId) {
        long etaMinutes = etaService.estimateEtaToStationByDistance(tripId, departureStationId);
        boolean insideRadius = isBusInsideRadius(tripId, departureStationId, 100);
        return etaMinutes < 1 || insideRadius;
    }

    public boolean shouldSendArrivalAlert(String tripId, String arrivalStationId) {
        long etaMinutes = etaService.estimateEtaToStationByDistance(tripId, arrivalStationId);
        boolean insideRadius = isBusInsideRadius(tripId, arrivalStationId, 100);
        return etaMinutes < 1 || insideRadius;
    }

    public boolean isBusInsideRadius(String tripId, String stationId, double radiusMeters) {
        Vehicle vehicle = trackingService.getVehicleForTrip(tripId);
        Station station = stationService.getStationById(stationId);

        double vehicleLat = Double.parseDouble(vehicle.getNewlat().trim());
        double vehicleLon = Double.parseDouble(vehicle.getNewlon().trim());
        double stationLat = Double.parseDouble(station.getLatitude().trim());
        double stationLon = Double.parseDouble(station.getLongitude().trim());

        double distanceMeters = distanceKm(vehicleLat, vehicleLon, stationLat, stationLon) * 1000;
        return distanceMeters <= radiusMeters;
    }

    private double distanceKm(double lat1, double lon1, double lat2, double lon2) {
        final double earthRadius = 6371.0;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }
}