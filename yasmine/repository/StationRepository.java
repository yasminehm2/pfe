package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.yasmine.entity.Station;
import java.util.List;

public interface StationRepository extends JpaRepository<Station, String> {
    
    // Optional: Faster native query if you have many stations
	// In StationRepository.java
	@Query(value = "SELECT * FROM station s WHERE " +
	       "(6371 * acos(cos(radians(:lat)) * cos(radians(CAST(s.latitude AS DOUBLE))) * " +
	       "cos(radians(CAST(s.longitude AS DOUBLE)) - radians(:lon)) + " +
	       "sin(radians(:lat)) * sin(radians(CAST(s.latitude AS DOUBLE))))) <= :radius", 
	       nativeQuery = true)
	List<Station> findNearby(@Param("lat") double lat, @Param("lon") double lon, @Param("radius") double radius);
}