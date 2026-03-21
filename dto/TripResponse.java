package org.yasmine.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripResponse {
    private String id;
    private Integer deccent;
    private Integer decagenc;
    private String datedet;
    private String denumli;
    private String decstat;
    private Integer matric;
    private Integer matric1;
    private String hdeparte;
    private String harralle;
    private String rannul;
    private Double km;
    private String motifa;
}