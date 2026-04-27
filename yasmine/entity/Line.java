package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity // Tells Java: "This class is a database table."
@Table(name = "line") // The table name is "line".
@Data // Automatically adds getters, setters, etc.
@NoArgsConstructor // Empty constructor.
@AllArgsConstructor // Full constructor.
@Builder // Allows for building objects piece by piece.
public class Line {

    @Id // The unique ID for this specific line record.
    private String id;

    private Integer deccent; // Link to the Center ID.
    private Integer decagenc; // Link to the Agency ID.

    @Column(unique = true, nullable = false)
    private String denumli; // The official Line Number (e.g., "10A"). Must be unique!

    private String denomli; // The official Name of the line (e.g., "Downtown - Airport").
    private Integer denbrkm; // The length of the line in Kilometers.
    private String statlig; // Status of the line (e.g., "A" for Active).
    private String lig; // A short code or internal shorthand for the line.

    // 1. LINK TO AGENCY (Parent)
    // Many lines belong to one Agency. 
    // It's "read-only" (insertable/updatable = false) because we use the Integer field above to save.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "decagenc",
            referencedColumnName = "decagenc",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Agency agency;

    // 2. LINK TO ROTATIONS (Children)
    // One line has many "Rotations" (schedules/trips). 
    // CascadeType.ALL means if you delete the Line, its rotations are deleted too.
    @OneToMany(mappedBy = "line", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<LineRot> lineRots = new ArrayList<>();

    // 3. LINK TO STATIONS (Children)
    // One line passes through many stations. 
    @OneToMany(mappedBy = "line", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<LineStation> lineStations = new ArrayList<>();

    // 4. LINK TO DISPLAY INFO (Children)
    // One line can have multiple display labels (different languages/formats).
    @OneToMany(mappedBy = "line", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<DisplayInfo> displayInfos = new ArrayList<>();

    // HELPER METHODS (Logic)

    // Checks if the line is "Active" (assuming 'A' means Active).
    public boolean isActive() {
        return statlig != null && statlig.equalsIgnoreCase("A");
    }

    // Combines the number and name for an easy-to-read label (e.g., "10A - Downtown").
    public String getFullName() {
        String number = denumli != null ? denumli : "";
        String name = denomli != null ? denomli : "";
        return number + " - " + name;
    }

    // Simple shortcut to get the line number.
    public String getLineNumber() {
        return denumli;
    }
}