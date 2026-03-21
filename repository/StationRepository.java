package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.yasmine.entity.Station;

public interface StationRepository extends JpaRepository<Station, String> {
}