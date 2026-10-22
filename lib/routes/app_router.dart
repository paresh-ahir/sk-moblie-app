import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/storage/token_storage.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/about/about_screen.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/features/auth/screens/email_sent_screen.dart';
import 'package:saleskido/features/auth/screens/forgot_password_screen.dart';
import 'package:saleskido/features/auth/screens/login_screen.dart';
import 'package:saleskido/features/auth/screens/set_password_screen.dart';
import 'package:saleskido/features/auth/screens/signup_screen.dart';
import 'package:saleskido/features/dashboard/main_shell.dart';
import 'package:saleskido/features/leads/screens/add_lead_screen.dart';
import 'package:saleskido/features/leads/screens/lead_detail_screen.dart';
import 'package:saleskido/features/notifications/notifications_screen.dart';
import 'package:saleskido/features/onboarding/onboarding_screen.dart';
import 'package:saleskido/features/quotations/screens/quotation_detail_screen.dart';
import 'package:saleskido/features/reports/screens/reports_screen.dart';
import 'package:saleskido/features/whatsapp/screens/chat_screen.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (!auth.initialized && loc != '/splash') return '/splash';
      if (!auth.initialized) return null;

      final loggingIn = loc == '/login' ||
          loc == '/signup' ||
          loc == '/onboarding' ||
          loc == '/forgot-password' ||
          loc == '/reset-link-sent' ||
          loc == '/email-sent' ||
          loc.startsWith('/set-password') ||
          loc == '/password-changed' ||
          loc == '/splash';

      if (!auth.isAuthenticated && !loggingIn) return '/login';
      if (auth.isAuthenticated &&
          (loc == '/login' || loc == '/signup' || loc == '/onboarding')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/email-sent',
        builder: (_, state) => EmailSentScreen(
          email: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-link-sent',
        builder: (_, state) => ResetLinkSentScreen(
          email: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: '/set-password',
        builder: (_, state) {
          final q = state.uri.queryParameters;
          return SetPasswordScreen(
            token: q['token'] ?? state.extra as String?,
            isReset: q['reset'] == '1',
          );
        },
      ),
      GoRoute(
        path: '/password-changed',
        builder: (_, __) => const PasswordChangedScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return MainShell(initialTab: tab);
        },
      ),
      GoRoute(
        path: '/add-lead',
        builder: (_, __) => const AddLeadScreen(),
      ),
      GoRoute(
        path: '/lead-detail',
        builder: (_, state) => LeadDetailScreen(
          leadId: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: '/quotation-detail',
        builder: (_, state) => QuotationDetailScreen(
          id: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: '/chat',
        builder: (_, state) => ChatScreen(
          args: Map<String, dynamic>.from((state.extra as Map?) ?? {}),
        ),
      ),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    await auth.loadSession();
    final seen = await TokenStorage().isOnboardingSeen();
    if (!mounted) return;
    if (!seen) {
      context.go('/onboarding');
    } else if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SalesKido',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
