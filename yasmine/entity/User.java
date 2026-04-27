package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity // Tells Java: "This class maps to a 'users' table in the database."
@Table(name = "users") // The table is named "users".
@Data // Automatically adds Getters, Setters, and toString.
@NoArgsConstructor // Empty constructor (needed for JPA).
@AllArgsConstructor // Constructor for all fields.
@Builder // Lets you create users easily: User.builder().email("test@mail.com").build().
public class User {

    @Id // The unique ID for the user (could be a UUID or a string ID).
    private String id;

    private String name; // The user's full name.

    @Column(unique = true, nullable = false) // Email must be unique and cannot be empty.
    private String email;

    @Column(nullable = false) // Password is required.
    private String password; // Note: This should be a hashed (encrypted) string!

    // GPS coordinates for the user's current live location.
    private double lat; 
    private double lon;

    @Enumerated(EnumType.STRING) 
    // 💡 IMPORTANT: This stores the role (ADMIN, DRIVER, PASSENGER) as a string 
    // in the database (e.g., "DRIVER") instead of a number.
    private UserRole role;

    // 🔗 LINK TO ROTATION
    // This connects the user to a specific trip.
    // If a driver is "on the clock," this would be the trip they are driving.
    // If a passenger is "tracking" a bus, this is the trip they are watching.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rotation_id") // The column in the 'users' table that stores the Rotation ID.
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Rotation chosenRotation;
}