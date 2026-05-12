package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "line_station")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
// 🚀 NEW: Tells JPA to use our custom class as the composite primary key
@IdClass(LineStationId.class) 
public class LineStation {

    // 🚀 NEW: This is now part 1 of the Primary Key
    @Id 
    @Column(name = "line_id", nullable = false)
    private String lineId;

    // 🚀 NEW: This is now part 2 of the Primary Key
    @Id 
    @Column(name = "station_id", nullable = false)
    private String stationId;

    @Column(name = "station_order") 
    // 💡 IMPORTANT: This tells us the sequence (e.g., 1st stop, 2nd stop, 3rd stop).
    private Integer stationOrder;

    // 🚀 UPDATED: How many total minutes from the FIRST station on the line to this one?
    @Column(name = "minutes_from_start")
    private Integer minutesFromStartStation;

    // 🔗 LINK TO LINE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "line_id",
            referencedColumnName = "id",
            insertable = false, // Must be false because the field is already an @Id above
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Line line;

    // 🔗 LINK TO STATION
    @ManyToOne(fetch = FetchType.EAGER) 
    @JoinColumn(
            name = "station_id",
            referencedColumnName = "id",
            insertable = false, // Must be false because the field is already an @Id above
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Station station;
}