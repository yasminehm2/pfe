package org.yasmine.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ArrivalAlertRequest {

    @NotBlank
    private String tripId;

    @NotBlank
    private String departureStationId;

    @NotBlank
    private String arrivalStationId;
}