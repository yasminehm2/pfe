package org.yasmine.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration // Tells Spring: "This is a setup file for the application."
@EnableWebSocketMessageBroker // Turns on high-level WebSocket powers (specifically STOMP messaging).
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        
        // 1. Where messages go TO the users:
        // Any message sent to a URL starting with "/topic" will be broadcasted to all subscribed users.
        // Example: "/topic/tracking" could send live GPS updates to everyone watching.
        config.enableSimpleBroker("/topic");

        // 2. Where messages come FROM the users:
        // If a user (frontend) wants to send data to the server, they must start the URL with "/app".
        // Example: Sending data to "/app/update-location".
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        
        // 3. The "Handshake" URL:
        // This is the initial entrance. The frontend connects to "http://yourserver:8080/ws-tracking"
        // to start the persistent "phone call" connection.
        registry.addEndpoint("/ws-tracking")
                
                // 4. Security bypass:
                // Allows any website (Origin) to connect to this WebSocket. 
                // Useful for development, but in a real app, you'd limit this to your specific frontend URL.
                .setAllowedOrigins("*"); 
    }
}