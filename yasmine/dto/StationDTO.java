package org.yasmine.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StationDTO {

    private String id;
    private String nameAr;
    private String nameFr;
    private double latitude;
    private double longitude;
    private double distanceKm;
    
    // 🚀 THESE ARE THE MISSING FIELDS CAUSING THE RED ERRORS:
    private Integer minutesFromStartStation; 
    private Integer liveEtaMinutes; 
    private boolean hasPassed; 
}