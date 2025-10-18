Welcome — quick instructions for AI coding agents working on this repo

Be concise and actionable. Only suggest changes that can be implemented within the repo layout and Flutter 3.24.0 constraints. Preserve existing file structure and naming conventions.

Project snapshot
- Flutter 3.24.0 scaffold using Clean Architecture (Presentation → Domain → Data).
- Main entry: `lib/main.dart` with flavor entrypoints: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`.
- DI: `lib/core/di.dart` (uses `get_it`).
- Theme & constants: `lib/core/theme.dart`, `lib/core/constants.dart`.
- Presentation: `lib/presentation/*` (pages and cubits). Example: `home_page.dart`, `home_cubit.dart`.
- Domain: `lib/domain/entities/*`, `lib/domain/repositories/*`.
- Data: `lib/data/models/*`, `lib/data/datasources/*`, `lib/data/repositories/*`.

Primary goals for edits
- Keep the Clean Architecture separation. Presentation should not depend on data implementations (use domain interfaces). Data layer implements domain contracts.
- Use `get_it` in `lib/core/di.dart` for service registration. Prefer `registerLazySingleton` for repositories and `registerFactory` for blocs/cubits where appropriate.
- Use `flutter_bloc` (Cubit/BLoC) in presentation. When adding any new screen, create a corresponding Cubit under `lib/presentation/cubit` and provide it via `BlocProvider` in the page widget.

Code patterns and examples (copyable)
- Register repository implementation (edit `lib/core/di.dart`):

  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl());

- Cubit pattern: create cubit in `lib/presentation/cubit` and use in page with `BlocProvider(create: (_) => MyCubit())`.
- Network datasources use Dio in `lib/data/datasources/remote/*` and return data models in `lib/data/models/*`.

Flavors and build
- Entrypoints exist for each flavor; when adding platform flavor configuration, update Android `android/app/build.gradle` to add `productFlavors` (see `docs/ANDROID_FLAVORS.md`).
- Build APK examples (use -t to select flavor entrypoint):

  flutter build apk --flavor dev -t lib/main_dev.dart

If you propose modifications that require Android changes, include the exact `build.gradle` snippet and explain where to paste it.

Testing and local verification
- When adding runnable code, ensure `flutter analyze` and `flutter test` pass locally. For small changes, a quick smoke test by running `flutter run` (or `flutter run -t lib/main_dev.dart`) is sufficient.

Conventions and restrictions
- Don't add breaking changes to public API without updating DI and usage sites.
- Keep strings and user-facing text simple; localization uses `intl` — if adding localized strings, add ARB files under `lib/l10n` and register them.
- Avoid creating new top-level packages; keep changes within `digital_bank_app` package structure.

When you make a PR
- Describe which layer changed and why (Presentation / Domain / Data). List added files. Include build/test proof (e.g., `flutter analyze` output or a short run log).

Files to inspect for context
- `lib/main.dart`, `lib/core/di.dart`, `lib/presentation/pages/home_page.dart`, `lib/presentation/cubit/home_cubit.dart`, `lib/domain/repositories/account_repository.dart`, `lib/data/repositories/account_repository_impl.dart`, `docs/ANDROID_FLAVORS.md`.

If anything is unclear
- Ask a single clarifying question that references a file path (e.g., "Should I add DI registration in `lib/core/di.dart` or create a new module?").

Keep responses and code edits minimal and directly testable.
