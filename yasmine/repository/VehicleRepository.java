package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Vehicle;
import java.util.Optional;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, String> {

    // Fixes "No property currentRotationId found" error
    // We join the rotations list and check the ID of the rotation
    @Query("SELECT v FROM Vehicle v JOIN v.rotations r WHERE r.id = :rotationId")
    Optional<Vehicle> findByRotationId(@Param("rotationId") String rotationId);
}