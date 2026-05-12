package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.LineStation;
import org.yasmine.entity.LineStationId;

import java.util.List;

/**
 * The "Sequence Specialist" that knows exactly which stops belong to which line
 * and what order they appear in.
 */
@Repository // Tells Spring: "This is the data office for the line-to-station connections."
public interface LineStationRepository extends JpaRepository<LineStation, LineStationId> {

    /**
     * 💡 MAGIC METHOD: "Get the Route Map"
     * This does three things at once:
     * 1. Finds all stations for a specific Line.
     * 2. Sorts them by 'stationOrder'.
     * 3. 'Asc' means 1, 2, 3... (from start to finish).
     * Use case: Drawing the line on a map so the path goes in a logical 
     * straight line instead of jumping around randomly.
     */
    List<LineStation> findByLineIdOrderByStationOrderAsc(String lineId);

    /**
     * 💡 MAGIC METHOD: "Who stops here?"
     * Finds every line that passes through a specific station.
     * Use case: When a user clicks a station icon, you show a list 
     * of all bus numbers that stop there.
     */
    List<LineStation> findByStationId(String stationId);
}