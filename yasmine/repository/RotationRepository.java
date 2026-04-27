package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Rotation;
import java.util.List;
import java.util.Optional;

/**
 * The "Trip Tracker" that handles complex searches for bus/train trips.
 */
@Repository // Tells Spring: "This is the data office for the 'rotation' table."
public interface RotationRepository extends JpaRepository<Rotation, String> {

    /**
     * 💡 ADVANCED QUERY: "What's coming to my stop?"
     * * This uses JPQL (Java Persistence Query Language). It's like a 
     * treasure map that jumps through four different tables:
     * 1. Rotation -> 2. LineRot -> 3. Line -> 4. LineStation (where the stationId is).
     */
    @Query("SELECT DISTINCT r FROM Rotation r " +
           "JOIN r.lineRots lr " +
           "JOIN lr.line l " +
           "JOIN l.lineStations ls " +
           "WHERE ls.station.id = :stationId " +
           "AND (r.rannul IS NULL OR r.rannul <> '1')")
    List<Rotation> findRotationsByStationThroughLine(@Param("stationId") String stationId);

    // 🚀 NEW: Finds the most recent trip assigned to a specific bus license plate
    Optional<Rotation> findFirstByMatricOrderByIdDesc(String matric);
}