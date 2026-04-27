package org.yasmine.entity;

import jakarta.persistence.*; // Tools to map this Java class to a database table
import lombok.*; // Tools to skip writing getters/setters manually

import java.util.ArrayList;
import java.util.List;

@Entity // Tells Spring: "Treat this class as a database table"
@Table(name = "center") // The table in your database will be named "center"
@Data // Automatically generates getters, setters, and toString()
@NoArgsConstructor // Creates an empty constructor (needed for JPA)
@AllArgsConstructor // Creates a constructor for all fields
@Builder // Lets you create objects easily: Center.builder().id("C1").build()
public class Center {

    @Id // The unique "Primary Key" for this record
    private String id;

    @Column(nullable = false, unique = true) // Cannot be empty and no two centers can have the same number
    private Integer deccent; // Likely "Center Code" (the unique ID used in relationships)

    @Column(nullable = false) // This name is required
    private String delcent; // Likely "Center Name" or "Label"

    private String deadrce; // Likely "Address" of the center

    private String deobser; // Likely "Observations" or "Notes" about this center

    // RELATIONSHIP: One Center can manage many different Agencies
    // "mappedBy = center" tells Java that the "Center" field in the Agency class 
    // is the one in charge of defining this connection.
    @OneToMany(mappedBy = "center", fetch = FetchType.LAZY) 
    @ToString.Exclude // Don't print all agencies when printing the Center (prevents crashes)
    @EqualsAndHashCode.Exclude // Don't use the list of agencies to compare two centers
    @Builder.Default // If using @Builder, start with an empty list instead of "null"
    private List<Agency> agencies = new ArrayList<>(); // The list of agencies belonging to this center
}