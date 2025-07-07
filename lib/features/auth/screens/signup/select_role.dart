import 'package:elderly_community/features/auth/screens/signup/signup.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: ECColors.primary,
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: ECSizes.spaceBtwSections),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ECTexts.selectRole,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: ECSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Get.toNamed('/sign_up', arguments: {'role': 'elderly'}),
                child: Text(ECTexts.elderly),
              ),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.white)),
                onPressed: () =>
                    Get.toNamed('/sign_up', arguments: {'role': 'caregiver'}),
                child: Text(ECTexts.caregiver),
              ),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/organiser_sign_up',
                    arguments: {'role': 'event organiser'}),
                child: Text(ECTexts.eventOrganiser),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
