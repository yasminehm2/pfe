package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.DisplayInfo;

@Repository
public interface DisplayInfoRepository extends JpaRepository<DisplayInfo, Long> {
}