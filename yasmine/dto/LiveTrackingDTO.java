package org.yasmine.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LiveTrackingDTO {
    private String rotationId;
    private String lineNumber; // from denumli [cite: 55]
    private String destination; // from denomli [cite: 55]
    private double vehicleLat; // from newlat 
    private double vehicleLon; // from newlon 
    private double etaMinutes; // continuously recalculated 
    private String status; // moving/stopped/visible [cite: 9]
    private boolean arrivalAlert; // true if < 100m or < 1 min [cite: 5]
}