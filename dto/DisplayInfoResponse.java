package org.yasmine.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DisplayInfoResponse {
    private Long id;
    private String lang;
    private String depart;
    private String arrivee;
    private String vehicule;
    private String detailLigne;
    private String ligne;
    private String direction;
    private String denumli;
    private String deltyli;
    private String delagenc;
}