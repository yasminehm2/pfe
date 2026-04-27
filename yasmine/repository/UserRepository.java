package org.yasmine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.yasmine.entity.User;
import java.util.Optional;

/**
 * The "User Registry" that manages all member accounts and login data.
 */
@Repository // Tells Spring: "This is the data office for the 'users' table."
public interface UserRepository extends JpaRepository<User, String> {

    /**
     * 💡 MAGIC METHOD: "Find by Email"
     * SQL equivalent: "SELECT * FROM users WHERE email = ?"
     * * Use case: When a user tries to log in, you use this to find 
     * their record and then check if their password matches.
     * * Returns 'Optional' to avoid crashes if the email isn't in the system.
     */
    Optional<User> findByEmail(String email);
    
    /**
     * 💡 MAGIC METHOD: "Quick Email Check"
     * SQL equivalent: "SELECT COUNT(*) > 0 FROM users WHERE email = ?"
     * * Use case: During Sign-Up, you use this to check if an email 
     * is already taken. It returns 'true' or 'false'.
     * * It's faster than 'findByEmail' because it doesn't download 
     * the whole user profile; it just checks if the user exists.
     */
    boolean existsByEmail(String email); 
}