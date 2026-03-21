package org.yasmine.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.yasmine.dto.*;
import org.yasmine.entity.DisplayInfo;
import org.yasmine.entity.Rotation;
import org.yasmine.entity.Station;
import org.yasmine.entity.Vehicle;
import org.yasmine.service.*;

import java.util.List;

@RestController
@RequestMapping
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;
    private final UserService userService;
    private final StationService stationService;
    private final TripService tripService;
    private final TrackingService trackingService;
    private final EtaService etaService;
    private final AlertService alertService;
    private final DisplayInfoService displayInfoService;

    @PostMapping("/auth/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        String token = authService.authenticate(request.getEmail(), request.getPassword());

        LoginResponse response = LoginResponse.builder()
                .token(token)
                .build();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/stations/nearby")
    public ResponseEntity<List<NearbyStationResponse>> getNearbyStations(
            @RequestParam double userLat,
            @RequestParam double userLon,
            @RequestParam(defaultValue = "5.0") double radiusKm
    ) {
        List<NearbyStationResponse> response = stationService.getNearbyStations(userLat, userLon, radiusKm)
                .stream()
                .map(station -> NearbyStationResponse.builder()
                        .id(station.getId())
                        .delstat(station.getDelstat())
                        .delstatfr(station.getDelstatfr())
                        .latitude(station.getLatitude())
                        .longitude(station.getLongitude())
                        .distanceKm(stationService.distanceToStation(userLat, userLon, station.getId()))
                        .build())
                .toList();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/stations/select")
    public ResponseEntity<StationSelectionRequest> selectStations(@RequestBody StationSelectionRequest request) {
        stationService.getStationById(request.getDepartureStationId());
        stationService.getStationById(request.getArrivalStationId());
        return ResponseEntity.ok(request);
    }

    @GetMapping("/trips")
    public ResponseEntity<List<TripResponse>> getTripsByLineNumber(@RequestParam String denumli) {
        List<TripResponse> response = tripService.getTripsByLineNumber(denumli)
                .stream()
                .map(this::mapToTripResponse)
                .toList();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/trips/select")
    public ResponseEntity<TripResponse> selectTrip(@RequestBody TripSelectionRequest request) {
        Rotation trip = tripService.getTripById(request.getTripId());
        return ResponseEntity.ok(mapToTripResponse(trip));
    }

    @GetMapping("/trips/{tripId}")
    public ResponseEntity<TripResponse> getTripById(@PathVariable String tripId) {
        Rotation trip = tripService.getTripById(tripId);
        return ResponseEntity.ok(mapToTripResponse(trip));
    }

    @GetMapping("/tracking/{tripId}")
    public ResponseEntity<TrackingResponse> getTracking(@PathVariable String tripId) {
        Vehicle vehicle = trackingService.getVehicleForTrip(tripId);

        TrackingResponse response = TrackingResponse.builder()
                .matvehicule(vehicle.getMatvehicule())
                .newlat(vehicle.getNewlat())
                .newlon(vehicle.getNewlon())
                .lastlat(vehicle.getLastlat())
                .lastlon(vehicle.getLastlon())
                .visible(vehicle.getVisible())
                .build();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/eta/{tripId}")
    public ResponseEntity<EtaResponse> getEtaToTripArrival(@PathVariable String tripId) {
        long etaMinutes = etaService.estimateEtaToTripArrival(tripId);

        EtaResponse response = EtaResponse.builder()
                .tripId(tripId)
                .etaMinutes(etaMinutes)
                .build();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/eta/{tripId}/station/{stationId}")
    public ResponseEntity<EtaResponse> getEtaToStation(
            @PathVariable String tripId,
            @PathVariable String stationId
    ) {
        long etaMinutes = etaService.estimateEtaToStationByDistance(tripId, stationId);

        EtaResponse response = EtaResponse.builder()
                .tripId(tripId)
                .stationId(stationId)
                .etaMinutes(etaMinutes)
                .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/alerts/arrival")
    public ResponseEntity<String> subscribeArrivalAlert(@RequestBody ArrivalAlertRequest request) {
        boolean departureAlert = alertService.shouldSendDepartureAlert(
                request.getTripId(),
                request.getDepartureStationId()
        );

        boolean arrivalAlert = alertService.shouldSendArrivalAlert(
                request.getTripId(),
                request.getArrivalStationId()
        );

        String message = "Departure alert: " + departureAlert + ", Arrival alert: " + arrivalAlert;
        return ResponseEntity.ok(message);
    }

    @GetMapping("/display-info")
    public ResponseEntity<List<DisplayInfoResponse>> getDisplayInfoByLine(@RequestParam String denumli) {
        List<DisplayInfoResponse> response = displayInfoService.getDisplayInfoByLineNumber(denumli)
                .stream()
                .map(this::mapToDisplayInfoResponse)
                .toList();

        return ResponseEntity.ok(response);
    }

    private TripResponse mapToTripResponse(Rotation trip) {
        return TripResponse.builder()
                .id(trip.getId())
                .deccent(trip.getDeccent())
                .decagenc(trip.getDecagenc())
                .datedet(trip.getDatedet())
                .denumli(trip.getDenumli())
                .decstat(trip.getDecstat())
                .matric(trip.getMatric())
                .matric1(trip.getMatric1())
                .hdeparte(trip.getHdeparte())
                .harralle(trip.getHarralle())
                .rannul(trip.getRannul())
                .km(trip.getKm())
                .motifa(trip.getMotifa())
                .build();
    }

    private DisplayInfoResponse mapToDisplayInfoResponse(DisplayInfo displayInfo) {
        return DisplayInfoResponse.builder()
                .id(displayInfo.getId())
                .lang(displayInfo.getLang())
                .depart(displayInfo.getDepart())
                .arrivee(displayInfo.getArrivee())
                .vehicule(displayInfo.getVehicule())
                .detailLigne(displayInfo.getDetailLigne())
                .ligne(displayInfo.getLigne())
                .direction(displayInfo.getDirection())
                .denumli(displayInfo.getDenumli())
                .deltyli(displayInfo.getDeltyli())
                .delagenc(displayInfo.getDelagenc())
                .build();
    }
}