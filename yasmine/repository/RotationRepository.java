package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Rotation;
import java.util.List;

@Repository
public interface RotationRepository extends JpaRepository<Rotation, String> {
	@Query("SELECT DISTINCT r FROM Rotation r " +
	           "JOIN r.lineRots lr " +
	           "JOIN lr.line l " +
	           "JOIN l.lineStations ls " +
	           "WHERE ls.station.id = :stationId " +
	           "AND (r.rannul IS NULL OR r.rannul <> '1')") // 🚀 Matches your isCancelled() logic
	    List<Rotation> findRotationsByStationThroughLine(@Param("stationId") String stationId);
}