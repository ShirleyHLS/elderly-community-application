import 'package:elderly_community/common/curved_app_bar.dart';
import 'package:elderly_community/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../controllers/signup/address_controller.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({
    super.key,
    this.canSkip = false,
  });

  final bool? canSkip;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      appBar: CustomCurvedAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text("Complete your profile")),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ECSizes.defaultSpace,
              vertical: ECSizes.spaceBtwItems),
          child: Form(
            key: controller.addressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address Details',
                    style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: ECSizes.spaceBtwSections),

                /// Street
                TextFormField(
                  controller: controller.streetController,
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
                  controller: controller.cityController,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Street', value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_city),
                    labelText: ECTexts.city,
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// State
                DropdownButtonFormField<MalaysianState>(
                  value: controller.selectedState.value,
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
                    controller.selectedState.value = newValue;
                  },
                  validator: (value) =>
                      value == null ? "Please select a state" : null,
                ),
                SizedBox(height: ECSizes.spaceBtwInputFields),

                /// Postcode
                TextFormField(
                  controller: controller.postcodeController,
                  validator: (value) =>
                      ECValidator.validateEmptyText('Postcode', value),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.local_post_office),
                    labelText: ECTexts.postcode,
                  ),
                ),
                SizedBox(height: ECSizes.spaceBtwSections),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => controller.saveAddress(),
                      child: Text(ECTexts.tContinue)),
                ),
                SizedBox(height: ECSizes.spaceBtwItems),
                if (!(canSkip ?? false))
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () => Get.toNamed('/upload_profile_picture'),
                        child: Text(ECTexts.skip)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
