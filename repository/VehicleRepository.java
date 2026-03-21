package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.yasmine.entity.Vehicle;

public interface VehicleRepository extends JpaRepository<Vehicle, String> {
}