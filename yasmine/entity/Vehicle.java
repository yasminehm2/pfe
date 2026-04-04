package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "gps_vehic")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Vehicle {

    @Id
    private String matvehicule;

    private String newlat;
    private String newlon;
    private String lastlat;
    private String lastlon;
    private String visible;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "latitude", column = @Column(name = "pos_lat")),
            @AttributeOverride(name = "longitude", column = @Column(name = "pos_lon"))
    })
    private Position position;

    @OneToMany(mappedBy = "vehicle", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<Rotation> rotations = new ArrayList<>();
}