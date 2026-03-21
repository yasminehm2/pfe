package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.yasmine.entity.Line;

import java.util.Optional;

public interface LineRepository extends JpaRepository<Line, String> {
    Optional<Line> findByDenumli(String denumli);
}