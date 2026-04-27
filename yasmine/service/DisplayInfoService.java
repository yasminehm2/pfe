package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.dto.DisplayInfoDTO;
import org.yasmine.entity.DisplayInfo;
import org.yasmine.entity.Rotation;
import org.yasmine.repository.DisplayInfoRepository;
import org.yasmine.repository.LineStationRepository;
import org.yasmine.repository.RotationRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service // Tells Spring: "This class handles the business logic for Display Info."
@RequiredArgsConstructor // Automatically connects the Repositories and Services needed.
@Slf4j // Allows the code to print "logs" (status messages) to the console for debugging.
public class DisplayInfoService {

    private final DisplayInfoRepository displayInfoRepository;
    private final LineStationRepository lineStationRepository;
    private final StationService stationService;
    
    // 🚀 INJECT THE ROTATION REPOSITORY
    private final RotationRepository rotationRepository;

    /**
     * 💡 LOGIC: "Find all trips for a specific station."
     * This is a two-step "Bridge Search."
     */
    @Transactional(readOnly = true) // Optimization: Tells the database we are only reading, not changing data.
    public List<DisplayInfoDTO> getAvailableRotations(String stationId) {
        log.info("🔍 Bridge Search: Finding Line ID for station {}", stationId);

        // STEP 1: Find all Bus Lines that stop at this station.
        List<String> associatedLineIds = lineStationRepository.findByStationId(stationId).stream()
                .filter(ls -> ls.getLine() != null) // Make sure the line actually exists.
                .map(ls -> ls.getLine().getId())    // Get just the ID (e.g., "Line_5").
                .distinct()                         // Remove duplicates (if a line stops twice).
                .toList();

        // Safety check: If no buses stop here, return an empty list.
        if (associatedLineIds.isEmpty()) {
            log.warn("⚠️ No Line found for station {}", stationId);
            return List.of();
        }

        // STEP 2: Get all display information that matches those Line IDs.
        return displayInfoRepository.findAll().stream()
                .filter(info -> info.getDenumli() != null && associatedLineIds.contains(info.getDenumli()))
                .map(this::mapToDTO) // Convert the database "Entity" into a simple "DTO" for the frontend.
                .collect(Collectors.toList());
    }

    /**
     * 💡 LOGIC: "The Translator"
     * This takes a messy Database Entity and turns it into a clean "Data Transfer Object" (DTO)
     * that the mobile app (Flutter) can easily understand.
     */
    private DisplayInfoDTO mapToDTO(DisplayInfo entity) {
        boolean tripCancelled = false;

        // 🚀 IMPROVED CANCELLATION CHECK
        if (entity.getVehicule() != null) {
            Rotation currentRotation = rotationRepository
                    .findFirstByMatricOrderByIdDesc(entity.getVehicule())
                    .orElse(null);

            if (currentRotation != null) {
                // Check if boolean is true OR if the raw DB string 'rannul' is "1"
                if (currentRotation.isCancelled() || "1".equals(currentRotation.getRannul())) {
                    tripCancelled = true;
                }
            }
        }

        return DisplayInfoDTO.builder()
                .id(entity.getId().toString())
                .lineNumber(entity.getDenumli())
                .busPlate(entity.getVehicule())
                .departureStation(entity.getDepart())
                .arrivalStation(stationService.formatDirectionAsArrival(entity.getDirection()))
                .departureTime(entity.getDepart()) 
                .arrivalTime(entity.getArrivee())
                .isCancelled(tripCancelled) 
                .build();
    }
}