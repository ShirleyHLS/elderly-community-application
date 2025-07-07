import 'package:elderly_community/common/curved_app_bar.dart';
import 'package:elderly_community/features/auth/controllers/signup/signup_controller.dart';
import 'package:elderly_community/features/auth/screens/login/login.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/social_buttons.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/text_strings.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.put(SignUpController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.offAll(LoginScreen()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ECSizes.defaultSpace,
              vertical: ECSizes.spaceBtwItems),
          child: Form(
            key: controller.signUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Create new account',
                    style: Theme.of(context).textTheme.headlineMedium),
                // Text('Already registered? Log in here',
                //     style: Theme.of(context).textTheme.bodySmall),
                SizedBox(height: ECSizes.spaceBtwSections),

                /// Name
                TextFormField(
                  controller: controller.name,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Name', value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: ECTexts.name,
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

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

                /// Phone number
                TextFormField(
                  controller: controller.phoneNumber,
                  validator: (value) => ECValidator.validatePhoneNumber(value),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.call),
                    labelText: ECTexts.phoneNo,
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Gender
                DropdownButtonFormField<Gender>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: ECTexts.gender,
                  ),
                  items: Gender.values
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender.toString().split(".").last),
                          ))
                      .toList(),
                  onChanged: (value) {
                    controller.gender.text = value.toString().split(".").last;
                  },
                  validator: (value) => ECValidator.validateGender(value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// DOB
                Obx(
                  () => TextFormField(
                    readOnly: true,
                    controller: controller.dobController.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today),
                      labelText: ECTexts.dob,
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      await controller.selectDate(context);
                    },
                    validator: (value) =>
                        ECValidator.validateEmptyText('Date of birth', value),
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Password
                Obx(
                  () => TextFormField(
                    validator: (value) => ECValidator.validatePassword(value),
                    controller: controller.password,
                    obscureText: controller.isPasswordHidden.value,
                    // expands: false,
                    decoration: InputDecoration(
                        labelText: ECTexts.password,
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                            onPressed: () =>
                                controller.togglePasswordVisibility(),
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ))),
                  ),
                ),
                const SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Confirmed Password
                Obx(
                  () => TextFormField(
                    validator: (value) => ECValidator.validateConfirmedPassword(
                        value, controller.password.text),
                    controller: controller.confirmedPassword,
                    // expands: false,
                    obscureText: controller.isConfirmPasswordHidden.value,
                    decoration: InputDecoration(
                        labelText: ECTexts.confirmedPassword,
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                            onPressed: () =>
                                controller.toggleConfirmPasswordVisibility(),
                            icon: Icon(
                              controller.isConfirmPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ))),
                  ),
                ),
                const SizedBox(height: ECSizes.spaceBtwSections),

                /// Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => controller.signUp(),
                      child: const Text(ECTexts.createAccount)),
                ),
                const SizedBox(height: ECSizes.spaceBtwSections),

                Text(
                  '--- or Sign Up With ---',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                SizedBox(height: ECSizes.spaceBtwItems / 2),
                SocialButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
