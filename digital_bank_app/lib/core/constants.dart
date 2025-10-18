enum Flavor { dev, staging, prod }

class AppConstants {
  static const appName = 'Digital Bank';
}

class EnvConfig {
  static const Map<Flavor, String> baseUrls = {
    Flavor.dev: 'https://dev-api.example.com',
    Flavor.staging: 'https://staging-api.example.com',
    Flavor.prod: 'https://api.example.com',
  };
}

// Current flavor will be set by the flavor entrypoint before DI/init
late Flavor currentFlavor;
