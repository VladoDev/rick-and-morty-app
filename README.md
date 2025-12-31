# Rick and Morty App

App Flutter para explorar personajes, ver detalles y gestionar favoritos a partir de la API de Rick y Morty.

![Simulator Screen Recording - iPhone 17 Pro Max - 2025-12-31 at 16 55 01](https://github.com/user-attachments/assets/7f8a9024-5bdc-4a60-9108-980b092be5e2)

## Requisitos
- Flutter >= 3.10.0
- Dart >= 3.10.0
- Android SDK (Android Studio / command-line tools)
- Xcode + CocoaPods (para iOS)

## Ejecución
```bash
flutter pub get
flutter run
```

Plataformas soportadas
Android: API 21+ (Android 5.0+), teléfono y tablet
iOS: 11.0+, iPhone y iPad

Arquitectura y librerías

Clean Architecture: escalabilidad y separación clara de responsabilidades.
Riverpod: estado simple y fácil de entender para equipos mixtos.
Sqflite: base de datos local con consultas SQL.
GoRouter: navegación declarativa estándar en Flutter.
GetIt: service locator centralizado para inyección de dependencias.
CachedNetworkImage: cache de imágenes y soporte para hero animation.
Url Launcher: abrir URLs recibidas desde la API.
Dio: cliente HTTP para consumo de API.
Testing: mocktail, network_image_mock y sqflite_common_ffi para mocks.


