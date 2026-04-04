package org.yasmine.entity;

import lombok.*;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LineRotId implements Serializable {
    private String lineId;
    private String rotationId;
}