import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth/auth_notifier.dart';
import 'core/state/driver_status_notifier.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/delivery/active_delivery_screen.dart';
import 'features/history/history_screen.dart';
import 'features/earnings/earnings_screen.dart';
import 'core/state/restaurant_notifier.dart';

/// Provider for auth state change notifications to GoRouter.
final authChangeNotifierProvider = Provider<ChangeNotifier>((ref) {
  final notifier = _AuthChangeNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider for GoRouter to prevent recreation on every build.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final notifier = ref.watch(authChangeNotifierProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Shell route for bottom navigation tabs
      ShellRoute(
        builder: (context, state, child) {
          return _AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/earnings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EarningsScreen(),
            ),
          ),
        ],
      ),
      // Active delivery is a full-screen route, NOT inside the shell
      // FCM Deep-Link Contract (Decision 7):
      // Notification payload MUST include "delivery_id".
      GoRoute(
        path: '/delivery/:deliveryId',
        builder: (context, state) {
          final deliveryId = state.pathParameters['deliveryId']!;
          return ActiveDeliveryScreen(deliveryId: deliveryId);
        },
      ),
    ],
    redirect: (context, state) {
      final isLoading = authState is AuthLoading;
      final isAuthenticated = authState is Authenticated;
      final isOnLoginPage = state.matchedLocation == '/login';
      final intendedLocation = state.matchedLocation;

      if (isLoading) return null;

      if (!isAuthenticated && !isOnLoginPage) {
        final query = intendedLocation != '/home' ? '?redirect=$intendedLocation' : '';
        return '/login$query';
      }

      if (isAuthenticated && isOnLoginPage) {
        final redirectParam = state.uri.queryParameters['redirect'];
        if (redirectParam != null &&
            RegExp(r'^/delivery/[0-9a-f-]{36}$').hasMatch(redirectParam)) {
          return redirectParam;
        }
        return '/home';
      }

      return null;
    },
  );
});

/// Main app widget — GoRouter setup, theming, auth redirect.
///
/// PRD_Driver.md §3, §5 (first screen after login)
class RestaurantDirectDriverApp extends ConsumerWidget {
  const RestaurantDirectDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Initialize driver status and restaurant features after successful auth
    if (authState is Authenticated) {
      final driverStatus = ref.read(driverStatusProvider);
      if (!driverStatus.isInitialized) {
        _initializeSession(ref, authState);
      }
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Restaurant Direct Driver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> _initializeSession(WidgetRef ref, Authenticated auth) async {
    try {
      await ref.read(driverStatusProvider.notifier).initialize(
            driverId: auth.driverId,
            restaurantId: auth.restaurantId,
          );

      await ref.read(restaurantFeaturesProvider.notifier).fetchFeatures(
            auth.restaurantId,
          );
    } catch (e) {
      if (kDebugMode) {
        print('[App] Initialization failed: $e');
      }
    }
  }
}

/// App shell with bottom navigation bar.
///
/// PRD_Driver.md §5/§8/§9: Home, History, Earnings tabs.
/// PRD_Driver.md §15 Invariant #8: Earnings tab HIDDEN when disabled.
class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PRD §15 Invariant #8: Earnings tab HIDDEN when disabled.
    // Default to hidden while features are loading — don't block Home/History.
    final features = ref.watch(restaurantFeaturesProvider);
    final earningsEnabled = features?.earningsEnabled ?? false;

    final currentIndex = _calculateSelectedIndex(context, earningsEnabled);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            _onItemTapped(context, index, earningsEnabled),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          // PRD §15 Invariant #8: Earnings tab HIDDEN (not disabled)
          if (earningsEnabled)
            const NavigationDestination(
              icon: Icon(Icons.attach_money_outlined),
              selectedIcon: Icon(Icons.attach_money),
              label: 'Earnings',
            ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context, bool earningsEnabled) {
    final location = GoRouterState.of(context).matchedLocation;
    if (earningsEnabled && location.startsWith('/earnings')) return 2;
    if (location.startsWith('/history')) return 1;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index, bool earningsEnabled) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        if (earningsEnabled) context.go('/earnings');
        break;
    }
  }
}

/// Listenable wrapper for auth state changes — triggers GoRouter refresh.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
}