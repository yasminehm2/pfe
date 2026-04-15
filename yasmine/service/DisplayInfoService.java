package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.DisplayInfo;
import org.yasmine.repository.DisplayInfoRepository;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DisplayInfoService {
    private final DisplayInfoRepository displayInfoRepository;

    public List<DisplayInfo> getRawDisplayData(String stationId) {
        return displayInfoRepository.findByStationId(stationId);
    }
}