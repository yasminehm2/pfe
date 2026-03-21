package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.yasmine.entity.Rotation;

import java.util.List;

public interface RotationRepository extends JpaRepository<Rotation, String> {

    List<Rotation> findByDenumli(String denumli);

    List<Rotation> findByRannul(String rannul);

}