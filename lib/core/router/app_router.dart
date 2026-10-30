import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/auth/auth_screen.dart';
import '../../presentation/patient/patient_dashboard.dart';
import '../../presentation/staff/staff_dashboard.dart';
import '../../presentation/admin/admin_dashboard.dart';
import '../../presentation/shared/providers.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/beds/presentation/screens/bed_management_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserEntity?>>(
      authStateProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      
      // If we are still loading, don't redirect yet
      if (authState.isLoading) return null;

      // If there's an error (e.g. Firebase failed), fallback to auth screen (Mock mode)
      if (authState.hasError) {
        if (state.uri.toString() == '/auth') return null;
        return '/auth';
      }

      final user = authState.value;
      final path = state.uri.toString();
      final isLoggingIn = path == '/auth';
      final isPublicRoute = path == '/auth' || path == '/' || path == '/onboarding';

      // If not logged in, allow public routes (Splash, Onboarding, Auth), otherwise redirect to auth
      if (user == null) {
        return isPublicRoute ? null : '/auth';
      }

      // If logged in and on auth screen, redirect to appropriate role dashboard
      if (isLoggingIn || state.uri.toString() == '/') {
        switch (user.role) {
          case UserRole.patient:
            return '/patient';
          case UserRole.staff:
            return '/staff';
          case UserRole.admin:
            return '/admin';
        }
      }

      // Role authorization gatekeeping
      if (path.startsWith('/patient') && user.role != UserRole.patient) {
        return '/';
      }
      if (path.startsWith('/staff') && user.role != UserRole.staff) {
        return '/';
      }
      if (path.startsWith('/admin') && user.role != UserRole.admin) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/patient',
        builder: (context, state) {
          final user = ref.read(authStateProvider).value;
          if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return PatientDashboard(user: user);
        },
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) {
          final user = ref.read(authStateProvider).value;
          if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return StaffDashboard(user: user);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) {
          final user = ref.read(authStateProvider).value;
          if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return AdminDashboard(user: user);
        },
      ),
      GoRoute(
        path: '/beds/:hospitalId',
        builder: (context, state) {
          final hospitalId = state.pathParameters['hospitalId']!;
          final deptId = state.uri.queryParameters['dept'];
          final isStaff = state.uri.queryParameters['staff'] == 'true';
          return BedManagementScreen(
            hospitalId: hospitalId,
            departmentId: deptId,
            isStaffMode: isStaff,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
