package com.huerta.users.api;

import java.util.UUID;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping(path = "/api/users", produces = MediaType.APPLICATION_JSON_VALUE)
public class UserController {
  public record UserDto(UUID id, String name) {
  }

  @GetMapping
  public Flux<UserDto> all() {
    return Flux.just(
        new UserDto(UUID.randomUUID(), "John"),
        new UserDto(UUID.randomUUID(), "Jane"));
  }
}