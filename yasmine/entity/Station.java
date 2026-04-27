package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.ArrayList;
import java.util.List;

@Entity // Tells Java: "This class is a database table."
@Table(name = "station") // The table is named "station".
@Data // Automatically creates Getters, Setters, and toString.
@NoArgsConstructor // Empty constructor for JPA.
@AllArgsConstructor // Full constructor for all fields.
@Builder // Allows you to create objects easily (e.g., Station.builder().id("S1").build()).
public class Station {

    @Id // The unique Primary Key for this station (e.g., "STATION_001").
    private String id; // This matches the 'station_id' used in DisplayInfo and LineStation.

    private String delstat; // The name of the station (likely in the default language).
    private String delstatfr; // The name of the station in French.
    private String latitude; // GPS Coordinate: How far North/South the station is.
    private String longitude; // GPS Coordinate: How far East/West the station is.

    // 🔗 LINK TO LINESTATION
    // One station can appear on many different lines.
    // CascadeType.ALL means if you delete the station, the mapping records for its lines are deleted too.
    @OneToMany(mappedBy = "station", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<LineStation> lineStations = new ArrayList<>();


    // 🚀 BIDIRECTIONAL LINK TO DISPLAY INFO
    // This allows you to say: "Give me all the display screens/labels located at this specific station."
    @OneToMany(mappedBy = "station", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<DisplayInfo> displayInfos = new ArrayList<>();
}