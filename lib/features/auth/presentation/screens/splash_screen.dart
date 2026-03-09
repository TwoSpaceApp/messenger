import 'package:flutter/material.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';

class SplashScreen extends StatelessWidget {
  static const List<String> _orderedSteps = [
    'Environment Loading',
    'Sentry Error Tracking',
    'Environment Validation',
    'Settings Service',
    'Aegis Session Restoration',
  ];

  final String? currentStep;
  final double? progress;

  const SplashScreen({
    super.key,
    this.currentStep,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = (progress ?? 0).clamp(0.0, 1.0);
    final activeStep = _presentableStep(currentStep);
    final activeIndex = _orderedSteps.indexOf(currentStep ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const Hero(
                tag: 'app_logo',
                child: AppLogo(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Secure messenger startup',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(flex: 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeStep,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Этап ${activeIndex >= 0 ? activeIndex + 1 : 1}/${_orderedSteps.length}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: normalizedProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8A7CFF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_orderedSteps.length, (index) {
                      final label = _presentableStep(_orderedSteps[index]);
                      final isDone = normalizedProgress >=
                          ((index + 1) / _orderedSteps.length);
                      final isCurrent = !isDone && index == activeIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              isDone
                                  ? Icons.check_circle_rounded
                                  : isCurrent
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                              size: 16,
                              color: isDone
                                  ? const Color(0xFF7CFFB2)
                                  : isCurrent
                                      ? const Color(0xFF8A7CFF)
                                      : Colors.white24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isDone || isCurrent
                                      ? Colors.white
                                      : Colors.white38,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  static String _presentableStep(String? step) {
    switch (step) {
      case 'Environment Loading':
        return 'Подготовка окружения';
      case 'Sentry Error Tracking':
        return 'Запуск обработки ошибок';
      case 'Environment Validation':
        return 'Проверка конфигурации';
      case 'Settings Service':
        return 'Загрузка настроек';
      case 'Aegis Session Restoration':
        return 'Восстановление сессии';
      default:
        return 'Запуск приложения';
    }
  }
}
