package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Agency;
import java.util.List;

/**
 * 🚀 KEY CONCEPT: This interface is the bridge between your Java code 
 * and the "agency" table in the database.
 */
@Repository // Tells Spring: "Manage this as a data access component."
public interface AgencyRepository extends JpaRepository<Agency, String> {
    
    /**
     * 💡 MAGIC METHOD: "Query Method"
     * You don't have to write the code for this! 
     * Spring looks at the name 'findByDeccent' and automatically writes the 
     * SQL query: "SELECT * FROM agency WHERE deccent = ?"
     * * @param deccent The Center ID you want to search for.
     * @return A list of all Agencies that belong to that specific Center.
     */
    
}