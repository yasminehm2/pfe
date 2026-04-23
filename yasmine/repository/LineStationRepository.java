package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.LineStation;
import java.util.List;

@Repository
public interface LineStationRepository extends JpaRepository<LineStation, Long> {
    List<LineStation> findByLineIdOrderByStationOrderAsc(String lineId);
    List<LineStation> findByStationId(String stationId);
}