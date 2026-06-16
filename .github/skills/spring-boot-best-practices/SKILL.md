---
name: spring-boot-best-practices
description: Spring Boot best practices for Kotlin — injection, transactions, proxy annotations, JPA entities, naming, and REST API design. Use when writing or reviewing Spring Boot code in Kotlin.
license: MIT
metadata:
  domain: backend
  tags: spring-boot kotlin jpa rest transactions proxy logging naming
---

# Spring Boot Best Practices (Kotlin)

## Injection

**Use constructor injection, not field injection.**

```kotlin
// Bad
@Service
class PaymentService {
    @Autowired
    lateinit var repository: PaymentRepository
}

// Good
@Service
class PaymentService(
    private val repository: PaymentRepository,
)
```

## Proxy Annotations

**Proxy annotations (`@Transactional`, `@Cacheable`, `@CacheEvict`, `@CachePut`, `@Async`) must not be placed on private methods** — the Spring proxy cannot intercept them.

```kotlin
// Bad
@Service
class InvoiceService {
    fun createInvoice() { persistInvoice() }

    @Transactional
    private fun persistInvoice() { /* proxy never intercepts this */ }
}

// Good
@Service
class InvoiceService {
    @Transactional
    fun createInvoice() { persistInvoice() }

    private fun persistInvoice() { /* transaction opened on the public method */ }
}
```

**Avoid self-invocation between proxy-annotated methods.** Calls via `this` bypass the proxy — inject a separate bean instead.

```kotlin
// Bad
@Service
class ReportService {
    @Transactional
    fun generate(id: Long) { archive(id) } // @Async never fires

    @Async
    fun archive(id: Long) { }
}

// Good
@Service
class ReportService(private val archiveService: ArchiveService) {
    @Transactional
    fun generate(id: Long) { archiveService.archive(id) }
}

@Service
class ArchiveService {
    @Async
    fun archive(id: Long) { }
}
```

## Configuration

**`@Configuration` classes must not hold mutable state** (exceptions: `@Value` and `@ConfigurationProperties` fields).

```kotlin
// Bad
@Configuration
class MailConfiguration {
    var retries = 0
    @Bean fun mailClient(): MailClient = MailClient()
}

// Good
@Configuration
class MailConfiguration {
    @Bean
    fun mailClient(properties: MailProperties): MailClient =
        MailClient(properties.host, properties.port)
}
```

**`@Bean` methods must live in `@Configuration` classes**, not in `@Component`.

## Exceptions

**Custom exceptions must extend `RuntimeException`**, not `Exception`.

```kotlin
// Bad
class PaymentFailedException(message: String) : Exception(message)

// Good
class PaymentFailedException(message: String) : RuntimeException(message)
```

## JPA

**Kotlin `data class` must not be used as JPA entities** — `data class` is `final` and prevents lazy-loading proxies.

```kotlin
// Bad
@Entity
data class UserEntity(@Id val id: Long, val email: String)

// Good
@Entity
class UserEntity(
    @Id var id: Long? = null,
    var email: String,
)
```

**All `@Entity` classes must declare an `@Id` field.**

**`@Transactional` belongs in the service layer**, not in controllers.

**Domain and entity packages must not import `org.springframework.*`** — keep the domain model independent of Spring.

## Naming

| Annotation | Suffix |
|---|---|
| `@Service` | `Service` |
| `@Repository` | `Repository` |
| `@Controller` / `@RestController` | `Controller` |
| `@ControllerAdvice` / `@RestControllerAdvice` | `ExceptionHandler` or `Advice` |
| `@ConfigurationProperties` | `Properties` |

## REST API

**Use specific HTTP method annotations** — avoid `@RequestMapping` where `@GetMapping`, `@PostMapping`, etc. apply.

**No trailing slash** on mapping paths: `/users`, not `/users/`.

**`GET` endpoints must return something** — not `Unit`/`void`. If it is a command, use `POST`.

**Do not expose JPA entities from REST** — use dedicated DTOs.

**Controllers must not inject repositories directly** — go through a service.

```kotlin
// Bad
@RestController
class UserController(private val userRepository: UserRepository)

// Good
@RestController
class UserController(private val userService: UserService)
```

