package org.yasmine.dto;

import lombok.*;

// 🚀 KEY CONCEPT: Data Transfer Object (DTO)
// This class doesn't live in the database. Its only job is to carry 
// data from the Server to the Mobile App in a clean, simple format.
@Data // Adds Getters and Setters
@Builder // Allows you to create objects easily: DisplayInfoDTO.builder().id("1").build()
@NoArgsConstructor // Empty constructor
@AllArgsConstructor // Full constructor
public class DisplayInfoDTO {
    
    private String id;           // Unique ID for this display record
    private String lineNumber;   // The bus number (maps to 'denumli' in the DB)
    
    // 🕒 TIME INFO: These might be null if the database doesn't have a schedule yet
    private String departureTime; 
    private String arrivalTime;   

    private String busPlate;     // The license plate (maps to 'vehicule' in the DB)
    
    // 📍 STATION INFO: Final cleaned-up names for the UI
    private String departureStation;
    private String arrivalStation;
    private boolean isCancelled;
}