package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.yasmine.entity.Station;
import org.yasmine.service.StationService;
import java.util.List;

@RestController
@RequestMapping("/api/map")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") 
public class MapController {
    private final StationService stationService;

    @GetMapping("/stations/nearby")
    public List<Station> getNearbyStations(@RequestParam double lat, @RequestParam double lon) {
        // Automatically display nearby stations based on device GPS 
        return stationService.getNearbyStations(lat, lon);
    }
}