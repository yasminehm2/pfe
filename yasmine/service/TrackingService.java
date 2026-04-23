package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.entity.User;
import org.yasmine.entity.Vehicle;
import org.yasmine.repository.DisplayInfoRepository;
import org.yasmine.repository.UserRepository;
import org.yasmine.repository.VehicleRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class TrackingService {

    private final DisplayInfoRepository displayInfoRepository;
    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;

    /**
     * 📡 LIVE POSITION LOOKUP:
     * Maps: Trip ID -> Bus Plate -> GPS Data.
     */
    public Vehicle getLiveBusPosition(String rotationId) {
        return displayInfoRepository.findById(Long.parseLong(rotationId))
                .map(display -> vehicleRepository.findById(display.getVehicule()).orElse(null))
                .orElse(null);
    }

    /**
     * ✅ GUEST-FRIENDLY ACTIVATION:
     */
    @Transactional
    public void activateLiveTracking(String userId, String rotationId) {
        if (userId != null && userId.startsWith("GUEST-")) {
            log.info("🚀 Guest session tracking trip ID: {}", rotationId);
            return; 
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
        
        log.info("👤 Registered User {} tracking trip ID: {}", userId, rotationId);
    }
}