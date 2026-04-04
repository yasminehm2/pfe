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
    private String denumli;
    private String deltyli;
    private String delagenc;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "station_id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Station station;

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