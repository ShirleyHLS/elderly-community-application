import 'package:flutter/material.dart';

import '../utils/constants/image_strings.dart';
import '../utils/constants/sizes.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: Image.asset(
            ECImages.google,
            height: ECSizes.iconLg,
          ),
        ),
        SizedBox(width: ECSizes.spaceBtwItems),
        IconButton(
          onPressed: () {},
          icon: Image.asset(
            ECImages.facebook,
            height: ECSizes.iconLg,
          ),
        ),
      ],
    );
  }
}
