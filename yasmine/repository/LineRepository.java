package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Line;
import java.util.Optional;

@Repository
public interface LineRepository extends JpaRepository<Line, String> {
    Optional<Line> findByDenumli(String denumli);
}