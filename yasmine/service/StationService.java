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
     * Converts String coordinates (potentially with commas) to double.
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
     * Cleans direction strings (e.g., "Direction: Sfax-Sud") for the UI.
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
     * Haversine formula for distance calculation in kilometers.
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

    /**
     * Retrieves the sequence of stops for a trip ID from the display table.
     * Maps: Display ID (e.g., 4) -> Line Name (L1) -> Line Stations.
     */
    public List<StationResponseDTO> getItineraryByRotation(String rotationId) {
        Long id = Long.parseLong(rotationId);
        String lineId = displayInfoRepository.findById(id)
                .map(DisplayInfo::getDenumli) 
                .orElse(null);

        if (lineId == null) return List.of();

        return lineStationRepository.findByLineIdOrderByStationOrderAsc(lineId).stream()
                .map(ls -> {
                    // This 'getStation()' now works because of the EAGER fetch
                    Station s = ls.getStation();
                    if (s == null) return null;
                    
                    return StationResponseDTO.builder()
                            .id(s.getId())
                            .nameAr(s.getDelstat())   // Arabic name from DB
                            .nameFr(s.getDelstatfr()) // French name from DB
                            .latitude(parseCoordinate(s.getLatitude()))
                            .longitude(parseCoordinate(s.getLongitude()))
                            .build();
                })
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());
    }
    }
