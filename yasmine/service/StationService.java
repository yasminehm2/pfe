package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.yasmine.dto.StationResponseDTO;
import org.yasmine.entity.DisplayInfo;
import org.yasmine.entity.Station;
import org.yasmine.repository.DisplayInfoRepository;
import org.yasmine.repository.LineRotRepository;
import org.yasmine.repository.LineStationRepository;
import org.yasmine.repository.StationRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class StationService {

    private final StationRepository stationRepository;
    private final LineRotRepository lineRotRepository;
    private final LineStationRepository lineStationRepository;
    private final DisplayInfoRepository displayInfoRepository;

    /**
     * ✅ FIX FOR RotationService: Converts String coordinates (with commas) to double
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
     * ✅ FIX FOR TrackingService: Cleans the direction string for display
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
     * Haversine formula for distance calculation
     */
    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double earthRadius = 6371; // km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return earthRadius * (2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)));
    }

    public List<StationResponseDTO> getNearbyStations(double userLat, double userLon, double radius) {
        return stationRepository.findAll().stream()
                .map(station -> {
                    double sLat = parseCoordinate(station.getLatitude());
                    double sLon = parseCoordinate(station.getLongitude());
                    double distance = calculateDistance(userLat, userLon, sLat, sLon);
                    
                    if (distance <= radius) {
                        return StationResponseDTO.builder()
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
                .filter(dto -> dto != null)
                .collect(Collectors.toList());
    }

    public List<StationResponseDTO> getItineraryByRotation(String rotationId) {
        // 1. Find the trip in the display table by its ID (e.g., 4) to get its Line Name (L1)
        String lineId = displayInfoRepository.findById(Long.parseLong(rotationId))
                .map(DisplayInfo::getDenumli) // Gets 'L1'
                .orElse(null);

        if (lineId == null) return List.of();

        // 2. Return all stations mapped to 'L1' in line_station table
        return lineStationRepository.findByLineIdOrderByStationOrderAsc(lineId).stream()
                .map(ls -> StationResponseDTO.builder()
                        .id(ls.getStation().getId())
                        .nameAr(ls.getStation().getDelstat())
                        .nameFr(ls.getStation().getDelstatfr())
                        .latitude(parseCoordinate(ls.getStation().getLatitude()))
                        .longitude(parseCoordinate(ls.getStation().getLongitude()))
                        .build())
                .collect(Collectors.toList());
    }
}