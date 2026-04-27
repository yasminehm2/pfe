package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Line;
import java.util.Optional;

/**
 * The "Line Assistant" that manages all the bus/train route data.
 */
@Repository // Tells Spring: "This is the data office for the 'line' table."
public interface LineRepository extends JpaRepository<Line, String> {

    /**
     * 💡 MAGIC METHOD: "Find by Official Number"
     * SQL equivalent: "SELECT * FROM line WHERE denumli = ?"
     * * Why 'Optional'? 
     * It's a safety box. If the line exists, the box has a Line inside. 
     * If the line doesn't exist (e.g., searching for Bus 999 which isn't real), 
     * the box is empty. This prevents your app from crashing with a "Null" error.
     */
    Optional<Line> findByDenumli(String denumli);
}