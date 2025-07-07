import 'package:elderly_community/features/auth/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:elderly_community/features/auth/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:elderly_community/features/auth/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../controllers/onboarding/onboarding_controller.dart';
import 'widgets/onboarding_page.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          ///   Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoadingPage(
                image: ECImages.onBoardingImage1,
                title: ECTexts.onBoardingTitle1,
                subTitle: ECTexts.onBoardingSubTitle1,
              ),
              OnBoadingPage(
                image: ECImages.onBoardingImage2,
                title: ECTexts.onBoardingTitle2,
                subTitle: ECTexts.onBoardingSubTitle2,
              ),
              OnBoadingPage(
                image: ECImages.onBoardingImage3,
                title: ECTexts.onBoardingTitle3,
                subTitle: ECTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          ///   Skip Button
          const OnBoardingSkip(),

          /// Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),

          /// Circular Button
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}



