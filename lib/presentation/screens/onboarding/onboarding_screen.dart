import 'package:flutter/material.dart';
import 'package:nvidiaapp/presentation/screens/onboarding/widget/onboarding_content.dart';
import 'package:nvidiaapp/presentation/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primary, Colors.white, Colors.white, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = 0;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) => buildOnBoardingContent(
                    image: _onboardingData[index]["image"]!,
                    title: _onboardingData[index]["title"]!,
                    description: _onboardingData[index]["description"]!,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
