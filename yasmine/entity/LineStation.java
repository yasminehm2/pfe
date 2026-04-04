package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "line_station")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LineStation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "line_id", nullable = false)
    private String lineId;

    @Column(name = "station_id", nullable = false)
    private String stationId;

    private Integer stationOrder;
    private Double distanceFromOrigin;
    private String direction;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "line_id",
            referencedColumnName = "id",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Line line;

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