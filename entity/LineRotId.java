package org.yasmine.entity;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class LineRotId implements Serializable {

    private String lineId;
    private String rotationId;
}