import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elderly_community/common/curved_app_bar.dart';
import 'package:elderly_community/features/auth/controllers/signup/signup_controller.dart';
import 'package:elderly_community/features/auth/screens/login/login.dart';
import 'package:elderly_community/utils/constants/sizes.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:elderly_community/utils/constants/text_strings.dart';

import '../../../../utils/constants/colors.dart';

class EventOrganizerSignUpScreen extends StatelessWidget {
  const EventOrganizerSignUpScreen({super.key});

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
            key: controller.organiserSignUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Event Organiser Sign Up',
                    style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: ECSizes.spaceBtwSections),

                /// Organization Name
                TextFormField(
                  controller: controller.name,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Organization Name', value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.business),
                    labelText: 'Organization Name',
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Organization Website
                TextFormField(
                  controller: controller.organisationWebsite,
                  validator: (value) => ECValidator.validateWebsite(value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.web),
                    labelText: 'Organization Website',
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Organization Description
                TextFormField(
                  controller: controller.organisationDescription,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Description', value),
                  maxLines: 3,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.description),
                    labelText: 'Organization Description',
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                Obx(
                  () => TextFormField(
                    readOnly: true,
                    controller: controller.dobController.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today),
                      labelText: "Establishment Date",
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      await controller.selectDate(context);
                    },
                    validator: (value) =>
                        ECValidator.validateEmptyText('Establishment Date', value),
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

                /// Password
                Obx(
                  () => TextFormField(
                    validator: (value) => ECValidator.validatePassword(value),
                    controller: controller.password,
                    obscureText: controller.isPasswordHidden.value,
                    decoration: InputDecoration(
                      labelText: ECTexts.password,
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () => controller.togglePasswordVisibility(),
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Confirmed Password
                Obx(
                  () => TextFormField(
                    validator: (value) => ECValidator.validateConfirmedPassword(
                        value, controller.password.text),
                    controller: controller.confirmedPassword,
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
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ECSizes.spaceBtwInputFields),

                Container(
                  padding: EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: ECColors.light,
                  ),
                  child: Obx(() => Column(
                        children: [
                          // Display selected files
                          controller.selectedFiles.isNotEmpty
                              ? Wrap(
                                  spacing: 8,
                                  children:
                                      controller.selectedFiles.map((file) {
                                    bool isImage = file.path
                                            .toLowerCase()
                                            .endsWith('.png') ||
                                        file.path
                                            .toLowerCase()
                                            .endsWith('.jpg') ||
                                        file.path
                                            .toLowerCase()
                                            .endsWith('.jpeg');

                                    return Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          margin: EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey[200],
                                            image: isImage
                                                ? DecorationImage(
                                                    image: FileImage(file),
                                                    fit: BoxFit.cover)
                                                : null,
                                          ),
                                          child: !isImage
                                              ? Center(
                                                  child: Icon(
                                                      Icons.insert_drive_file,
                                                      size: 40,
                                                      color: Colors.grey[600]))
                                              : null,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.cancel,
                                              color: Colors.red),
                                          onPressed: () => controller
                                              .selectedFiles
                                              .remove(file),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                )
                              : Text(
                                  'Please upload your business registration certificate',
                                  textAlign: TextAlign.center,
                                ),

                          SizedBox(height: ECSizes.spaceBtwItems),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.pickFiles,
                              icon: Icon(Icons.upload),
                              label: Text('Upload Files or Images'),
                            ),
                          ),
                        ],
                      )),
                ),
                const SizedBox(height: ECSizes.spaceBtwSections),

                /// Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.signupAsEventOrganiser(),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
