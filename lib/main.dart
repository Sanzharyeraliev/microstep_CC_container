import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'design_system.dart';
import 'pages/home_page.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

const bool isInDebugMode = bool.fromEnvironment('dart.vm.product', defaultValue: false) == false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ВРЕМЕННО: пропускаем SQLite для веб-платформы
  if (!kIsWeb) {
    // Инициализация базы данных (только не веб)
    await DatabaseService().database;
  } else {
    debugPrint('⚠️ SQLite временно отключен для веб-сборки');
  }

  // Инициализация Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }

  // Загружаем .env файл
  try {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      debugPrint('✅ Gemini API key loaded');
    } else {
      debugPrint('⚠️ Gemini API key is empty, using mock AI');
    }
  } catch (e) {
    debugPrint('⚠️ .env file not found, using mock AI');
  }

  // Устанавливаем статус-бар
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Инициализация сервиса уведомлений
  await NotificationService().initialize();
  
  // Инициализация FCM и получение токена (только не веб)
  if (!kIsWeb) {
    await _initFCM();
  } else {
    debugPrint('⚠️ FCM временно отключен для веб-сборки');
  }

  // Запуск приложения
  runApp(
    isInDebugMode
        ? DevicePreview(
            enabled: true,
            builder: (context) => const MicroStepApp(),
          )
        : const MicroStepApp(),
  );
}

/// Инициализация Firebase Cloud Messaging
Future<void> _initFCM() async {
  try {
    final messaging = FirebaseMessaging.instance;
    
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    final String? token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('📱 FCM Token: $token');
      try {
        await DatabaseService().setSetting('fcm_token', token);
        debugPrint('✅ FCM token saved to database');
      } catch (e) {
        debugPrint('⚠️ Could not save FCM token: $e');
      }
    } else {
      debugPrint('⚠️ FCM Token is null or empty');
    }
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Received message in foreground');
      final title = message.notification?.title ?? 'MicroStep';
      final body = message.notification?.body ?? '';
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: body,
        type: NotificationType.learn,
      );
    });
    
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('📨 App opened from terminated state by notification');
    }
    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📨 App opened from background by notification');
    });
  } catch (e) {
    debugPrint('❌ FCM initialization failed: $e');
  }
}

class MicroStepApp extends StatelessWidget {
  const MicroStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MicroStep',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      home: const HomePage(),
      builder: (context, child) {
        if (isInDebugMode && DevicePreview.isEnabled(context)) {
          return DevicePreview.appBuilder(context, child);
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextTheme.textTheme,
      scaffoldBackgroundColor: AppColors.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: AppColors.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(
          color: AppColors.outlineVariant,
          fontSize: 14,
        ),
      ),
    );
  }
}