package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "gps_vehic")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
public class Vehicle {

    @Id
    private String matvehicule;
    private String newlat;
    private String newlon;
    private String lastlat;
    private String lastlon;
    private String visible;
}