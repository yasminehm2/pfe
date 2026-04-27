package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Vehicle;
import java.util.Optional;

/**
 * The "Vehicle Assistant" that manages the live bus/train data.
 */
@Repository // Tells Spring: "This is the data office for the 'gps_vehic' table."
public interface VehicleRepository extends JpaRepository<Vehicle, String> {

    /**
     * 💡 ADVANCED QUERY: "Which bus is driving this trip?"
     * Since a Vehicle has a LIST of rotations, we have to "JOIN" them 
     * to search inside that list.
     * * * Logic:
     * 1. JOIN v.rotations r: "Look at all the trips assigned to this vehicle."
     * 2. WHERE r.id = :rotationId: "Find the one that matches the trip ID I'm looking for."
     * * * Use Case: When a passenger wants to track "Trip #505," the app uses this 
     * to find out exactly which bus (Vehicle) is currently assigned to it.
     */
    @Query("SELECT v FROM Vehicle v JOIN v.rotations r WHERE r.id = :rotationId")
    Optional<Vehicle> findByRotationId(@Param("rotationId") String rotationId);
}