package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.LineRot;
import org.yasmine.entity.LineRotId;
import java.util.List;

@Repository
public interface LineRotRepository extends JpaRepository<LineRot, LineRotId> {
    // Find all rotations linked to a specific Line ID
    List<LineRot> findByLineId(String lineId);

    // Find the line associated with a specific Rotation ID
    List<LineRot> findByRotationId(String rotationId);
    
}