package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.dto.DisplayInfoDTO;
import org.yasmine.entity.*;
import org.yasmine.repository.*;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TrackingService {
    private final DisplayInfoRepository displayInfoRepository;
    private final StationService stationService;
    private final UserRepository userRepository;
    private final RotationRepository rotationRepository;
    private final VehicleRepository vehicleRepository;
    private final LineStationRepository lineStationRepository;

    /**
     * Finds trips shared by all stations on the same line.
     */
    @Transactional(readOnly = true)
    public List<DisplayInfoDTO> getAvailableRotations(String stationId) {
        // 1. Identify which Line ID(s) this station belongs to (e.g., 'L1')
        List<String> associatedLineIds = lineStationRepository.findAll().stream()
                .filter(ls -> ls.getStation() != null && ls.getStation().getId().equals(stationId))
                .filter(ls -> ls.getLine() != null)
                .map(ls -> ls.getLine().getId()) // Returns 'L1'
                .distinct()
                .toList();

        if (associatedLineIds.isEmpty()) return List.of();

        // 2. Fetch all trips from 'display' where denumli matches the found Line IDs
        return displayInfoRepository.findAll().stream()
                .filter(info -> info.getDenumli() != null && associatedLineIds.contains(info.getDenumli())) 
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    private DisplayInfoDTO mapToDTO(DisplayInfo entity) {
        return DisplayInfoDTO.builder()
                .id(entity.getId().toString())
                .lineNumber(entity.getDenumli()) // e.g., 'L1'
                .busPlate(entity.getVehicule())
                .departureStation(entity.getDepart())
                .departureTime(entity.getDepart()) // Map from 'depart' column
                .arrivalTime(entity.getArrivee())   // Map from 'arrivee' column
                .arrivalStation(stationService.formatDirectionAsArrival(entity.getDirection()))
                .build();
    }
}