import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../presentation/screens/auth/login_screen.dart';

/// Widget que verifica autenticación antes de mostrar contenido
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Mostrar loading mientras se inicializa
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si está autenticado, mostrar el contenido
    if (authState.isAuthenticated) {
      return child;
    }

    // Si no está autenticado, mostrar fallback o login
    return fallback ?? const LoginScreen();
  }
}

/// Widget especializado para el onboarding
class OnboardingGuard extends ConsumerWidget {
  final Widget onboardingFlow;
  final Widget authenticatedFlow;

  const OnboardingGuard({
    super.key,
    required this.onboardingFlow,
    required this.authenticatedFlow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Mostrar loading mientras se verifica el estado
    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si ya está autenticado, saltar onboarding
    if (authState.isAuthenticated) {
      return authenticatedFlow;
    }

    // Si no está autenticado, mostrar onboarding
    return onboardingFlow;
  }
}