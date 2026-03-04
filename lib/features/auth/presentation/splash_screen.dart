import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Navigate based on auth state
    ref.listen(authStateProvider, (prev, next) {
      if (!next.isLoading) {
        if (next.value != null) {
          context.go('/');
        } else {
          context.go('/login');
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AuraTheme.loginGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AuraTheme.brandGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AuraTheme.brandColor.withValues(alpha: 0.6),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'AuraChat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect with your community',
                style: TextStyle(color: AuraTheme.textMuted, fontSize: 15),
              ),
              const SizedBox(height: 48),
              if (authState.isLoading)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AuraTheme.brandLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
