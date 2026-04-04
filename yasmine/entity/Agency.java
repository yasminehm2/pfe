package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "agency")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Agency {

    @Id
    private String id;

    @Column(nullable = false, unique = true)
    private Integer decagenc;

    @Column(nullable = false)
    private String delagenc;

    @Column(nullable = false)
    private Integer deccent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "deccent",
            referencedColumnName = "deccent",
            insertable = false,
            updatable = false
    )
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Center center;

    @OneToMany(mappedBy = "agency", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<Line> lines = new ArrayList<>();
}