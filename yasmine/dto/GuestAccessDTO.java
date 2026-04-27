package org.yasmine.dto;

import lombok.Builder;
import lombok.Data;
import org.yasmine.entity.UserRole;

/**
 * 🎫 THE TEMPORARY TICKET
 * This DTO is used when someone wants to browse the app as a Guest.
 */
@Data // Automatically adds Getters, Setters, and toString.
@Builder // For quick object creation: GuestAccessDTO.builder().tempId("G1").build().
public class GuestAccessDTO {

    // A random ID (like "GUEST-abc-123") so the server can 
    // recognize this specific guest during their current visit.
    private String tempId;

    // This will always be UserRole.GUEST. 
    // It tells the app to hide features like "Favorite Lines" or "Profile."
    private UserRole role; 

    // A friendly greeting, e.g., "Welcome! You are browsing as a guest."
    private String message;
}