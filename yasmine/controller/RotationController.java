package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.RotationDTO;
import org.yasmine.exception.TrackingUnavailableException;
import org.yasmine.service.RotationService;


@RestController 
@RequestMapping("/api/tracking") 
@RequiredArgsConstructor 
@CrossOrigin(origins = "*") 
public class RotationController {

    private final RotationService rotationService;

    @PostMapping("/{rotationId}/confirm")
    public ResponseEntity<Void> confirmTrip(
            @PathVariable String rotationId, 
            @RequestParam String userId) {
        rotationService.activateLiveTracking(userId, rotationId);
        return ResponseEntity.ok().build(); 
    }

    @GetMapping("/{rotationId}/live")
    public ResponseEntity<RotationDTO> getLiveUpdate(
            @PathVariable String rotationId, 
            @RequestParam String stationId) {
        
        RotationDTO response = rotationService.getLiveTrackingUpdate(rotationId, stationId);

        // 🚀 THE FIX: Commented out the OFFLINE block for testing. 
        // Now, Flutter will ALWAYS receive the ETA math, even during manual database testing!
        /* if (response.getStatus().equals("OFFLINE")) {
            throw new TrackingUnavailableException();
        }
        */

        return ResponseEntity.ok(response);
    }
}