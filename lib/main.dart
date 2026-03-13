import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/core/config/environment.dart';
import 'package:two_space_app/core/config/theme_builder.dart';
import 'package:two_space_app/core/constants/app_colors.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/navigation/app_router.dart';
import 'package:two_space_app/core/services/dev_tools_service.dart';
import 'package:two_space_app/core/services/initialization_service.dart';
import 'package:two_space_app/core/services/sentry_service.dart';
import 'package:two_space_app/core/widgets/dev_fab.dart';
import 'package:two_space_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_listener.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupErrorHandlers();
  ErrorWidget.builder = _buildErrorWidget;

  runApp(
    const ProviderScope(
      child: AppBootstrapper(),
    ),
  );
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  AppBootstrapperState createState() => AppBootstrapperState();
}

class AppBootstrapperState extends State<AppBootstrapper> {
  InitializationResult? _initResult;
  String _currentStep = 'Starting...';
  double _progress = 0;
  DateTime _lastProgressUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _progressUiThrottle = Duration(milliseconds: 140);

  @override
  void initState() {
    super.initState();
    _startInit();
  }

  Future<void> _startInit() async {
    final result = await InitializationService.initialize(
      onProgress: (stepName, progress) {
        final now = DateTime.now();
        final canUpdateByTime =
            now.difference(_lastProgressUiUpdate) >= _progressUiThrottle;
        final shouldForceUpdate = progress >= 1.0 ||
            (_currentStep != stepName && progress > _progress);
        if (!canUpdateByTime && !shouldForceUpdate) {
          return;
        }
        _lastProgressUiUpdate = now;
        setState(() {
          _currentStep = stepName;
          _progress = progress;
        });
      },
    );
    if (mounted) {
      setState(() {
        _initResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initResult == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        locale: Locale(SettingsService.languageNotifier.value),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(
          currentStep: _currentStep,
          progress: _progress,
        ),
      );
    }
    return TwoSpaceApp(initializationResult: _initResult!);
  }
}

void _setupErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    SentryService.captureException(
      details.exception,
      stackTrace: details.stack,
      hint: {'flutter_error': true},
    );
  };

  // Catch errors outside Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    SentryService.captureException(
      error,
      stackTrace: stack,
      hint: {'platform_error': true},
    );
    return true;
  };
}

/// Build custom error widget (with hardcoded English text for reliability)
Widget _buildErrorWidget(FlutterErrorDetails details) {
  final msg = details.exceptionAsString();
  return MaterialApp(
    home: Scaffold(
      backgroundColor: AppColors.backgroundError,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Application Error', // Hardcoded English text
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  msg,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class TwoSpaceApp extends ConsumerWidget {
  const TwoSpaceApp({
    required this.initializationResult,
    super.key,
  });
  final InitializationResult initializationResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show critical initialization errors
    if (initializationResult.hasFailures) {
      final criticalFailures = initializationResult.failures
          .where((f) => f.stepName.contains('Critical'))
          .toList();

      if (criticalFailures.isNotEmpty && !kDebugMode) {
        return _buildInitializationErrorApp(criticalFailures);
      }
    }

    final goRouter = ref.watch(routerProvider);
    final appSettingsListenable = Listenable.merge(<Listenable>[
      SettingsService.languageNotifier,
      SettingsService.themeNotifier,
      SettingsService.paleVioletNotifier,
      SettingsService.themeModeNotifier,
      SettingsService.textScaleNotifier,
      DevToolsService.performanceOverlayEnabled,
    ]);

    return AnimatedBuilder(
      animation: appSettingsListenable,
      builder: (context, _) {
        final languageCode = SettingsService.languageNotifier.value;
        final settings = SettingsService.themeNotifier.value;
        final paleVioletEnabled = SettingsService.paleVioletNotifier.value;
        final themeMode = SettingsService.themeModeNotifier.value;
        final textScale = SettingsService.textScaleNotifier.value;
        final showPerformanceOverlay =
            DevToolsService.performanceOverlayEnabled.value;

        final lightTheme = AppThemeBuilder.build(
          settings,
          paleVioletEnabled,
          brightnessOverride: Brightness.light,
        );
        final darkTheme = AppThemeBuilder.build(
          settings,
          paleVioletEnabled,
          brightnessOverride: Brightness.dark,
        );

        final app = MaterialApp.router(
          title: 'TwoSpace',
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? 'TwoSpace',
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: showPerformanceOverlay,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          locale: Locale(languageCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: goRouter,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: AuthListener(
                child: child ?? const SizedBox(),
              ),
            );
          },
        );

        if (kDebugMode || Environment.enableDevTools) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(children: [app, const DevFab()]),
          );
        }
        return app;
      },
    );
  }

  Widget _buildInitializationErrorApp(List<InitStepResult> failures) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.backgroundError,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Critical Initialization Failure', // Hardcoded English text
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...failures.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${f.stepName}: ${f.error}',
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
