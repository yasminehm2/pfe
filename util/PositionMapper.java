package org.yasmine.util;

import org.yasmine.entity.Position;
import org.yasmine.entity.Station;
import org.yasmine.entity.Vehicle;

public final class PositionMapper {

    private PositionMapper() {
    }

    public static Position fromVehicle(Vehicle vehicle) {
        return Position.builder()
                .latitude(parse(vehicle.getNewlat()))
                .longitude(parse(vehicle.getNewlon()))
                .build();
    }

    public static Position fromStation(Station station) {
        return Position.builder()
                .latitude(parse(station.getLatitude()))
                .longitude(parse(station.getLongitude()))
                .build();
    }

    private static double parse(String value) {
        return Double.parseDouble(value == null ? "0" : value.trim());
    }
}