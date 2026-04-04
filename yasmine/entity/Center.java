package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "center")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Center {

    @Id
    private String id;

    @Column(nullable = false, unique = true)
    private Integer deccent;

    @Column(nullable = false)
    private String delcent;

    private String deadrce;

    private String deobser;

    @OneToMany(mappedBy = "center", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @Builder.Default
    private List<Agency> agencies = new ArrayList<>();
}