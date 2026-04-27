package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.yasmine.dto.StationDTO;
import org.yasmine.entity.DisplayInfo;
import org.yasmine.entity.LineStation;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.Station;
import org.yasmine.entity.Vehicle;
import org.yasmine.repository.DisplayInfoRepository;
import org.yasmine.repository.LineStationRepository;
import org.yasmine.repository.RotationRepository;
import org.yasmine.repository.StationRepository;
import org.yasmine.repository.VehicleRepository;

import java.util.ArrayList;
import java.util.List;

@Service // Tells Spring: "This class handles the core logic for trips (rotations)."
@RequiredArgsConstructor // Automatically connects all the Repositories and Services listed below.
@Slf4j // Allows us to print warnings/info to the console.
public class RotationService {

    private final RotationRepository rotationRepository;
    private final VehicleRepository vehicleRepository;
    private final StationRepository stationRepository;
    private final StationService stationService;
    
    private final DisplayInfoRepository displayInfoRepository;
    private final LineStationRepository lineStationRepository;

    /**
     * 💡 LOGIC: "Get only the trips that are actually happening."
     */
    public List<Rotation> getActiveRotations() {
        return rotationRepository.findAll().stream()
                .filter(r -> !r.isCancelled()) 
                .toList();
    }

    /**
     * 💡 LOGIC: "The ETA Calculator (Single Stop)"
     */
    public double calculateDynamicETA(String rotationId, String targetStationId) {
        Vehicle vehicle = vehicleRepository.findByRotationId(rotationId).orElse(null);
        if (vehicle == null || vehicle.getNewlat() == null || vehicle.getNewlon() == null) {
            log.warn("Vehicle data missing for rotation: {}", rotationId);
            return 0.0; 
        }

        double busLat = stationService.parseCoordinate(vehicle.getNewlat());
        double busLon = stationService.parseCoordinate(vehicle.getNewlon());

        Station targetStation = stationRepository.findById(targetStationId)
                .orElseThrow(() -> new RuntimeException("Station not found: " + targetStationId));
        
        double sLat = stationService.parseCoordinate(targetStation.getLatitude());
        double sLon = stationService.parseCoordinate(targetStation.getLongitude());

        double distKm = stationService.calculateDistance(busLat, busLon, sLat, sLon);
        return Math.round((distKm / 30.0) * 60.0);
    }
    
    /**
     * 🚀 UPDATED LOGIC: "The Cumulative ETA Map (Using Start Baselines)"
     * Calculates the live ETA using total minutes from the start station.
     */
    public List<StationDTO> getFullItineraryWithLiveETAs(String rotationId) {
        
        // 1. Get the bus's live location
        Vehicle vehicle = vehicleRepository.findByRotationId(rotationId).orElse(null);
        boolean hasLiveBus = (vehicle != null && vehicle.getNewlat() != null);
        
        double busLat = hasLiveBus ? stationService.parseCoordinate(vehicle.getNewlat()) : 0;
        double busLon = hasLiveBus ? stationService.parseCoordinate(vehicle.getNewlon()) : 0;

        // 2. Get all stations for this trip
        Long displayId = Long.parseLong(rotationId);
        String lineId = displayInfoRepository.findById(displayId)
                .map(DisplayInfo::getDenumli).orElse(null);
                
        List<LineStation> itinerary = lineStationRepository.findByLineIdOrderByStationOrderAsc(lineId);
        if (itinerary.isEmpty()) return new ArrayList<>();

        // 3. Find the "Next Station" (the closest one in front of the bus)
        int nextStationIndex = 0;
        double shortestDistance = Double.MAX_VALUE;

        if (hasLiveBus) {
            for (int i = 0; i < itinerary.size(); i++) {
                Station s = itinerary.get(i).getStation();
                double dist = stationService.calculateDistance(busLat, busLon, 
                              stationService.parseCoordinate(s.getLatitude()), 
                              stationService.parseCoordinate(s.getLongitude()));
                if (dist < shortestDistance) {
                    shortestDistance = dist;
                    nextStationIndex = i;
                }
            }
        }

        // 4. Calculate Live ETA for the Next Station (using GPS)
        int liveEtaToNextStation = 0;
        if (hasLiveBus) {
            liveEtaToNextStation = (int) Math.round((shortestDistance / 30.0) * 60.0);
        }

        // 5. Establish the Schedule Baseline (Where is the next station on the timeline?)
        int nextStationBaseline = 0;
        if (nextStationIndex < itinerary.size() && itinerary.get(nextStationIndex).getMinutesFromStartStation() != null) {
            nextStationBaseline = itinerary.get(nextStationIndex).getMinutesFromStartStation();
        }

        // 6. Build the list to send to Flutter
        List<StationDTO> result = new ArrayList<>();
        
        for (int i = 0; i < itinerary.size(); i++) {
            LineStation ls = itinerary.get(i);
            Station s = ls.getStation();
            
            StationDTO dto = StationDTO.builder()
                    .id(s.getId())
                    .nameAr(s.getDelstat())
                    .nameFr(s.getDelstatfr())
                    .latitude(stationService.parseCoordinate(s.getLatitude()))
                    .longitude(stationService.parseCoordinate(s.getLongitude()))
                    .hasPassed(i < nextStationIndex) 
                    .build();

            // 7. Apply the Baseline Offset Math
            if (i < nextStationIndex) {
                dto.setLiveEtaMinutes(null); // Bus passed this stop
            } else if (i == nextStationIndex) {
                dto.setLiveEtaMinutes(liveEtaToNextStation); // Live GPS
            } else {
                // Figure out how long it takes to drive from the "Next Station" to "This Station"
                int currentStationBaseline = (ls.getMinutesFromStartStation() != null) ? ls.getMinutesFromStartStation() : 0;
                
                // Example: Stop 4 is at 20 mins. Stop 2 (Next Station) is at 5 mins. 
                // Travel time = 20 - 5 = 15 mins.
                int travelTimeFromNextStation = currentStationBaseline - nextStationBaseline;
                
                // Safety check: If database is missing info and math breaks, assume 3 mins per stop
                if (travelTimeFromNextStation <= 0) {
                    travelTimeFromNextStation = (i - nextStationIndex) * 3;
                }

                // Final ETA = Live GPS to next stop + scheduled travel time between them
                dto.setLiveEtaMinutes(liveEtaToNextStation + travelTimeFromNextStation);
            }
            
            result.add(dto);
        }

        return result;
    }
}