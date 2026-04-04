package org.yasmine.dto;

import lombok.Builder;
import lombok.Data;
import org.yasmine.entity.UserRole;

@Data
@Builder
public class GuestAccessDTO {
    private String tempId;
    private UserRole role; // Set to GUEST
    private String message;
}