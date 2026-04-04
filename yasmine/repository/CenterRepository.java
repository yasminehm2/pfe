package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.Center;

@Repository
public interface CenterRepository extends JpaRepository<Center, String> {
}