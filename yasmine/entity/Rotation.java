package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "deprotat")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Rotation {

    @Id
    private String id;

    private Integer deccent;
    private Integer decagenc;
    private String datedet;
    private String denumli;
    private String decstat;

    private String matric;

    private String hdeparte;
    private String harralle;
    private String rannul;
    private Double km;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "matric",
            referencedColumnName = "matvehicule",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Vehicle vehicle;

    @OneToMany(mappedBy = "rotation", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<LineRot> lineRots = new ArrayList<>();

    @OneToMany(mappedBy = "rotation", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<RotationStation> rotationStations = new ArrayList<>();

    @OneToMany(mappedBy = "chosenRotation", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<User> users = new ArrayList<>();

    public boolean isCancelled() {
        return rannul != null && rannul.trim().equals("1");
    }

    public boolean isInProgress() {
        return !isCancelled();
    }

}