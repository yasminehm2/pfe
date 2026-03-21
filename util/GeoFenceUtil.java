package org.yasmine.util;

public final class GeoFenceUtil {

    private GeoFenceUtil() {
    }

    public static boolean isInsideRadius(
            double pointLat,
            double pointLon,
            double centerLat,
            double centerLon,
            double radiusMeters
    ) {
        double distance = DistanceCalculator.distanceMeters(pointLat, pointLon, centerLat, centerLon);
        return distance <= radiusMeters;
    }
}