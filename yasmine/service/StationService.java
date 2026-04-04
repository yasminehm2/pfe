package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Station;
import org.yasmine.repository.StationRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class StationService {

    private final StationRepository stationRepository;

    public List<Station> getNearbyStations(double userLat, double userLon) {
        return stationRepository.findAll().stream()
                .filter(s -> {
                    try {
                        // Null/Empty check for Strings from SQL
                        if (s.getLatitude() == null || s.getLongitude() == null || 
                            s.getLatitude().isBlank() || s.getLongitude().isBlank()) {
                            return false;
                        }

                        double sLat = Double.parseDouble(s.getLatitude());
                        double sLon = Double.parseDouble(s.getLongitude());

                        // Calculate distance and filter by 2km
                        return calculateDistance(userLat, userLon, sLat, sLon) <= 2.0;

                    } catch (NumberFormatException e) {
                        log.warn("Skipping station {} due to invalid coordinates", s.getId());
                        return false;
                    }
                })
                .collect(Collectors.toList());
    }

    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double earthRadius = 6371; // km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }
}