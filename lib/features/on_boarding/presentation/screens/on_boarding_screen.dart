
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nvidiaapp/core/navigation/app_navigation.dart';
import 'package:nvidiaapp/features/on_boarding/storage/onboarding_storage.dart';
import 'package:nvidiaapp/core/theme/app_theme.dart';
import 'package:nvidiaapp/features/auth/auth_gate.dart';
import 'package:nvidiaapp/features/on_boarding/controller/onboarding_controller.dart';
import 'package:nvidiaapp/features/on_boarding/presentation/widget/onboarding_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

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
                  itemCount: controller.onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = controller.onboardingData[index];

                    return OnboardingContent(
                      image: data["image"]!,
                      title: data["title"]!,
                      description: data["description"]!,
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => TextButton(
                        onPressed: controller.currentPage.value == 0
                            ? null
                            : controller.previousPage,
                        child: const Text("Back"),
                      ),
                    ),
 
                    Obx(
                      () => TextButton(
                        onPressed: () {
                          if (controller.currentPage.value ==
                              controller.onboardingData.length - 1) {
                            Get.offAll(() => const AppNavigation());
                          } else {
                            controller.nextPage();
                          }
                        },
                        child: Text(
                          controller.currentPage.value ==
                                  controller.onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                        ),
                      ),
                    ),
                    Obx(
                      () => TextButton(
                        onPressed: () async {
                          if (controller.currentPage.value ==
                              controller.onboardingData.length - 1) {
                            final userId = Supabase.instance.client.auth.currentUser?.id;

                            if (userId == null) return;

                            await OnboardingStorage.setCompleted(userId);

                            Get.offAll(() => const AuthGate());
                          } else {
                            controller.nextPage();
                          }
                        },
                        child: Text(
                          controller.currentPage.value ==
                                  controller.onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
