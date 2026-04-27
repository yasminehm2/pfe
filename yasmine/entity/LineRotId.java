package org.yasmine.entity;

import lombok.*;

import java.io.Serializable;

/**
 * This is an "ID Class." 
 * It groups the multiple parts of a Primary Key into one object.
 */
@Data // Automatically creates Getters, Setters, equals(), and hashCode()
@NoArgsConstructor // Creates an empty constructor (required for JPA)
@AllArgsConstructor // Creates a constructor with both IDs
public class LineRotId implements Serializable { 
    
    // 1. First part of the key: The ID of the Line
    private String lineId;

    // 2. Second part of the key: The ID of the Rotation
    private String rotationId;

    // Why "Serializable"?
    // It's like "freezing" the object so Java can save it or send it 
    // across the network/database easily. JPA requires this for composite keys.
}