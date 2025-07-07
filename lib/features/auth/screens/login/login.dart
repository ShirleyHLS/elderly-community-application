import 'package:elderly_community/common/curved_edges.dart';
import 'package:elderly_community/features/auth/controllers/login/login_controller.dart';
import 'package:elderly_community/features/auth/screens/signup/select_role.dart';
import 'package:elderly_community/features/auth/screens/signup/signup.dart';
import 'package:elderly_community/utils/constants/colors.dart';
import 'package:elderly_community/utils/constants/image_strings.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/social_buttons.dart';
import '../../../../utils/constants/sizes.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomCurvedEdgeWidget(
                child: Container(
                  color: ECColors.primary,
                  height: 200,
                  child: Center(
                    child: Image(
                      image: AssetImage(ECImages.appLogo),
                      height: 120,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ECSizes.spaceBtwItems),
              Text('Login', style: Theme.of(context).textTheme.headlineLarge),
              Text('Sign in to continue.',
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: ECSizes.spaceBtwSections),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ECSizes.spaceBtwSections),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// Email
                      TextFormField(
                        controller: controller.email,
                        validator: (value) => ECValidator.validateEmail(value),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: ECTexts.email,
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// Password
                      Obx(
                        () => TextFormField(
                          controller: controller.password,
                          validator: (value) =>
                              ECValidator.validateEmptyText('Password', value),
                          obscureText: controller.isPasswordHidden.value,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                                onPressed: () =>
                                    controller.togglePasswordVisibility(),
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                )),
                            labelText: ECTexts.password,
                          ),
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields / 2),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.85, // Adjust size if needed
                                child: Obx(
                                  () => Checkbox(
                                    value: controller.rememberMe.value,
                                    onChanged: (value) => controller.rememberMe
                                        .value = !controller.rememberMe.value,
                                    visualDensity: VisualDensity.compact, // Reduce padding
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                              const Text(ECTexts.rememberMe),
                            ],
                          ),

                          /// Forget Password
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              ECTexts.forgetPassword,
                              style: TextStyle(color: ECColors.buttonPrimary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ECSizes.spaceBtwSections),

                      /// Sign in button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => controller.emailAndPasswordSignIn(_formKey),
                          child: const Text(ECTexts.logIn),
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwItems),

                      /// Sign up button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed('/select_role'),
                          child: const Text(ECTexts.createAccount),
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwSections),

                      Text(
                        '--- or Sign In With ---',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      SizedBox(height: ECSizes.spaceBtwItems / 2),
                      SocialButtons(),
                    ],
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
