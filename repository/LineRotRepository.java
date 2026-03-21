package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.yasmine.entity.LineRot;
import org.yasmine.entity.LineRotId;

import java.util.List;

public interface LineRotRepository extends JpaRepository<LineRot, LineRotId> {

    List<LineRot> findByLineId(String lineId);

    List<LineRot> findByRotationId(String rotationId);

}