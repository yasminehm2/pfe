package org.yasmine.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 📡 THE LIVE FEED
 * This object is sent to the phone every few seconds to update 
 * the bus position and the "Arriving in X mins" timer.
 */
@Data // Adds Getters, Setters, and toString.
@Builder // For easy creation
@NoArgsConstructor
@AllArgsConstructor
public class RotationDTO {

    private String rotationId;  // The specific trip ID being tracked.
    private String lineNumber;  // The bus number (e.g., "Bus 10").
    private String destination; // Where the bus is going.

    // 📍 LIVE GPS: The exact spot where the bus is right now.
    private double vehicleLat; 
    private double vehicleLon; 

    // ⏳ THE MAIN TARGET COUNTDOWN:
    // This is the number of minutes left until the bus hits the SPECIFIC station the user tapped.
    private Integer etaMinutes; 

    // 🚦 ENGINE STATUS: 
    // Tells the user if the bus is "moving", "stopped", or if the GPS is "offline".
    private String status; 

    // 🔔 THE PROXIMITY TRIGGER:
    // This turns 'true' when the bus is very close (e.g., < 100m).
    private boolean arrivalAlert; 
    
    // 🚀 NEW: THE FULL ROUTE WITH LIVE ETAS
    // This tells Java to accept the itinerary list!
    private List<StationDTO> itinerary;
}