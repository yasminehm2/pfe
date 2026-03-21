package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
public class User {

    @Id
    private String id;
    private String name;
    private String email;
    private String password;
    private double lat;
    private double lon;
    @Enumerated(EnumType.STRING)
    private UserRole role;
}