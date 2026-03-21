package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Station;
import org.yasmine.repository.StationRepository;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class StationService {

    private final StationRepository stationRepository;

    public List<Station> getAllStations() {
        return stationRepository.findAll();
    }

    public Station getStationById(String id) {
        return stationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Station not found with id: " + id));
    }

    public List<Station> getNearbyStations(double userLat, double userLon, double radiusKm) {
        return stationRepository.findAll()
                .stream()
                .filter(station -> {
                    double distance = distanceKm(
                            userLat,
                            userLon,
                            Double.parseDouble(station.getLatitude().trim()),
                            Double.parseDouble(station.getLongitude().trim())
                    );
                    return distance <= radiusKm;
                })
                .sorted(Comparator.comparingDouble(station ->
                        distanceKm(
                                userLat,
                                userLon,
                                Double.parseDouble(station.getLatitude().trim()),
                                Double.parseDouble(station.getLongitude().trim())
                        )
                ))
                .toList();
    }

    public double distanceToStation(double userLat, double userLon, String stationId) {
        Station station = getStationById(stationId);
        return distanceKm(
                userLat,
                userLon,
                Double.parseDouble(station.getLatitude().trim()),
                Double.parseDouble(station.getLongitude().trim())
        );
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