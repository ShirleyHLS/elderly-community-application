import 'package:elderly_community/features/auth/models/user_model.dart';
import 'package:elderly_community/features/user_management/controllers/user_management_controller.dart';
import 'package:elderly_community/features/user_management/screens/widgets/user_text_field.dart';
import 'package:flutter/material.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/validators/validation.dart';

class UserFormScreen extends StatelessWidget {
  const UserFormScreen({super.key, this.user, this.role});

  final UserModel? user;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final UserManagementController controller =
        UserManagementController.instance;

    if (user != null) {
      controller.setUser(user!);
    } else {
      controller.clearFields();
      controller.role.text = role!;
    }

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
          title: Text(user != null ? 'Edit User' : 'New User'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ECSizes.defaultSpace,
              vertical: ECSizes.spaceBtwItems),
          child: Form(
            key: controller.userFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Name
                CustomTextField(
                  label: ECTexts.name,
                  controller: controller.name,
                  icon: Icons.person,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Name', value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Email
                CustomTextField(
                  label: ECTexts.email,
                  controller: controller.email,
                  icon: Icons.email,
                  isReadOnly: user != null,
                  isEnabled: user == null,
                  validator: (value) => ECValidator.validateEmail(value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Phone number
                CustomTextField(
                  label: ECTexts.phoneNo,
                  controller: controller.phoneNumber,
                  icon: Icons.call,
                  keyboardType: TextInputType.number,
                  validator: (value) => ECValidator.validatePhoneNumber(value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Gender
                user != null
                    ? CustomTextField(
                        label: ECTexts.gender,
                        controller: controller.gender,
                        icon: Icons.person,
                        isReadOnly: true,
                        isEnabled: false,
                      )
                    : DropdownButtonFormField<Gender>(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade600),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: ECColors.secondary, width: 1),
                          ),
                          prefixIcon:
                              Icon(Icons.person, color: Colors.grey.shade600),
                          labelText: ECTexts.gender,
                          labelStyle:
                              TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        items: Gender.values
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(
                                    gender.toString().split(".").last,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          controller.gender.text =
                              value.toString().split(".").last;
                        },
                        validator: (value) => ECValidator.validateGender(value),
                      ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// DOB
                CustomTextField(
                  label: ECTexts.dob,
                  controller: controller.dobController,
                  icon: Icons.calendar_today,
                  isReadOnly: true,
                  isEnabled: user == null,
                  onTap: () => controller.pickDate(),
                  validator: (value) =>
                      ECValidator.validateEmptyText('Date of Birth', value),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Password
                user == null
                    ? Column(
                        children: [
                          CustomTextField(
                            label: ECTexts.password,
                            controller: controller.password,
                            icon: Icons.lock,
                            validator: (value) =>
                                ECValidator.validatePassword(value),
                          ),
                          const SizedBox(height: ECSizes.spaceBtwInputFields),
                        ],
                      )
                    : SizedBox.shrink(),

                /// Role
                CustomTextField(
                  label: 'Role',
                  controller: controller.role,
                  icon: Icons.person_outline,
                  isReadOnly: true,
                  isEnabled: false,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Role', value),
                ),
                // DropdownButtonFormField<String>(
                //   decoration: InputDecoration(
                //       enabledBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(12),
                //         borderSide: BorderSide(color: Colors.grey.shade600),
                //       ),
                //       focusedBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(12),
                //         borderSide:
                //             BorderSide(color: ECColors.secondary, width: 1),
                //       ),
                //       prefixIcon: Icon(Icons.person_outline,
                //           color: Colors.grey.shade600),
                //       labelText: 'Role',
                //       labelStyle: TextStyle(fontSize: 14, color: Colors.black)),
                //   value: user?.role,
                //   items: ['elderly', 'caregiver', 'admin', 'event organiser']
                //       .map((role) => DropdownMenuItem(
                //             value: role,
                //             child: Text(
                //               role,
                //               style: TextStyle(fontSize: 14),
                //             ),
                //           ))
                //       .toList(),
                //   onChanged: (value) {
                //     controller.role.text = value.toString();
                //   },
                //   validator: (value) =>
                //       ECValidator.validateEmptyText('Role', value),
                // ),
                SizedBox(height: ECSizes.spaceBtwSections),

                /// Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => user != null
                          ? controller.editUser(user!.id.toString())
                          : controller.addUser(),
                      child: const Text(ECTexts.save)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
