package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.yasmine.entity.Rotation;
import org.yasmine.repository.RotationRepository;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TripService {

    private final RotationRepository rotationRepository;

    public List<Rotation> getAllTrips() {
        return rotationRepository.findAll();
    }

    public Rotation getTripById(String id) {
        return rotationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Trip not found with id: " + id));
    }

    public List<Rotation> getTripsByLineNumber(String denumli) {
        return rotationRepository.findByDenumli(denumli)
                .stream()
                .sorted(Comparator.comparing(Rotation::getHdeparte))
                .toList();
    }

    public List<Rotation> getNotCancelledTrips() {
        return rotationRepository.findAll()
                .stream()
                .filter(rotation -> rotation.getRannul() == null || !"1".equals(rotation.getRannul()))
                .toList();
    }

    public List<Rotation> getCancelledTrips() {
        return rotationRepository.findByRannul("1");
    }

    public Rotation saveTrip(Rotation rotation) {
        return rotationRepository.save(rotation);
    }

    public void deleteTrip(String id) {
        rotationRepository.deleteById(id);
    }
}