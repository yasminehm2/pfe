package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.Station;
import org.yasmine.entity.Vehicle;

import java.time.Duration;
import java.time.LocalTime;

@Service
@RequiredArgsConstructor
public class EtaService {

    private final TripService tripService;
    private final TrackingService trackingService;
    private final StationService stationService;

    public long estimateEtaToTripArrival(String tripId) {
        Rotation rotation = tripService.getTripById(tripId);

        if (rotation.getHarralle() == null || rotation.getHarralle().isBlank()) {
            return -1;
        }

        LocalTime arrival = LocalTime.parse(rotation.getHarralle());
        LocalTime now = LocalTime.now();

        long minutes = Duration.between(now, arrival).toMinutes();
        return Math.max(minutes, 0);
    }

    public long estimateEtaToStationByDistance(String tripId, String stationId) {
        Vehicle vehicle = trackingService.getVehicleForTrip(tripId);
        Station station = stationService.getStationById(stationId);

        double vehicleLat = Double.parseDouble(vehicle.getNewlat().trim());
        double vehicleLon = Double.parseDouble(vehicle.getNewlon().trim());
        double stationLat = Double.parseDouble(station.getLatitude().trim());
        double stationLon = Double.parseDouble(station.getLongitude().trim());

        double distanceKm = distanceKm(vehicleLat, vehicleLon, stationLat, stationLon);

        double assumedAverageSpeedKmH = 30.0;
        double hours = distanceKm / assumedAverageSpeedKmH;

        return Math.max((long) Math.ceil(hours * 60), 0);
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