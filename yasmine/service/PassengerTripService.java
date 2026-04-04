package org.yasmine.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.User;
import org.yasmine.repository.RotationRepository;
import org.yasmine.repository.UserRepository;

@Service
@RequiredArgsConstructor
public class PassengerTripService {

    private final UserRepository userRepository;
    private final RotationRepository rotationRepository;

    @Transactional
    public void confirmTrip(String userId, String rotationId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Rotation rotation = rotationRepository.findById(rotationId)
                .orElseThrow(() -> new RuntimeException("Rotation not found"));

        user.setChosenRotation(rotation); // Confirm to activate live tracking 
        userRepository.save(user);
    }
}