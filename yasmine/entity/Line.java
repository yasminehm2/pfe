package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "line")
@Data
@NoArgsConstructor
@AllArgsConstructor
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

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "decagenc",
            referencedColumnName = "decagenc",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Agency agency;

    @OneToMany(mappedBy = "line", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<LineRot> lineRots = new ArrayList<>();

    @OneToMany(mappedBy = "line", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<LineStation> lineStations = new ArrayList<>();

    @OneToMany(mappedBy = "line", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<DisplayInfo> displayInfos = new ArrayList<>();

    public boolean isActive() {
        return statlig != null && statlig.equalsIgnoreCase("A");
    }

    public String getFullName() {
        String number = denumli != null ? denumli : "";
        String name = denomli != null ? denomli : "";
        return number + " - " + name;
    }

    public String getLineNumber() {
        return denumli;
    }
}