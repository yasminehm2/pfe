package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Station;
import org.yasmine.repository.StationRepository;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MapService {
    private final StationRepository stationRepository;

    public List<Station> getMapMarkers(double userLat, double userLon) {
        // Retrieves stations to be displayed with AR/FR names 
        // This supports the "taps their preferred station" workflow 
        return stationRepository.findAll(); 
    }

    public double calculateDistanceToStation(double userLat, double userLon, Station station) {
        // Calculates the distance to display next to the station name 
        return 0.0;
    }
}