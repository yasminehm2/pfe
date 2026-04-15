package org.yasmine.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DisplayInfoDTO {
    private String id;
    private String lineNumber;     // denumli
    private String departureTime;  // Will be null if missing in DB
    private String arrivalTime;    // Will be null if missing in DB
    private String busPlate;       // vehicule
    private String departureStation;
    private String arrivalStation;
}