package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "deprotat")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
public class Rotation {

    @Id
    private String id;
    private Integer deccent;
    private Integer decagenc;
    private String datedet;
    private String denumli;
    private String decstat;
    private Integer matric;
    private Integer matric1;
    private String hdeparte;
    private String harralle;
    private String rannul;
    private Double km;
    private String motifa;
}