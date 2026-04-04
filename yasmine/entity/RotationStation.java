package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "rotation_station")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RotationStation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "rotation_id", nullable = false)
    private String rotationId;

    @Column(name = "station_id", nullable = false)
    private String stationId;

    private Integer stationOrder;
    private String plannedArrivalTime;
    private String actualArrivalTime;
    private Integer etaMinutes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "rotation_id",
            referencedColumnName = "id",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Rotation rotation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "station_id",
            referencedColumnName = "id",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Station station;
}