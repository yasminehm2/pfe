package org.yasmine.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) 
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .authorizeHttpRequests(auth -> auth
                // 1. Public Authentication Endpoints
                // This covers /login, /signup, /guest, and /check-email
                .requestMatchers("/api/auth/**").permitAll() 

                // 2. Public Map & Tracking Endpoints
                .requestMatchers("/api/stations/**").permitAll()  
                .requestMatchers("/api/tracking/**").permitAll()  

                // 🚀 3. THE UPDATE: The location update is now inside /api/auth/update-location
                // We permit all so that Guests can also update their position for nearby stops.
                .requestMatchers(HttpMethod.POST, "/api/auth/update-location").permitAll()
                
                // 4. General maintenance endpoints
                .requestMatchers("/error").permitAll() 

                // 5. Pre-flight requests for CORS
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll() 
                
                // 6. Secure everything else
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            );

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // Allow Flutter app from any IP
        configuration.setAllowedOriginPatterns(List.of("*")); 
        
        // Added PATCH just in case you use it for other features later
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}