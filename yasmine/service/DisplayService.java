package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.DisplayInfo;
import org.yasmine.repository.DisplayInfoRepository;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DisplayService {
    private final DisplayInfoRepository displayInfoRepository;

    public List<DisplayInfo> getScheduleForStation(String stationId) {
        // Provides line numbers, destinations, and estimated waiting times [cite: 54, 55]
        return displayInfoRepository.findAll(); 
    }
}