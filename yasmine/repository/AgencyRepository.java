package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Agency;
import java.util.List;

@Repository
public interface AgencyRepository extends JpaRepository<Agency, String> {
    List<Agency> findByDeccent(Integer deccent);
}