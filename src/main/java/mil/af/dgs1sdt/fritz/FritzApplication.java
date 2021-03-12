package mil.af.dgs1sdt.fritz;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class FritzApplication {
	public static void main(String[] args) {
		SpringApplication.run(FritzApplication.class, args);
	}
}

