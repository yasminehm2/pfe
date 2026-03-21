package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.yasmine.entity.DisplayInfo;

public interface DisplayInfoRepository extends JpaRepository<DisplayInfo, Long> {
}