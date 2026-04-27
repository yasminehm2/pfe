package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.yasmine.entity.Station;
import java.util.List;

/**
 * The "Location Specialist" for finding bus stops on a map.
 */
public interface StationRepository extends JpaRepository<Station, String> {
    
    /**
     * 💡 ADVANCED SEARCH: "Find Nearby Stations"
     * This uses a "Native Query," which means it's raw SQL that talks 
     * directly to your database engine.
     * * The Big Math Formula (Haversine Formula):
     * - The 6371 is the Earth's radius in kilometers.
     * - The complex 'acos', 'cos', and 'sin' part calculates the distance 
     * between two points on a sphere (the Earth).
     * * Logic:
     * 1. It takes the User's Latitude and Longitude (:lat, :lon).
     * 2. It calculates the distance to every station in the table.
     * 3. It only returns stations where the distance is less than or equal to the :radius.
     */
    @Query(value = "SELECT * FROM station s WHERE " +
           "(6371 * acos(cos(radians(:lat)) * cos(radians(CAST(s.latitude AS DOUBLE))) * " +
           "cos(radians(CAST(s.longitude AS DOUBLE)) - radians(:lon)) + " +
           "sin(radians(:lat)) * sin(radians(CAST(s.latitude AS DOUBLE))))) <= :radius", 
           nativeQuery = true)
    List<Station> findNearby(@Param("lat") double lat, @Param("lon") double lon, @Param("radius") double radius);
}