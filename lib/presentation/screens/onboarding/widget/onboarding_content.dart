import 'package:flutter/material.dart';
import 'package:nvidiaapp/presentation/theme/app_theme.dart';

class buildOnBoardingContent extends StatelessWidget {
  buildOnBoardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Image
          Container(
            height: 340,
            alignment: Alignment.center,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, StackTrace) {
                // If image isnt supported/not loaded
                return const Icon(
                  Icons.image_not_supported_outlined,
                  size: 100,
                  color: Colors.grey,
                );
              },
            ),
          ),
          SizedBox(height: 40),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondary,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
