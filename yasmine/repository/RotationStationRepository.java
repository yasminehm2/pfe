package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.RotationStation;
import java.util.List;

@Repository
public interface RotationStationRepository extends JpaRepository<RotationStation, Long> {

    /**
     * Finds all stops for a specific rotation ordered by their sequence.
     * Supports the "continuously recalculating ETA" requirement.
     */
    List<RotationStation> findByRotationIdOrderByStationOrderAsc(String rotationId);
}