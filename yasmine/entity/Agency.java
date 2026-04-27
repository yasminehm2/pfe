package org.yasmine.entity;

import jakarta.persistence.*; // Tools to connect Java to Database tables
import lombok.*; // Tools to automatically write "boring" code (like Getters/Setters)

import java.util.ArrayList;
import java.util.List;

@Entity // Tells Java: "This class represents a table in the database."
@Table(name = "agency") // Sets the actual name of the database table to "agency".
@Data // Lombok: Automatically creates Getters, Setters, and toString() methods.
@NoArgsConstructor // Lombok: Creates an empty constructor (needed by Java).
@AllArgsConstructor // Lombok: Creates a constructor with all fields.
@Builder // Lombok: Allows you to create objects easily (e.g., Agency.builder().id("1").build()).
public class Agency {

    @Id // Marks this as the Primary Key (the unique ID for every agency).
    private String id;

    @Column(nullable = false, unique = true) // This column cannot be empty and must be unique.
    private Integer decagenc; // likely "Agency Code"

    @Column(nullable = false) // This column cannot be empty.
    private String delagenc; // likely "Agency Name/Label"

    @Column(nullable = false) // This column cannot be empty.
    private Integer deccent; // The ID of the Center this agency belongs to.

    // RELATIONSHIP: Many Agencies belong to one Center.
    @ManyToOne(fetch = FetchType.LAZY) // Lazy means "don't load center data until I specifically ask for it" (saves memory).
    @JoinColumn(
            name = "deccent", // The name of the column in this table.
            referencedColumnName = "deccent", // The name of the column it points to in the Center table.
            insertable = false, // We use the Integer field above to save, so this relationship is "read-only".
            updatable = false
    )
    @ToString.Exclude // Prevents an infinite loop when printing the object.
    @EqualsAndHashCode.Exclude // Prevents errors when comparing objects.
    private Center center; // The actual Center object linked to this agency.

    // RELATIONSHIP: One Agency can have many Lines (like bus lines or train lines).
    @OneToMany(mappedBy = "agency", fetch = FetchType.LAZY) // Points to the "agency" field in the Line class.
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default // Ensures the list isn't null if you use the Builder pattern.
    private List<Line> lines = new ArrayList<>(); // A list of all lines belonging to this agency.
}