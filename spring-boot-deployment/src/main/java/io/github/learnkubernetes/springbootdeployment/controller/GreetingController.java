package io.github.learnkubernetes.springbootdeployment.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GreetingController {

	@Value("${greeting.message:I have nothing to say.}")
	protected String greetingMessage;

    @GetMapping("/greet/{user}")
    public String greet(@PathVariable("user") String user) {
        return String.format("Hi %s! %s", user, greetingMessage);
    }
}