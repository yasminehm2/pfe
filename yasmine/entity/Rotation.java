package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity // Tells Java: "This is a database table."
@Table(name = "deprotat") // The actual table name in your database is "deprotat".
@Data // Automatically adds getters, setters, and toString.
@NoArgsConstructor // Empty constructor for JPA.
@AllArgsConstructor // Full constructor for all fields.
@Builder // Allows you to create objects like Rotation.builder().id("R1").build().
public class Rotation {

    @Id // The unique ID for this specific trip/rotation.
    private String id;

    private Integer deccent; // Link to Center ID.
    private Integer decagenc; // Link to Agency ID.
    private String datedet; // The date of the trip.
    private String denumli; // The line number this trip belongs to.
    private String decstat; // The status code of the rotation.

    private String matric; // The license plate/ID of the vehicle assigned to this trip.

    private String hdeparte; // Departure time (e.g., "09:00").
    private String harralle; // Arrival time (e.g., "09:45").
    private String rannul; // Cancellation flag (if it's "1", the trip is cancelled).
    private Double km; // Total kilometers driven for this trip.


    // 🔗 LINK TO VEHICLE
    // Connects this trip to a specific Vehicle object.
    // Read-only (insertable=false) because we use the 'matric' string above to save data.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "matric",
            referencedColumnName = "matvehicule",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Vehicle vehicle;

    // 🔗 LINK TO LINE_ROT (Mapping)
    // Connects this rotation to the Line through the join table we saw earlier.
    @OneToMany(mappedBy = "rotation", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<LineRot> lineRots = new ArrayList<>();

    // 🔗 LINK TO USERS
    // A list of users who have "chosen" or are assigned to this specific trip.
    @OneToMany(mappedBy = "chosenRotation", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<User> users = new ArrayList<>();

    // HELPER METHODS (Logic)

    // Check if the trip is cancelled.
    // It checks if 'rannul' is "1".
    public boolean isCancelled() {
        return rannul != null && rannul.trim().equals("1");
    }

    // If it's not cancelled, we assume it is "In Progress" or active.
    public boolean isInProgress() {
        return !isCancelled();
    }

}