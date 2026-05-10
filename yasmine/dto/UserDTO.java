package org.yasmine.dto;

import lombok.*;
import org.yasmine.entity.UserRole;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserDTO {
    private String id;
    private String name;
    private String email;
    private String password; // Used for registration/login only
    private Double lat;
    private Double lon;
    private UserRole role;
    private String message;
    private String token;
}