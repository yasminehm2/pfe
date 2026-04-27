package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Center;

/**
 * The "Center Assistant" for the database.
 */
@Repository // Tells Spring: "This is the dedicated gatekeeper for the 'center' table."
public interface CenterRepository extends JpaRepository<Center, String> {
    
    // Even though it looks empty, it actually has dozens of methods ready to use:
    // .findAll() -> Gets every Center in the database.
    // .findById("C1") -> Gets the specific Center with ID "C1".
    // .save(myCenter) -> Adds a new Center or updates an existing one.
    // .deleteById("C1") -> Removes a Center from the database.
    
    // Inside JpaRepository<Center, String>:
    // 'Center' is the name of the Entity class.
    // 'String' is the data type of the @Id (Primary Key) in that class.
}