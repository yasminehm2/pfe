package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "station")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Station {

    @Id
    private String id; // This matches the 'station_id' in DisplayInfo

    private String delstat;
    private String delstatfr;
    private String latitude;
    private String longitude;

    @OneToMany(mappedBy = "station", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<LineStation> lineStations = new ArrayList<>();

    @OneToMany(mappedBy = "station", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<RotationStation> rotationStations = new ArrayList<>();

    // 🚀 BIDIRECTIONAL LINK
    @OneToMany(mappedBy = "station", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<DisplayInfo> displayInfos = new ArrayList<>();
}