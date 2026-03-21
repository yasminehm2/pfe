package org.yasmine.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NearbyStationResponse {
    private String id;
    private String delstat;
    private String delstatfr;
    private String latitude;
    private String longitude;
    private double distanceKm;
}