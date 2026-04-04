package org.yasmine.pfe;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = {"org.yasmine", "org.yasmine.pfe"})
@EnableJpaRepositories(basePackages = "org.yasmine.repository")
@EntityScan(basePackages = "org.yasmine.entity")
public class YasminepfeApplication {

    public static void main(String[] args) {
        SpringApplication.run(YasminepfeApplication.class, args);
    }
}