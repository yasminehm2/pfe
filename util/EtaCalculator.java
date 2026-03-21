package org.yasmine.util;

public final class EtaCalculator {

    private EtaCalculator() {
    }

    public static long estimateMinutesByDistance(double distanceKm, double averageSpeedKmH) {
        if (averageSpeedKmH <= 0) {
            return -1;
        }
        double hours = distanceKm / averageSpeedKmH;
        return Math.max((long) Math.ceil(hours * 60), 0);
    }
}