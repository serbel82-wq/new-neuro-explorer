import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Конфигурация Firebase для Neuro Explorer.
///
/// ДЛЯ НАСТРОЙКИ:
/// 1. Создайте проект в Firebase Console: https://console.firebase.google.com/
/// 2. Добавьте приложение (Flutter Web)
/// 3. Скачайте google-services.json и добавьте в папку android/app/ (Android)
/// 4. Для Web добавьте конфигурацию ниже
///
/// Инструкция: https://firebase.google.com/docs/flutter/setup
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions не поддерживается для Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions не поддерживается для Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions не поддерживается для этой платформы.',
        );
    }
  }

  /// Конфигурация для Web
  /// Заполните своими данными из Firebase Console > Настройки проекта > Ваши приложения > Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY', // Замените на ваш API Key из Firebase Console
    appId:
        'YOUR_APP_ID', // Замените на ваш App ID (например: 1:123456789:web:abc123...)
    messagingSenderId: 'YOUR_SENDER_ID', // Замените на ваш Sender ID
    projectId: 'YOUR_PROJECT_ID', // Замените на имя вашего проекта
    authDomain:
        'YOUR_PROJECT_ID.firebaseapp.com', // Обычно: [PROJECT_ID].firebaseapp.com
    storageBucket:
        'YOUR_PROJECT_ID.appspot.com', // Обычно: [PROJECT_ID].appspot.com
    databaseURL:
        'https://YOUR_PROJECT_ID.firebaseio.com', // URL Realtime Database (если используется)
  );

  /// Конфигурация для Android
  /// Используйте google-services.json из Firebase Console
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  /// Конфигурация для iOS
  /// Используйте GoogleService-Info.plist из Firebase Console
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID', // Из GoogleService-Info.plist
    iosBundleId: 'com.example.neyroissledovatel', // Из Firebase Console
  );

  /// Конфигурация для macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.neyroissledovatel',
  );
}
