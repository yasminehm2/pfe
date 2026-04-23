package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.DisplayInfo;
import java.util.List;

@Repository
public interface DisplayInfoRepository extends JpaRepository<DisplayInfo, Long> {

    /**
     * Finds all trips associated with a specific station.
     * Since we linked DisplayInfo directly to Station, this is 
     * significantly faster than joining Line and LineStation.
     */
    List<DisplayInfo> findByStationId(String stationId);

    /**
     * Optional: If you still need to filter based on the Line's relationship
     */
    List<DisplayInfo> findByDenumliIn(List<String> lineNumbers);
}