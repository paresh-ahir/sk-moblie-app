import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saleskido/core/storage/token_storage.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardData(
      icon: Icons.people_alt_rounded,
      title: 'Manage leads, maximize revenue',
      subtitle:
          'Seamlessly capture, track, and organize leads from multiple sources, ensuring no opportunity is missed.',
    ),
    _OnboardData(
      icon: Icons.request_quote_rounded,
      title: 'Create, and share professional quotations',
      subtitle:
          'Create, customize, and share quotes easily, streamlining your sales process and communication with clients.',
    ),
    _OnboardData(
      icon: Icons.chat_rounded,
      title: 'Integrated WhatsApp Business API',
      subtitle:
          'Effortlessly manage customer interactions with advanced WhatsApp chat functionalities.',
    ),
    _OnboardData(
      icon: Icons.rocket_launch_rounded,
      title: 'Maximize sales potential with SalesKido',
      subtitle:
          'Grow your sales 4X and unlock success with SalesKido’s powerful features!',
    ),
  ];

  Future<void> _finish() async {
    await TokenStorage().setOnboardingSeen(true);
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.onboardingGradientStart,
              AppColors.onboardingGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final page = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const Spacer(),
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(page.icon, size: 80, color: Colors.white),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 18,
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                child: SkButton(
                  label: isLast ? 'Get Started' : 'Next',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardData {
  const _OnboardData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
}
