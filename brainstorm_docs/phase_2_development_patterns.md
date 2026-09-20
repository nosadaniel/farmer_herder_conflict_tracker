# Development Patterns & Standards: Farmer-Herders Conflict Tracker

**Version**: 1.0.0  
**Last Updated**: September 20, 2026  
**Phase**: 2 - Product Planning  
**Status**: Draft  
**Related Document**: phase_2_tech_architecture.md

---

## 🏗️ Development Patterns & Architecture

### Development Methodology: Test-Driven Development (TDD)

**TDD Workflow**: Red → Green → Refactor

```
1. RED: Write failing test for new feature
   ↓
2. GREEN: Write minimal code to pass test
   ↓
3. REFACTOR: Improve code while keeping tests passing
   ↓
4. REPEAT: Continue cycle for next feature
```

#### TDD Implementation Strategy

**Test Pyramid** (Bottom-Up Approach):
```
          ┌─────────────┐
          │   E2E Tests  │  (10-20 tests)
          │   (Slow)    │  ← User flows, integration
          └──────┬──────┘
                 │
    ┌─────────────────┴─────────────────┐
    │           Integration Tests        │  (50-100 tests)
    │           (Medium)                 │  ← Multi-component, APIs
    └─────────────┬─────────────────┘
                  │
     ┌────────────┴────────────┐
     │        Unit Tests          │  (200-500+ tests)
     │        (Fast)              │  ← Individual functions, widgets
     └──────────────────────────┘
```

**Testing Coverage Targets**:
- **Unit Tests**: >80% code coverage
- **Widget Tests**: >80% widget coverage
- **Integration Tests**: >70% flow coverage
- **E2E Tests**: Critical user journeys only

#### Test Structure

**Note**: Test structure must follow the feature-based folder pattern. All tests are co-located with their respective features.

```
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   │   └── user_model_test.dart  (Unit tests)
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   │       └── auth_repository_test.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   │   └── user_test.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart (abstract)
│   │   │       └── auth_repository_test.dart (mock tests)
│   │   ├── application/
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       │   └── login_test.dart
│   │   │       └── register.dart
│   │   │           └── register_test.dart
│   │   └── presentation/
│   │       ├── blocs/
│   │       │   ├── auth_bloc.dart
│   │       │   └── auth_bloc_test.dart  (Widget + Bloc tests)
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       │       └── login_page_test.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           │   └── login_form_test.dart  (Widget tests)
│   │           └── auth_button.dart
│   │               └── auth_button_test.dart
│   │
│   ├── conflict_reporting/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── conflict_model.dart
│   │   │   │   │   └── conflict_model_test.dart
│   │   │   │   ├── report_model.dart
│   │   │   │   └── report_model_test.dart
│   │   │   └── repositories/
│   │   │       ├── conflict_repository.dart
│   │   │       │   └── conflict_repository_test.dart
│   │   │       └── report_repository.dart
│   │   │           └── report_repository_test.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── conflict.dart
│   │   │   │   │   └── conflict_test.dart
│   │   │   │   ├── report.dart
│   │   │   │   └── report_test.dart
│   │   │   │   └── location.dart
│   │   │   │       └── location_test.dart
│   │   │   └── repositories/
│   │   │       ├── conflict_repository.dart (abstract)
│   │   │       │   └── conflict_repository_test.dart
│   │   │       └── report_repository.dart (abstract)
│   │   │           └── report_repository_test.dart
│   │   ├── application/
│   │   │   └── usecases/
│   │   │       ├── submit_report.dart
│   │   │       │   └── submit_report_test.dart
│   │   │       ├── get_conflicts.dart
│   │   │       │   └── get_conflicts_test.dart
│   │   │       ├── assess_risk_level.dart
│   │   │       │   └── assess_risk_level_test.dart
│   │   │       └── share_alert.dart
│   │   │           └── share_alert_test.dart
│   │   └── presentation/
│   │       ├── blocs/
│   │       │   ├── report_bloc.dart
│   │       │   │   └── report_bloc_test.dart
│   │       │   ├── conflict_map_bloc.dart
│   │       │   │   └── conflict_map_bloc_test.dart
│   │       │   └── risk_assessment_bloc.dart
│   │       │       └── risk_assessment_bloc_test.dart
│   │       └── widgets/
│   │           ├── conflict_card.dart
│   │           │   └── conflict_card_test.dart
│   │           └── share_button.dart
│   │               └── share_button_test.dart
│   │
│   └── map/
│       ├── application/
│       │   └── usecases/
│       │       ├── load_map.dart
│       │       │   └── load_map_test.dart
│       │       └── update_location.dart
│       │           └── update_location_test.dart
│       └── presentation/
│           └── widgets/
│               └── conflict_map.dart
│                   └── conflict_map_test.dart
│
└── test/
    ├── integration/
    │   ├── auth_flow_test.dart
    │   ├── conflict_reporting_flow_test.dart
    │   └── map_flow_test.dart
    └── e2e/
        ├── user_auth_journey_test.dart
        └── conflict_reporting_journey_test.dart
```

**Key Principle**: Unit tests and widget tests live alongside the code they test within each feature folder. Integration and E2E tests remain in the top-level `test/` directory organized by test type.

#### Test File Naming Convention
- Unit tests: `[filename]_test.dart` (same directory)
- Widget tests: `[widget_name]_test.dart` (same directory)
- Integration tests: `[feature]_integration_test.dart` (in `test/integration/`)
- E2E tests: `[scenario]_e2e_test.dart` (in `test/e2e/`)

#### TDD Best Practices
1. **One Assert per Test**: Each test verifies one behavior
2. **FIRST Principles**: Fast, Isolated, Repeatable, Self-validating, Timely
3. **Test Data Builders**: Use factories for test data creation
4. **Mock Dependencies**: Use `mockito` for external dependencies
5. **Golden Tests**: For UI consistency (widget snapshots)
6. **Test Coverage**: Use `flutter test --coverage` and upload to Codecov

---

### Architecture Pattern: Feature-Based with Layered Architecture

**Pattern**: Presentation-Application-Domain-Data (4-Layer Clean Architecture)

**Folder Structure**: Feature-based modules with clean separation of concerns

```
lib/
├── core/                          # App-wide shared code
│   ├── constants/                 # App constants, configs
│   │   ├── app_constants.dart
│   │   ├── api_endpoints.dart
│   │   └── design_system.dart
│   │
│   ├── errors/                   # Error handling
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── error_handler.dart
│   │
│   ├── network/                  # Network utilities
│   │   ├── api_client.dart
│   │   ├── connectivity.dart
│   │   └── interceptors.dart
│   │
│   ├── utils/                    # Utility functions
│   │   ├── date_utils.dart
│   │   ├── validators.dart
│   │   └── extensions.dart
│   │
│   └── theme/                    # App theming
│       ├── app_theme.dart
│       └── colors.dart
│
├── features/                     # Feature modules (feature-based)
│   ├── auth/                     # Authentication feature
│   │   ├── data/                # DATA LAYER
│   │   │   ├── datasources/
│   │   │   │   ├── remote/
│   │   │   │   │   └── auth_remote_data_source.dart
│   │   │   │   └── local/
│   │   │   │       └── auth_local_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   │
│   │   ├── domain/              # DOMAIN LAYER
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart (abstract)
│   │   │
│   │   ├── application/        # APPLICATION LAYER
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       └── register.dart
│   │   │
│   │   └── presentation/       # PRESENTATION LAYER
│   │       ├── blocs/           # Riverpod/State Management
│   │       │   ├── auth_bloc.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── auth_button.dart
│   │
│   ├── conflict_reporting/     # Main feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── remote/
│   │   │   │   │   ├── conflict_remote_data_source.dart
│   │   │   │   │   └── weather_remote_data_source.dart
│   │   │   │   └── local/
│   │   │   │       ├── conflict_local_data_source.dart
│   │   │   │       └── report_cache_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── conflict_model.dart
│   │   │   │   ├── report_model.dart
│   │   │   │   └── weather_model.dart
│   │   │   └── repositories/
│   │   │       ├── conflict_repository.dart
│   │   │       └── report_repository.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── conflict.dart
│   │   │   │   ├── report.dart
│   │   │   │   └── location.dart
│   │   │   └── repositories/
│   │   │       ├── conflict_repository.dart (abstract)
│   │   │       └── report_repository.dart (abstract)
│   │   │
│   │   ├── application/        # APPLICATION LAYER
│   │   │   └── usecases/
│   │   │       ├── submit_report.dart
│   │   │       ├── get_conflicts.dart
│   │   │       ├── assess_risk_level.dart
│   │   │       └── share_alert.dart
│   │   │
│   │   └── presentation/        # PRESENTATION LAYER
│   │       ├── blocs/
│   │       │   ├── report_bloc.dart
│   │       │   ├── conflict_map_bloc.dart
│   │       │   └── risk_assessment_bloc.dart
│   │       ├── a2ui/            # A2UI specific components
│   │       │   ├── a2ui_workspace.dart
│   │       │   ├── dynamic_canvas.dart
│   │       │   └── components/
│   │       │       ├── a2ui_header.dart
│   │       │       ├── a2ui_map_view.dart
│   │       │       └── ... (all catalog components)
│   │       ├── pages/
│   │       │   ├── main_app_page.dart
│   │       │   ├── report_page.dart
│   │       │   └── map_page.dart
│   │       └── widgets/
│   │           ├── microphone_button.dart
│   │           ├── text_input_modal.dart
│   │           ├── conflict_card.dart
│   │           └── share_button.dart
│   │
│   ├── map/                      # Map feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── map_remote_data_source.dart
│   │   │   └── repositories/
│   │   │       └── map_repository.dart
│   │   │
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── map_location.dart
│   │   │
│   │   ├── application/        # APPLICATION LAYER
│   │   │   └── usecases/
│   │   │       ├── load_map.dart
│   │   │       └── update_location.dart
│   │   │
│   │   └── presentation/
│   │       └── widgets/
│   │           └── conflict_map.dart
│   │
│   └── weather/                   # Weather data feature
│       ├── data/
│       │   ├── datasources/
│       │   │   └── remote/
│       │   │       └── weather_remote_data_source.dart
│       │   └── repositories/
│       │       └── weather_repository.dart
│       │
│       ├── domain/
│       │   └── entities/
│       │       └── weather_data.dart
│       │
│       ├── application/        # APPLICATION LAYER
│       │   └── usecases/
│       │       └── fetch_weather.dart
│       │
│       └── presentation/
│           └── widgets/
│               └── weather_overlay.dart
│
└── main.dart                    # App entry point
```

#### Layer Architecture: Presentation-Application-Domain-Data (Clean Architecture)

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                         │
│  (UI, State Management, A2UI)                                  │
│  - Widgets (Stateless/Stateful)                              │
│  - Riverpod Providers (StateNotifiers, StateProviders)      │
│  - A2UI Components (Dynamic UI)                             │
│  - Pages/Screens                                            │
│  - Blocs/Controllers (if using)                              │
└──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                          │
│  (Use Cases, Business Rules, Coordination)                   │
│  - Use Cases (Orchestrates business logic)                   │
│  - Business Rules (Application-specific logic)              │
│  - Coordination between Domain Entities                     │
│  - Application Services                                     │
└──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  (Business Logic, Entities, Core Rules)                      │
│  - Entities (Business objects)                              │
│  - Repository Interfaces (Abstract contracts)              │
│  - Value Objects                                            │
│  - Domain Services (Pure business logic)                    │
└──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                               │
│  (Data Sources, APIs, Storage)                               │
│  - Remote Data Sources (API clients)                        │
│  - Local Data Sources (SQLite, Preferences)                 │
│  - Repository Implementations                               │
│  - Models (DTOs, fromJson/toJson)                            │
└─────────────────────────────────────────────────────────────┘
```

**Layer Responsibilities**:

| Layer | Responsibility | Dependencies | Contains |
|-------|----------------|--------------|----------|
| **Presentation** | UI, User Interaction | Application Layer | Widgets, Pages, State Mgmt, A2UI |
| **Application** | Use Cases, Business Rules | Domain Layer | Use Cases, Business Rules, Application Services |
| **Domain** | Business Logic, Core Rules | None | Entities, Repository Interfaces, Value Objects, Domain Services |
| **Data** | Data Access | Domain Layer | Models, Data Sources, Repositories (concrete) |

**Dependency Rule**: Presentation → Application → Domain → Data (never reverse!)

---

### Code Base Practices

#### 1. DRY (Don't Repeat Yourself)

**Implementation**:
- **Shared Widgets**: Create reusable widgets in `core/widgets/`
- **Utility Functions**: Common functions in `core/utils/`
- **Constants**: Centralize magic numbers, strings in `core/constants/`
- **Mixins**: For shared behavior across classes
- **Extensions**: Add methods to existing classes (e.g., String extensions)

**Examples**:
```dart
// ✅ DO: Shared widget
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryButton({required this.text, required this.onPressed});
  @override
  Widget build(BuildContext context) => ElevatedButton(...);
}

// ❌ DON'T: Duplicate button code in multiple places
```

**DRY Checklist**:
- [ ] Is this code used in more than one place? → Extract to reusable component
- [ ] Is this a magic number/string? → Add to constants
- [ ] Is this logic repeated? → Extract to utility function

#### 2. SOLID Principles

**S - Single Responsibility Principle (SRP)**
- Each class/widget should have one reason to change
- One class = One responsibility

```dart
// ✅ DO: Single responsibility
class ReportRepository {
  // Only handles report data operations
  Future<void> submitReport(Report report);
  Future<List<Report>> getReports();
}

class ReportBloc {
  // Only handles report state management
  Stream<ReportState> mapEventToState(ReportEvent event);
}

// ❌ DON'T: Multiple responsibilities
class ReportManager {
  Future<void> submitReport(Report report);  // Data
  Stream<ReportState> mapEventToState(...);  // State
  Widget buildReportForm();               // UI
}
```

**O - Open/Closed Principle (OCP)**
- Open for extension, closed for modification
- Use polymorphism and inheritance

```dart
// ✅ DO: Extendable base class
abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<void> save(T item);
}

class ReportRepository extends BaseRepository<Report> {
  @override
  Future<List<Report>> getAll() => ...;
  
  @override
  Future<void> save(Report report) => ...;
}

class ConflictRepository extends BaseRepository<Conflict> {
  @override
  Future<List<Conflict>> getAll() => ...;
}
```

**L - Liskov Substitution Principle (LSP)**
- Subtypes must be substitutable for their base types
- Override methods should not break parent behavior

```dart
// ✅ DO: Proper substitution
class VoiceReportService implements ReportService {
  @override
  Future<Report> createReport() async {
    // Voice-specific implementation
    return await _recordAndProcessAudio();
  }
}

class TextReportService implements ReportService {
  @override
  Future<Report> createReport() async {
    // Text-specific implementation
    return await _processTextInput();
  }
}

// Can use either interchangeably
ReportService service = isVoiceEnabled 
  ? VoiceReportService() 
  : TextReportService();
```

**I - Interface Segregation Principle (ISP)**
- Clients should not be forced to depend on interfaces they don't use
- Split large interfaces into smaller, focused ones

```dart
// ✅ DO: Segregated interfaces
abstract class ReadRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
}

abstract class WriteRepository<T> {
  Future<void> save(T item);
  Future<void> delete(String id);
}

abstract class FullRepository<T> implements ReadRepository<T>, WriteRepository<T> {}

// ❌ DON'T: Monolithic interface
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
  // ... many more methods
}
```

**D - Dependency Inversion Principle (DIP)**
- High-level modules should not depend on low-level modules
- Both should depend on abstractions

```dart
// ✅ DO: Dependency injection with abstractions
class ReportBloc {
  final ReportRepository _repository;
  
  ReportBloc(this._repository); // Injected abstraction
  
  // Uses abstract repository, not concrete implementation
}

// Usage with dependency injection
final reportBloc = ReportBloc(
  MockReportRepository(), // For testing
  // or ProductionReportRepository(), // For production
);
```

#### 3. Code Composition

**Prefer Composition over Inheritance**

```dart
// ✅ DO: Composition
class ReportForm extends StatelessWidget {
  final TextInputFormatter _formatter;
  final Validator _validator;
  final ReportSubmitter _submitter;
  
  const ReportForm({
    TextInputFormatter? formatter,
    Validator? validator,
    ReportSubmitter? submitter,
  }) : _formatter = formatter ?? DefaultFormatter(),
       _validator = validator ?? DefaultValidator(),
       _submitter = submitter ?? DefaultSubmitter();
  
  @override
  Widget build(BuildContext context) {
    // Compose functionality
    return Column(
      children: [
        TextField(
          inputFormatters: [_formatter],
          validator: (_validator.validate),
        ),
        ElevatedButton(
          onPressed: _submitter.submit,
          child: Text('Submit'),
        ),
      ],
    );
  }
}

// ❌ DON'T: Deep inheritance chains
class BaseForm extends StatelessWidget { ... }
class ReportForm extends BaseForm { ... }
class VoiceReportForm extends ReportForm { ... }
```

**Functional Composition**:
```dart
// ✅ DO: Compose functions
typedef ReportValidator = bool Function(Report);
typedef ReportFormatter = String Function(Report);

String processReport(Report report) {
  return _composeActions(report, [
    validateReport,
    formatReport,
    logReport,
  ]);
}

T _composeActions<T>(T input, List<Function(T)> actions) {
  return actions.fold(input, (value, action) => action(value));
}
```

---

### State Management: Riverpod Patterns

**Requirement**: Use class-based patterns where possible with Riverpod code generator for compile-time safety and reduced boilerplate.

#### Riverpod Provider Types

| Provider Type | Use Case | Example |
|--------------|----------|---------|
| **Provider** | Simple, immutable state | App configuration, constants |
| **StateProvider** | Mutable state | Current user, theme mode |
| **StateNotifierProvider** | Complex state | Form state, multi-step flows |
| **ChangeNotifierProvider** | Legacy (avoid if possible) | Use StateNotifierProvider instead |
| **FutureProvider** | Async data loading | Fetch reports from API |
| **StreamProvider** | Real-time data | Firestore subscriptions, WebSockets |
| **AsyncValue** | Handle async states | Loading, data, error states |

#### Recommended Riverpod Architecture

**Use Riverpod Code Generator (`@riverpod` annotation) for class-based patterns:**

```dart
// 1. Add to pubspec.yaml:
// dev_dependencies:
//   riverpod_generator: ^2.3.0
//   build_runner: ^2.4.0
// 
// Then run: flutter pub run build_runner watch

// 1. Create State Classes (Immutable)
@immutable
class ReportState {
  final bool isLoading;
  final List<Report> reports;
  final String? error;
  
  const ReportState({
    this.isLoading = false,
    this.reports = const [],
    this.error,
  });
  
  ReportState copyWith({
    bool? isLoading,
    List<Report>? reports,
    String? error,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      error: error ?? this.error,
    );
  }
}

// 2. Create StateNotifier with @riverpod annotation (Class-based)
@riverpod
class ReportNotifier extends _$ReportNotifier {
  @override
  ReportState build() {
    return const ReportState();
  }
  
  Future<void> fetchReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.watch(reportRepositoryProvider);
      final reports = await repository.getReports();
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<void> submitReport(Report report) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.watch(reportRepositoryProvider);
      await repository.submitReport(report);
      state = state.copyWith(isLoading: false);
      await fetchReports(); // Refresh
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// 3. Provider is auto-generated as: reportNotifierProvider
// No need to manually create the provider!
```

**Comparison - Manual vs Code Generator:**

```dart
// OLD WAY (Manual - still valid but more verbose):
final reportNotifierProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return ReportNotifier(repository);
});

// NEW WAY (Code Generator - recommended):
@riverpod
class ReportNotifier extends _$ReportNotifier {
  @override
  ReportState build() {
    final repository = ref.watch(reportRepositoryProvider);
    return ReportState();
  }
  // methods...
}
// Auto-generates: reportNotifierProvider
```

// 4. Use in UI (Consumer widget)
class ReportList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportNotifierProvider);
    final notifier = ref.read(reportNotifierProvider.notifier);
    
    return reportState.isLoading
      ? LoadingIndicator()
      : reportState.error != null
        ? ErrorFeedback(message: reportState.error!)
        : ListView.builder(
            itemCount: reportState.reports.length,
            itemBuilder: (context, index) => 
              ReportCard(report: reportState.reports[index]),
          );
  }
}
```

#### Riverpod Best Practices

**1. Provider Scope**
```dart
// ✅ DO: Scope providers appropriately
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnv();
});

// Global provider (app-wide)
final authStateProvider = StateProvider<AuthState>((ref) => AuthState.unauthenticated);

// Feature-scoped provider
final reportNotifierProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  // Can access global providers
  final config = ref.watch(appConfigProvider);
  final repository = ref.watch(reportRepositoryProvider);
  return ReportNotifier(repository);
});
```

**2. Provider Families** (For similar providers)
```dart
// ✅ DO: Use provider families for similar types
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(dioProvider));
});

final conflictRepositoryProvider = Provider<ConflictRepository>((ref) {
  return ConflictRepositoryImpl(ref.watch(dioProvider));
});

// Generic repository provider family
final repositoryProvider = ProviderFamily<Repository<dynamic>, Type>((ref, type) {
  switch (type) {
    case Report:
      return ReportRepositoryImpl(ref.watch(dioProvider)) as Repository<dynamic>;
    case Conflict:
      return ConflictRepositoryImpl(ref.watch(dioProvider)) as Repository<dynamic>;
    default:
      throw UnsupportedError('No repository for type $type');
  }
});
```

**3. Auto-Dispose Providers**
```dart
// ✅ DO: Use autoDispose for providers that should be cleaned up
final reportSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredReportsProvider = Provider.autoDispose<List<Report>>((ref) {
  final searchTerm = ref.watch(reportSearchProvider);
  final allReports = ref.watch(allReportsProvider);
  
  return allReports.where((report) => 
    report.description.toLowerCase().contains(searchTerm.toLowerCase())
  ).toList();
});
```

**4. AsyncValue Pattern** (Recommended for async operations)
```dart
// ✅ DO: Use AsyncValue for loading states
final reportsProvider = FutureProvider<List<Report>>((ref) async {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getReports();
});

// In UI
class ReportList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);
    
    return reportsAsync.when(
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorFeedback(message: error.toString()),
      data: (reports) => ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) => ReportCard(report: reports[index]),
      ),
    );
  }
}
```

**5. Family Pattern with Parameters**
```dart
// ✅ DO: Create parameterized providers
final reportByIdProvider = FutureProvider.family<Report, String>((ref, reportId) async {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getReportById(reportId);
});

// Usage
final reportAsync = ref.watch(reportByIdProvider(reportId));
```

**6. Provider Ordering**
```dart
// ✅ DO: Order providers by dependency
// 1. Repositories (data layer)
final reportRepositoryProvider = Provider<ReportRepository>((ref) => ...);

// 2. Use Cases (domain layer)
final submitReportUseCaseProvider = Provider<SubmitReportUseCase>((ref) {
  return SubmitReportUseCase(ref.watch(reportRepositoryProvider));
});

// 3. Notifiers/State (presentation layer)
final reportNotifierProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.watch(submitReportUseCaseProvider));
});
```

**7. Testing with Riverpod**
```dart
// ✅ DO: Test providers in isolation
void main() {
  test('ReportNotifier fetches reports successfully', () async {
    // Create mock repository
    final mockRepository = MockReportRepository();
    when(mockRepository.getReports()).thenAnswer(
      (_) async => [testReport1, testReport2],
    );
    
    // Create container with overrides
    final container = ProviderContainer(
      overrides: [
        reportRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    
    // Read provider
    final notifier = container.read(reportNotifierProvider.notifier);
    
    // Test
    await notifier.fetchReports();
    final state = container.read(reportNotifierProvider);
    
    expect(state.reports.length, 2);
    expect(state.isLoading, false);
    expect(state.error, isNull);
  });
}
```

**8. Error Handling**
```dart
// ✅ DO: Centralized error handling
class AppException implements Exception {
  final String message;
  final int? code;
  
  AppException(this.message, {this.code});
}

// In notifier
class ReportNotifier extends StateNotifier<ReportState> {
  // ...
  
  Future<void> fetchReports() async {
    try {
      final reports = await _repository.getReports();
      state = state.copyWith(reports: reports);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      // Optionally: ref.read(errorHandlerProvider).handle(e);
    } on SocketException {
      state = state.copyWith(error: 'No internet connection');
    } catch (e) {
      state = state.copyWith(error: 'An unknown error occurred');
    }
  }
}
```
