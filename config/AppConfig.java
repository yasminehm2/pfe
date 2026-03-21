package org.yasmine.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

    @Bean
    public Double defaultNearbyRadiusKm() {
        return 5.0;
    }

    @Bean
    public Double defaultGeofenceRadiusMeters() {
        return 100.0;
    }

    @Bean
    public Double averageBusSpeedKmH() {
        return 30.0;
    }
}