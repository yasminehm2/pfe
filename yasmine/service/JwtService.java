package org.yasmine.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {

    // 🚀 Reads the new secret key property
    @Value("${app.security.jwt.secret}")
    private String secretKey;

    // 🚀 Reads the expiration in MINUTES
    @Value("${app.security.jwt.accessTokenMinutes}")
    private long accessTokenMinutes;

    // 🚀 Reads the new issuer property
    @Value("${app.security.jwt.issuer}")
    private String issuer;

    public String extractEmail(String token) {
        return extractClaim(token, Claims::getSubject);
    }

 // Creates a token for a specific user using their email and role
    public String generateToken(String email, String role) {
        
        // 1. Create a map to hold extra custom data
        Map<String, Object> extraClaims = new HashMap<>();
        
        // 2. Add the user's role (so the mobile app knows what they are allowed to do)
        extraClaims.put("role", role);
        
        // 3. Start building the token
        return Jwts.builder()
                .setClaims(extraClaims) // Attach our custom data (the role)
                .setSubject(email)      // Set the main identifier (the user's email)
                .setIssuer(issuer)      // Set the name of our app as the creator
                .setIssuedAt(new Date(System.currentTimeMillis())) // Record exactly when it was created
                
                // 4. Set the expiration time (converts your minutes from properties into milliseconds)
                .setExpiration(new Date(System.currentTimeMillis() + (accessTokenMinutes * 60 * 1000))) 
                
                // 5. Lock and sign the token securely with our secret key
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                
                // 6. Package it all up into the final String format
                .compact();
    }
    
    public boolean isTokenValid(String token) {
        try {
            return !extractExpiration(token).before(new Date());
        } catch (Exception e) {
            return false;
        }
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = Jwts.parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
        return claimsResolver.apply(claims);
    }

    private Key getSignInKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}