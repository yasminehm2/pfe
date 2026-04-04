package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Rotation;
import org.yasmine.repository.RotationRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LiveTrackingScheduler {

    private final RotationRepository rotationRepository;
    private final ETAService etaService;

    // Updates internal ETA values every 10 seconds 
    @Scheduled(fixedRate = 10000)
    public void updateAllLiveEtas() {
        // Retrieve active trips from deprotat [cite: 7]
        List<Rotation> activeRotations = rotationRepository.findAll().stream()
                .filter(r -> !r.isCancelled()) // Check rannul != '1' [cite: 7]
                .toList();

        for (Rotation rotation : activeRotations) {
            // Intelligent Processing: Recalculate ETA for the target station [cite: 4, 26]
            // We save the value to the DB so the Controller can find it during Polling
            etaService.updateRotationETAs(rotation); 
        }
    }
}