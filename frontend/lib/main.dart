import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/storage/local_storage_service.dart';
import 'core/ads/ad_service.dart';
import 'core/billing/billing_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline LocalStorage
  await localStorageService.init();

  // Set immersive status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.areia,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  localStorageService.onActivityCompleted = adService.recordActivityCompleted;

  runApp(const SorteFeitaApp());

  // Publicidade e billing iniciam depois do primeiro frame e falham isolados.
  // O SDK de anúncios só carrega após resolver o consentimento (UMP).
  Future.microtask(() async {
    await billingService.init();
    await adService.init();
  });
}

class SorteFeitaApp extends StatelessWidget {
  const SorteFeitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localStorageService,
      builder: (context, _) {
        ThemeMode mode = ThemeMode.light;
        if (localStorageService.themeMode == 'dark') {
          mode = ThemeMode.dark;
        } else if (localStorageService.themeMode == 'system') {
          mode = ThemeMode.system;
        }

        return MaterialApp(
          title: 'Sorte Feita',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
