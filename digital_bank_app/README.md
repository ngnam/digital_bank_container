Digital Bank App (scaffold)

This repository contains a minimal Flutter 3.24.0 application scaffolded with Clean Architecture (Presentation → Domain → Data).

Project structure (important files):
- `lib/main.dart` — app entry, flavor bootstrap, route setup
- `lib/core/di.dart` — dependency injection setup using `get_it`
- `lib/core/theme.dart` — app ThemeData
- `lib/core/constants.dart` — app-level constants
- `lib/presentation/pages/home_page.dart` — example page using Cubit
- `lib/presentation/cubit/home_cubit.dart` — example Cubit
- `lib/domain/entities/account.dart` — example entity
- `lib/domain/repositories/account_repository.dart` — abstract repo
- `lib/data/models/account_model.dart` — data model
- `lib/data/datasources/remote/account_remote_datasource.dart` — remote datasource using Dio
- `lib/data/repositories/account_repository_impl.dart` — repo impl

Flavors
 - This scaffold supports multi-flavor bootstrap. The example uses a simple `Flavor` enum and `main` entrypoints.
 - Android flavor configuration requires editing `android/app/build.gradle` to add productFlavors (see guidance below).

Build APK (Android)
- To build a flavor APK after configuring `android/app/build.gradle`, run:

```bash
# dev
flutter build apk --flavor dev -t lib/main_dev.dart

# staging
flutter build apk --flavor staging -t lib/main_staging.dart

# prod
flutter build apk --flavor prod -t lib/main_prod.dart
```

Notes
- This is a minimal scaffold — implement network, storage, and features as needed.

Quick run (dev)

```bash
# get packages
flutter pub get

# run the dev flavor locally
flutter run -t lib/main_dev.dart
```

Verify analysis/tests

```bash
flutter analyze
flutter test
```

Full usage and developer notes

1) Flavors and entrypoints
 - Entrypoints:
	 - `lib/main_dev.dart` — dev flavor
	 - `lib/main_staging.dart` — staging flavor
	 - `lib/main_prod.dart` — prod flavor
 - Android productFlavors are configured in `android/app/build.gradle`. To build a flavor APK use:

```bash
flutter build apk --flavor dev -t lib/main_dev.dart
```

2) Signing (release)
 - Create `android/keystore.properties` based on `android/keystore.properties.example` with these keys:
	 - `storeFile` (path relative to `android/`)
	 - `storePassword`
	 - `keyAlias`
	 - `keyPassword`
 - When `keystore.properties` exists, Gradle will use it to sign the release APK.

3) Dependency Injection (GetIt)
 - DI bootstrap is in `lib/core/di.dart`. Call `await init()` early in `main()` (already wired in `lib/main.dart`).
 - Registered services (examples):
	 - `Dio` configured per-flavor (baseUrl from `lib/core/constants.dart`).
	 - `FlutterSecureStorage` registered as a singleton.
	 - `AccountRemoteDataSource` and `AccountRepository` registered.

	Example: retrieve account repository anywhere:

```dart
import 'core/di.dart' as di;
import 'domain/repositories/account_repository.dart';

final repo = di.sl<AccountRepository>();
```

4) Adding new services / datasources
 - Data layer should depend only on domain interfaces. Register implementations in `lib/core/di.dart`.
 - For network calls, prefer injecting `Dio` instance via DI.

5) CI guidance
 - Add steps to run `flutter pub get`, `flutter analyze`, and `flutter build apk --flavor <flavor>`.

6) Notes
 - `EnvConfig.baseUrls` in `lib/core/constants.dart` contains example base URLs per flavor — replace with real endpoints.


```bash
cd /workspaces/digital_bank_container/digital_bank_app
flutter pub get
flutter analyze
flutter build apk --flavor dev -t lib/main_dev.dart -v
```