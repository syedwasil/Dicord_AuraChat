import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/auth/presentation/profile_screen.dart';
import '../features/home/presentation/friends_screen.dart';
import '../features/auth/presentation/login_screen.dart';

import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

/// A notifier that simply triggers a refresh when the auth state changes.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final auth = authState.value;
      final isAuth = auth != null;
      final isLoading = authState.isLoading;

      // The current location
      final location = state.matchedLocation;

      // If we are loading and NOT already at a screen that handles its own loading (like Login/Register/Splash)
      // then we can go to splash. But usually, we only want splash for the initial app start.
      if (isLoading && location == '/splash') {
        return null; // Stay at splash until loading finishes
      }

      final isLoggingIn = location == '/login' || location == '/register';

      // --- Not Authenticated ---
      if (!isAuth) {
        // If we're at splash and finished loading, or somehow elsewhere, go to login
        if (!isLoading && !isLoggingIn) {
          return '/login';
        }
        // If we are logging in or already at splash, stay there
        return null;
      }

      // --- Authenticated ---
      if (isAuth && (isLoggingIn || location == '/splash')) {
        return '/';
      }

      return null;
    },
  );
});
