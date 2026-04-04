package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Rotation;
import java.util.List;

@Repository
public interface RotationRepository extends JpaRepository<Rotation, String> {

    /**
     * Fetches all rotations for a specific station that are not cancelled (rannul != '1').
     */
    @Query("SELECT r FROM Rotation r WHERE r.decstat = :stationId AND r.rannul != '1'")
    List<Rotation> findActiveRotationsByStation(@Param("stationId") String stationId);
}