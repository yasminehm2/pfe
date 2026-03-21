package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "station")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
public class Station {

    @Id
    private String id;
    private String delstat;
    private String delstatfr;
    private String latitude;
    private String longitude;
}