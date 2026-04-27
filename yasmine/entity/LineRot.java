package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity // Tells Java: "This class maps to a database table."
@Table(name = "line_rot") // The table is named "line_rot".
// 🚀 KEY CONCEPT: This tells JPA that the ID isn't a single field, 
// but a combination of fields defined in a separate class called LineRotId.
@IdClass(LineRotId.class) 
@Data // Automatically creates getters/setters.
@NoArgsConstructor // Empty constructor.
@AllArgsConstructor // Full constructor.
@Builder // For easy object building.
public class LineRot {

    @Id // Part 1 of the Composite Primary Key.
    private String lineId;

    @Id // Part 2 of the Composite Primary Key.
    private String rotationId;

    private Integer deccent; // Link to the Center ID.
    private Integer decagenc; // Link to the Agency ID.
    private String denumli; // The line number string (e.g., "Line 5").

    // 🔗 LINK TO LINE
    // This connects this row to the actual 'Line' object.
    // We set insertable/updatable to false because the 'lineId' field above 
    // is the one that actually saves the data to the database.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "lineId",
            referencedColumnName = "id",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Line line;

    // 🔗 LINK TO ROTATION
    // This connects this row to the actual 'Rotation' (Schedule) object.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "rotationId",
            referencedColumnName = "id",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Rotation rotation;
}