package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "display")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DisplayInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String lang;
    private String depart;
    private String arrivee;
    private String vehicule;

    @Column(name = "detail_ligne")
    private String detailLigne;

    private String ligne;
    private String direction;
    private String denumli; // The line number string
    private String deltyli;
    private String delagenc;

    // 🚀 LINK TO STATION
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "station_id", referencedColumnName = "id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Station station;

    // Read-only link to Line details
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "denumli",
            referencedColumnName = "denumli",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Line line;
}