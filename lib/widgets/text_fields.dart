import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/texts.dart';

Widget authTextField({
  required TextEditingController controller,
  required String label,
  // required IconData icon,
  required Size size,
  required String? Function(String?) validator,
  void Function(String?)? onSaved,
  bool obscureText = false,
}) {
  return SizedBox(
    height: size.height*0.06,
    width: size.width*0.85,
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        label: reusableText(
          text: label,
          color: AppColors.bodyTextColor.withAlpha(126),
        ),
        // prefixIcon: SizedBox(
        //   width: 40,
        //   child: Center(
        //     child: FaIcon(
        //       icon,
        //       color: AppColors.bodyTextColor.withAlpha(126),
        //       size: 20,
        //     ),
        //   ),
        // ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide:  BorderSide(color: AppColors.bodyTextColor.withAlpha(126)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide:  BorderSide(color: AppColors.secondaryAccentColor),
        ),
        filled: true,
        fillColor: AppColors.bodyTextColor.withAlpha(39),
      ),
      style: TextStyle(
        fontFamily: montserratRegular,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.bodyTextColor
      ),
      cursorColor: AppColors.bodyTextColor.withAlpha(126),
      validator: validator, // ✅ uses the passed-in function
      onSaved: onSaved,
    ),
  );
}
