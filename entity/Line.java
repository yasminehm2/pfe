package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "line")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
public class Line {

    @Id
    private String id;
    private Integer deccent;
    private Integer decagenc;
    @Column(unique = true, nullable = false)
    private String denumli;
    private String denomli;
    private Integer denbrkm;
    private String statlig;
    private String lig;
}