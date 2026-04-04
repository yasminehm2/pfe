package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Station;
import java.util.List;

@Repository
public interface StationRepository extends JpaRepository<Station, String> {

    // Native query to find stations within ~1km of the user in Sfax
    @Query(value = "SELECT *, (6371 * acos(cos(radians(:lat)) * cos(radians(latitude)) * " +
                   "cos(radians(longitude) - radians(:lon)) + sin(radians(:lat)) * " +
                   "sin(radians(latitude)))) AS distance FROM station " +
                   "HAVING distance < 1.0 ORDER BY distance", nativeQuery = true)
    List<Station> findNearbyStations(@Param("lat") double lat, @Param("lon") double lon);

    // Find station by its Arabic name (delstat)
    List<Station> findByDelstatContaining(String nameAr);
}