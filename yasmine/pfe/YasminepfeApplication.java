package org.yasmine.pfe;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.boot.security.autoconfigure.SecurityAutoConfiguration;
import org.springframework.boot.security.autoconfigure.UserDetailsServiceAutoConfiguration;
import org.springframework.context.annotation.Import; // Add this import
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.yasmine.config.SecurityConfig; // Add this import

@SpringBootApplication(
	    scanBasePackages = "org.yasmine",
	    exclude = { 
	        SecurityAutoConfiguration.class, 
	        UserDetailsServiceAutoConfiguration.class 
	    } // 🚀 This stops the automatic password generation
	)
@EnableJpaRepositories(basePackages = "org.yasmine.repository")
@EntityScan(basePackages = "org.yasmine.entity")
@Import(SecurityConfig.class)
public class YasminepfeApplication {
    public static void main(String[] args) {
        SpringApplication.run(YasminepfeApplication.class, args);
    }
}