package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.DisplayInfo;
import java.util.List;

@Repository // Tells Spring: "This is the Data Access layer for the Display table."
public interface DisplayInfoRepository extends JpaRepository<DisplayInfo, Long> {

    /**
     * 💡 MAGIC METHOD: "Quick Station Look-up"
     * This looks for all DisplayInfo records where the 'station_id' matches.
     * Use case: When a passenger clicks on a station on a map, this quickly
     * returns all the "Digital Signage" info for that specific location.
     */
    List<DisplayInfo> findByStationId(String stationId);

    /**
     * 💡 MAGIC METHOD: "Bulk Line Filter"
     * The 'In' keyword tells Spring to search for any match within a list.
     * SQL equivalent: "SELECT * FROM display WHERE denumli IN ('L1', 'L2', 'L5')"
     * Use case: Finding display info for several different lines at once.
     */
    List<DisplayInfo> findByDenumliIn(List<String> lineNumbers);
}