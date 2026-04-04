package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "line_rot")
@IdClass(LineRotId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LineRot {

    @Id
    private String lineId;

    @Id
    private String rotationId;

    private Integer deccent;
    private Integer decagenc;
    private String denumli;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "lineId",
            referencedColumnName = "id",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Line line;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "rotationId",
            referencedColumnName = "id",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Rotation rotation;
}