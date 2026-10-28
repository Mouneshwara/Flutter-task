# Create the native Flutter wrapper

This ZIP contains `lib/`, tests, and package configuration. From this directory run:

```bash
flutter create . --platforms=android,ios,web,windows,macos
flutter pub get
flutter test
flutter analyze
flutter run
```

If you already have an empty Flutter project folder, copy these files into that folder, then run `flutter create .` there. Do not run `flutter create` from inside the `flutter/bin` SDK directory.
