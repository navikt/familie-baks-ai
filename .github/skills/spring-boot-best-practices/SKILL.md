---
name: spring-boot-best-practices
description: Spring Boot beste praksiser for Kotlin — injeksjon, transaksjoner, proxy-annotasjoner, JPA-entiteter, navngivning, pakkestruktur og REST API-design. Bruk når du skriver eller gjennomgår Spring Boot-kode i Kotlin.
license: MIT
metadata:
  domain: backend
  tags: spring-boot kotlin jpa rest transactions proxy logging naming
---

# Spring Boot beste praksiser (Kotlin)

## Injeksjon

**Bruk konstruktørinjeksjon, ikke feltinjeksjon.**

```kotlin
// Dårlig
@Service
class BetalingService {
    @Autowired
    lateinit var repository: BetalingRepository
}

// Bra
@Service
class BetalingService(
    private val repository: BetalingRepository,
)
```

## Proxy-annotasjoner

**Proxy-annotasjoner (`@Transactional`, `@Cacheable`, `@CacheEvict`, `@CachePut`, `@Async`) skal ikke stå på private metoder** — Spring-proxyen kan ikke intercepte dem.

```kotlin
// Dårlig
@Service
class FakturaService {
    fun opprettFaktura() { lagreFaktura() }

    @Transactional
    private fun lagreFaktura() { /* proxy intercepter aldri dette */ }
}

// Bra
@Service
class FakturaService {
    @Transactional
    fun opprettFaktura() { lagreFaktura() }

    private fun lagreFaktura() { /* transaksjonen åpnes på public-metoden */ }
}
```

**Unngå selv-kall mellom proxy-annoterte metoder.** Kall fra `this` går utenom proxyen — inject en egen bean i stedet.

```kotlin
// Dårlig
@Service
class RapportService {
    @Transactional
    fun generer(id: Long) { arkiver(id) } // @Async kjøres aldri

    @Async
    fun arkiver(id: Long) { }
}

// Bra
@Service
class RapportService(private val arkivService: ArkivService) {
    @Transactional
    fun generer(id: Long) { arkivService.arkiver(id) }
}

@Service
class ArkivService {
    @Async
    fun arkiver(id: Long) { }
}
```

## Konfigurasjon

**`@Configuration`-klasser skal ikke ha mutable state** (unntak: `@Value`- og `@ConfigurationProperties`-felt).

```kotlin
// Dårlig
@Configuration
class EpostKonfigurasjon {
    var forsøk = 0
    @Bean fun epostKlient(): EpostKlient = EpostKlient()
}

// Bra
@Configuration
class EpostKonfigurasjon {
    @Bean
    fun epostKlient(properties: EpostProperties): EpostKlient =
        EpostKlient(properties.host, properties.port)
}
```

**`@Bean`-metoder skal ligge i `@Configuration`-klasser**, ikke i `@Component`.

## Unntak

**Egendefinerte unntak skal arve `RuntimeException`**, ikke `Exception`.

```kotlin
// Dårlig
class BetalingFeiletException(message: String) : Exception(message)

// Bra
class BetalingFeiletException(message: String) : RuntimeException(message)
```

## JPA

**Kotlin `data class` skal ikke brukes som JPA-entiteter** — `data class` er `final` og hindrer lazy-loading-proxyer.

```kotlin
// Dårlig
@Entity
data class BrukerEntitet(@Id val id: Long, val epost: String)

// Bra
@Entity
class BrukerEntitet(
    @Id var id: Long? = null,
    var epost: String,
)
```

**Alle `@Entity`-klasser må ha et `@Id`-felt.**

**`@Transactional` hører hjemme i service-laget**, ikke i kontrollere.

**Domain- og entity-pakker skal ikke importere `org.springframework.*`** — hold domenemodellen uavhengig av Spring.

## Navngivning

| Annotering | Suffiks |
|---|---|
| `@Service` | `Service` |
| `@Repository` | `Repository` |
| `@Controller` / `@RestController` | `Controller` |
| `@ControllerAdvice` / `@RestControllerAdvice` | `ExceptionHandler` eller `Advice` |
| `@ConfigurationProperties` | `Properties` |

## REST API

**Bruk spesifikke HTTP-metode-annotasjoner** — ikke `@RequestMapping` der `@GetMapping`, `@PostMapping` o.l. passer.

**Ingen trailing slash** på mapping-stier: `/brukere`, ikke `/brukere/`.

**`GET`-endepunkter skal returnere noe** — ikke `Unit`/`void`. Hvis det er en kommando, bruk `POST`.

**Ikke eksponér JPA-entiteter fra REST** — bruk egne DTO-er.

**Kontrollere skal ikke injisere repositories direkte** — gå via service.

```kotlin
// Dårlig
@RestController
class BrukerController(private val brukerRepository: BrukerRepository)

// Bra
@RestController
class BrukerController(private val brukerService: BrukerService)
```

