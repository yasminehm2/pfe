package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity // Tells Java: "This class is a database table."
@Table(name = "line_station") // The table is named "line_station".
@Data // Automatically creates Getters, Setters, etc.
@NoArgsConstructor // Empty constructor.
@AllArgsConstructor // Full constructor.
@Builder // Allows you to build objects easily.
public class LineStation {

    @Id // The unique Primary Key for this specific row.
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "line_id", nullable = false)
    private String lineId;

    @Column(name = "station_id", nullable = false)
    private String stationId;

    @Column(name = "station_order") 
    // 💡 IMPORTANT: This tells us the sequence (e.g., 1st stop, 2nd stop, 3rd stop).
    private Integer stationOrder;

    // 🚀 UPDATED: How many total minutes from the FIRST station on the line to this one?
    // (For the 1st station, this will be 0. For the 2nd it might be 5. For the 3rd, 12, etc.)
    @Column(name = "minutes_from_start")
    private Integer minutesFromStartStation;

    // 🔗 LINK TO LINE
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

    // 🔗 LINK TO STATION
    @ManyToOne(fetch = FetchType.EAGER) 
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