package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

// 🚀 KEY CONCEPT: @Embeddable
// This means "This is not a separate table." 
// Instead, these fields (latitude/longitude) will be added as extra columns 
// into whatever table uses this class.
@Embeddable 
@Data // Automatically creates Getters and Setters
@NoArgsConstructor // Empty constructor
@AllArgsConstructor // Full constructor
@Builder // For easy object creation (e.g., Position.builder().latitude(34.1).build())
public class Position {

    // Simple decimal numbers for GPS coordinates
    private double latitude;
    private double longitude;
}