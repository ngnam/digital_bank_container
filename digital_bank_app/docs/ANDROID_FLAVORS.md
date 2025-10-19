Android flavors setup (guidance)

This project provides Flutter entrypoints for flavors at `lib/main_dev.dart`, `lib/main_staging.dart`, and `lib/main_prod.dart`.

To enable Android product flavors, open `android/app/build.gradle` and add a `productFlavors` block inside the `android {}` section like this:

```groovy
android {
    // ... existing config
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        prod {
            dimension "environment"
        }
    }
}
```

Then build with the flavor and target file:

```bash
flutter build apk --flavor dev -t lib/main_dev.dart -v
flutter build apk --flavor staging -t lib/main_staging.dart
flutter build apk --flavor prod -t lib/main_prod.dart
```

If you use signing configurations, ensure each flavor references proper signing configs in `build.gradle`.

### Cài đặt gh cli
```
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" | \
sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

```
