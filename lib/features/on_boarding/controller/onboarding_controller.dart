
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding_image.png",
      "title": "Track Every Medicine",
      "description": "Keep all your TB and chronic disease medications organized in one place, no more guessing what to take.",
    },
    {
      "image": "assets/images/onboarding_2.png",
      "title": "Never Miss a Dose",
      "description": "Alarm-based reminders for every medication, right when you need to take it.",
    },
    {
      "image": "assets/images/onboarding_3.png",
      "title": "Heal With Support",
      "description": "Track your progress and let your family stay updated, so you're never on this journey alone.",
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
