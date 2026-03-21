package org.yasmine.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrackingResponse {
    private String matvehicule;
    private String newlat;
    private String newlon;
    private String lastlat;
    private String lastlon;
    private String visible;
}