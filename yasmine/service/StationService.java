package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.yasmine.dto.StationDTO;
import org.yasmine.entity.DisplayInfo;
import org.yasmine.entity.Station;
import org.yasmine.repository.DisplayInfoRepository;
import org.yasmine.repository.LineStationRepository;
import org.yasmine.repository.StationRepository;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service // Tells Spring: "This class manages the core logic for Stations."
@RequiredArgsConstructor // Connects all the Repositories automatically.
@Slf4j // Allows us to print error messages to the console.
public class StationService {

    private final StationRepository stationRepository;
    private final LineStationRepository lineStationRepository;
    private final DisplayInfoRepository displayInfoRepository;

    /**
     * 💡 LOGIC: "The Number Cleaner"
     * Database coordinates are often strings like "34,73". 
     * This turns them into a Java number (34.73) so we can do math.
     */
    public double parseCoordinate(String coord) {
        if (coord == null || coord.trim().isEmpty()) return 0.0;
        try {
            return Double.parseDouble(coord.replace(",", ".").trim());
        } catch (NumberFormatException e) {
            log.error("Failed to parse coordinate: {}", coord);
            return 0.0;
        }
    }

    /**
     * 💡 LOGIC: "The Text Cleaner"
     * Changes "Direction: Sfax-Sud" into just "Sud". 
     */
    public String formatDirectionAsArrival(String direction) {
        if (direction == null || direction.isBlank()) return "Terminus";
        String cleaned = direction.replaceAll("(?i)^(Direction|Vers|Ligne)[:\\s]*", "").trim();
        if (cleaned.contains("-")) {
            String[] parts = cleaned.split("-");
            cleaned = parts[parts.length - 1].trim();
        }
        return cleaned;
    }

    /**
     * 💡 LOGIC: "The Distance Calculator" (Haversine Formula)
     */
    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double earthRadius = 6371; 
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return earthRadius * (2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)));
    }

    /**
     * 💡 LOGIC: "What stops are near me?"
     */
    public List<StationDTO> getNearbyStations(double userLat, double userLon, double radius) {
        return stationRepository.findAll().stream()
                .map(station -> {
                    double sLat = parseCoordinate(station.getLatitude());
                    double sLon = parseCoordinate(station.getLongitude());
                    double distance = calculateDistance(userLat, userLon, sLat, sLon);
                    
                    if (distance <= radius) {
                        return StationDTO.builder()
                                .id(station.getId())
                                .nameAr(station.getDelstat())
                                .nameFr(station.getDelstatfr())
                                .latitude(sLat)
                                .longitude(sLon)
                                .distanceKm(distance)
                                .build();
                    }
                    return null;
                })
                .filter(Objects::nonNull) 
                .collect(Collectors.toList());
    }

    /**
     * 💡 LOGIC: "Show the full Route Map"
     * 🚀 UPDATED: Now includes minutesFromStartStation so Flutter can show 4, 9, 12 mins.
     */
    public List<StationDTO> getItineraryByRotation(String rotationId) {
        // 1. Look up the trip in the Display table to find the Line ID.
        Long id = Long.parseLong(rotationId);
        String lineId = displayInfoRepository.findById(id)
                .map(DisplayInfo::getDenumli) 
                .orElse(null);

        if (lineId == null) {
            log.warn("Could not find lineId for rotationId: {}", rotationId);
            return List.of();
        }

        // 2. Get all stations for that line and map them to DTOs including the DB timing.
        return lineStationRepository.findByLineIdOrderByStationOrderAsc(lineId).stream()
                .map(ls -> {
                    Station s = ls.getStation();
                    if (s == null) return null;
                    
                    return StationDTO.builder()
                            .id(s.getId())
                            .nameAr(s.getDelstat())
                            .nameFr(s.getDelstatfr())
                            .latitude(parseCoordinate(s.getLatitude()))
                            .longitude(parseCoordinate(s.getLongitude()))
                            // 🚀 THE FIX: Link the DB column value to the DTO
                            .minutesFromStartStation(ls.getMinutesFromStartStation()) 
                            .hasPassed(false) // Default status before tracking starts
                            .build();
                })
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }
}