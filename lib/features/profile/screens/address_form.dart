import 'package:elderly_community/features/auth/controllers/signup/address_controller.dart';
import 'package:elderly_community/features/binding/controllers/binding_controller.dart';
import 'package:elderly_community/features/profile/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/curved_app_bar.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/validators/validation.dart';
import '../../auth/models/user_model.dart';

class AddressFormScreen extends StatelessWidget {
  const AddressFormScreen({
    super.key,
    this.ownProfile = true,
  });

  final bool? ownProfile;

  @override
  Widget build(BuildContext context) {
    final addressController = Get.put(AddressController());
    addressController.loadUserAddress(ownProfile!);

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          title: Text('Edit Address'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ECSizes.defaultSpace, vertical: ECSizes.spaceBtwItems),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: addressController.addressEditFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Street
                      TextFormField(
                        controller: addressController.streetController,
                        validator: (value) =>
                            ECValidator.validateEmptyText('Street', value),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.home),
                          labelText: ECTexts.street,
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// City
                      TextFormField(
                        controller: addressController.cityController,
                        validator: (value) =>
                            ECValidator.validateEmptyText('City', value),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_city),
                          labelText: ECTexts.city,
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// State
                      DropdownButtonFormField<MalaysianState>(
                        value: addressController.selectedState.value,
                        decoration: InputDecoration(
                          labelText: "State",
                          prefixIcon: Icon(Icons.map),
                        ),
                        items: MalaysianState.values
                            .map((state) => DropdownMenuItem(
                                  value: state,
                                  child: Text(state.displayName),
                                ))
                            .toList(),
                        onChanged: (MalaysianState? newValue) {
                          addressController.selectedState.value = newValue;
                        },
                        validator: (value) =>
                            value == null ? "Please select a state" : null,
                      ),
                      SizedBox(height: ECSizes.spaceBtwInputFields),

                      /// Postcode
                      TextFormField(
                        controller: addressController.postcodeController,
                        validator: (value) =>
                            ECValidator.validateEmptyText('Postcode', value),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.local_post_office),
                          labelText: ECTexts.postcode,
                        ),
                      ),
                      SizedBox(height: ECSizes.spaceBtwSections),
                    ],
                  ),
                ),
              ),
            ),

            /// Save Button at the bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => addressController.updateAddress(ownProfile!),
                child: Text(ECTexts.save),
              ),
            ),
            SizedBox(height: ECSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}
