package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "line_rot")
@IdClass(LineRotId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
public class LineRot {

    @Id
    private String lineId;

    @Id
    private String rotationId;

    private Integer deccent;
    private Integer decagenc;
    private String denumli;
    @ManyToOne
    @JoinColumn(name = "lineId", referencedColumnName = "id", insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Line line;

    @ManyToOne
    @JoinColumn(name = "rotationId", referencedColumnName = "id", insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Rotation rotation;
    
}