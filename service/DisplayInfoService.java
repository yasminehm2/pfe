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

    public List<DisplayInfo> getAllDisplayInfo() {
        return displayInfoRepository.findAll();
    }

    public DisplayInfo getDisplayInfoById(Long id) {
        return displayInfoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Display info not found with id: " + id));
    }

    public List<DisplayInfo> getDisplayInfoByLineNumber(String denumli) {
        return displayInfoRepository.findAll()
                .stream()
                .filter(displayInfo -> denumli.equals(displayInfo.getDenumli()))
                .toList();
    }

    public DisplayInfo saveDisplayInfo(DisplayInfo displayInfo) {
        return displayInfoRepository.save(displayInfo);
    }

    public void deleteDisplayInfo(Long id) {
        displayInfoRepository.deleteById(id);
    }
}