package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity // Tells Java: "This class represents a database table."
@Table(name = "gps_vehic") // The database table is actually named "gps_vehic".
@Data // Automatically adds Getters, Setters, etc.
@NoArgsConstructor // Empty constructor.
@AllArgsConstructor // Full constructor.
@Builder // For easy object creation.
public class Vehicle {

    @Id // The Primary Key. 
    // In this case, it's the license plate or internal ID of the bus.
    private String matvehicule; 

    // REAL-TIME TRACKING FIELDS
    private String newlat;   // The very latest Latitude received from the GPS.
    private String newlon;   // The very latest Longitude received from the GPS.
    private String lastlat;  // The previous Latitude (useful for calculating speed/direction).
    private String lastlon;  // The previous Longitude.
    private String visible;  // A flag (like "1" or "0") to show if the bus is currently online/active.

    // 🚀 EMBEDDED POSITION
    // Remember that 'Position' class we saw? We are using it here!
    @Embedded
    @AttributeOverrides({
            // Since 'Position' uses names like "latitude", we rename them here 
            // so they match the specific columns in the 'gps_vehic' table.
            @AttributeOverride(name = "latitude", column = @Column(name = "pos_lat")),
            @AttributeOverride(name = "longitude", column = @Column(name = "pos_lon"))
    })
    private Position position;

    // 🔗 LINK TO ROTATIONS
    // One vehicle can be assigned to many different rotations (trips) over time.
    // Example: This bus does the 9:00 AM trip, then the 2:00 PM trip.
    @OneToMany(mappedBy = "vehicle", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<Rotation> rotations = new ArrayList<>();
}