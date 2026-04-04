package org.yasmine.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class StationResponseDTO {
    private String id;
    private String nameAr; // from delstat [cite: 64]
    private String nameFr; // from delstatfr [cite: 64]
    private double latitude;
    private double longitude;
    private double distanceKm; // Calculated distance from passenger 
}