package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.LineRot;
import org.yasmine.entity.LineRotId;
import java.util.List;

/**
 * The "Link Specialist" that manages the relationship between Lines and Trips.
 */
@Repository // Tells Spring: "This is the office that manages the Line-to-Rotation links."
public interface LineRotRepository extends JpaRepository<LineRot, LineRotId> {
    
    /**
     * 💡 MAGIC METHOD: "Give me all trips for this route."
     * Use case: You click on "Bus Line 10" and want to see every 
     * scheduled trip (Morning, Afternoon, Evening) for that line.
     */
    List<LineRot> findByLineId(String lineId);

    /**
     * 💡 MAGIC METHOD: "Which route does this trip belong to?"
     * Use case: You have a specific trip ID (Rotation) and you need 
     * to find out which Bus Line it is currently serving.
     */
    List<LineRot> findByRotationId(String rotationId);
}