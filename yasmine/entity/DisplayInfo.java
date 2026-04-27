package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity // Tells Java: "This class maps to a database table."
@Table(name = "display") // The database table is named "display".
@Data // Generates getters, setters, and other standard methods automatically.
@NoArgsConstructor // Creates an empty constructor.
@AllArgsConstructor // Creates a constructor with all fields.
@Builder // Allows for easy object creation: DisplayInfo.builder().lang("FR").build().
public class DisplayInfo {

    @Id // The Primary Key.
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Database will auto-increment this ID (1, 2, 3...).
    private Long id;

    private String lang; // The language of the text (e.g., "en", "fr", "ar").
    private String depart; // The "Departure" station name/label for display.
    private String arrivee; // The "Arrival" station name/label for display.
    private String vehicule; // The type or ID of the vehicle (e.g., "Bus 101").

    @Column(name = "detail_ligne") // Maps this Java field to the "detail_ligne" column.
    private String detailLigne; // Extra details about the line.

    private String ligne; // The name of the line.
    private String direction; // The direction the vehicle is heading (e.g., "Northbound").
    private String denumli; // The line number/ID as a string (e.g., "Line 5").
    private String deltyli; // Likely the "Type" of line (e.g., Express vs. Local).
    private String delagenc; // The name of the agency running this line.

    // 🚀 LINK TO STATION
    // Many different "DisplayInfos" can belong to one "Station".
    // Think: One physical station might have multiple signs/displays.
    @ManyToOne(fetch = FetchType.LAZY) 
    @JoinColumn(name = "station_id", referencedColumnName = "id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Station station;

    // 🚀 LINK TO LINE DETAILS
    // This links to the "Line" entity using the line number (denumli).
    // insertable/updatable = false makes this "Read-Only". 
    // We use the string "denumli" above to change data, and this object just to READ extra info.
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