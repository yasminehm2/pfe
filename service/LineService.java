package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Line;
import org.yasmine.repository.LineRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LineService {

    private final LineRepository lineRepository;

    public List<Line> getAllLines() {
        return lineRepository.findAll();
    }

    public Line getLineById(String id) {
        return lineRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Line not found with id: " + id));
    }

    public Line getLineByDenumli(String denumli) {
        return lineRepository.findByDenumli(denumli)
                .orElseThrow(() -> new RuntimeException("Line not found with denumli: " + denumli));
    }

    public Line saveLine(Line line) {
        return lineRepository.save(line);
    }

    public void deleteLine(String id) {
        lineRepository.deleteById(id);
    }
}