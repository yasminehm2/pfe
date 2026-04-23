package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.dto.DisplayInfoDTO;
import org.yasmine.entity.DisplayInfo;
import org.yasmine.repository.DisplayInfoRepository;
import org.yasmine.repository.LineStationRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DisplayInfoService {

    private final DisplayInfoRepository displayInfoRepository;
    private final LineStationRepository lineStationRepository;
    private final StationService stationService;

    /**
     * 🚀 SHARED LINE LOGIC: 
     * Finds trips for the entire line that the tapped station belongs to.
     */
    @Transactional(readOnly = true)
    public List<DisplayInfoDTO> getAvailableRotations(String stationId) {
        log.info("🔍 Bridge Search: Finding Line ID for station {}", stationId);

        List<String> associatedLineIds = lineStationRepository.findByStationId(stationId).stream()
                .filter(ls -> ls.getLine() != null)
                .map(ls -> ls.getLine().getId()) 
                .distinct()
                .toList();

        if (associatedLineIds.isEmpty()) {
            log.warn("⚠️ No Line found for station {}", stationId);
            return List.of();
        }

        return displayInfoRepository.findAll().stream()
                .filter(info -> info.getDenumli() != null && associatedLineIds.contains(info.getDenumli()))
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    private DisplayInfoDTO mapToDTO(DisplayInfo entity) {
        return DisplayInfoDTO.builder()
                .id(entity.getId().toString())
                .lineNumber(entity.getDenumli()) 
                .busPlate(entity.getVehicule())   
                .departureStation(entity.getDepart())
                .arrivalStation(stationService.formatDirectionAsArrival(entity.getDirection()))
                .departureTime(entity.getDepart())
                .arrivalTime(entity.getArrivee())
                .build();
    }
}