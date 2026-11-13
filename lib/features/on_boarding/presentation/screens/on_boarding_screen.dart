
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:nvidiaapp/features/auth/auth_gate.dart';
import 'package:nvidiaapp/features/on_boarding/storage/onboarding_storage.dart';
import 'package:nvidiaapp/features/on_boarding/controller/onboarding_controller.dart';
import 'package:nvidiaapp/features/on_boarding/presentation/widget/onboarding_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  final List<Map<String, String>> onboardingData = const [
    {
      'image': 'lib/assets/images/onboarding_image.png',
      'title': 'Track Your Expenses',
      'description':
          'Keep track of your daily expenses and understand where your money goes.',
    },
    {
      'image': 'lib/assets/images/onboarding_image.png',
      'title': 'Manage Your Budget',
      'description':
          'Set spending limits, manage your budget, and stay in control of your finances.',
    },
    {
      'image': 'lib/assets/images/onboarding_image.png',
      'title': 'Reach Your Financial Goals',
      'description':
          'Build better financial habits and turn your saving goals into reality.',
    },
  ];

  Future<void> _handleButton() async {
    final isLastPage =
        controller.currentPage.value == onboardingData.length - 1;

    if (!isLastPage) {
      controller.nextPage();
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return;

    await OnboardingStorage.setCompleted(userId);

    Get.offAll(() => const AuthGate());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary,
            Colors.white,
            Colors.white,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = onboardingData[index];

                    return OnboardingContent(
                      image: data['image']!,
                      title: data['title']!,
                      description: data['description']!,
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Obx(() {
                    final isLastPage =
                        controller.currentPage.value ==
                            onboardingData.length - 1;

                    return ElevatedButton(
                      onPressed: _handleButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
