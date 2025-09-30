import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:lottie/lottie.dart';

Widget longActionButton({
  required String text,
  required Size size,
  Color? buttonColor,
  Color? textColor,
  VoidCallback? onPressed,
}) {
  double width = size.width * 0.85;
  double height = size.height * 0.06;

  return GestureDetector(
    onTap: onPressed,
    child: Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: buttonColor ?? AppColors.primaryAccentColor,
        borderRadius: BorderRadius.circular(15)
      ),
      child: reusableText(
        text: text,
        fontWeight: FontWeight.w600,
        color: textColor ?? AppColors.bodyTextColor
      )
    ),
  );
}


Widget shortActionButton({
  required String text,
  required Size size,
  Color? buttonColor,
  Color? textColor,
  VoidCallback? onPressed,
}) {
  double width = size.width * 0.33;
  double height = size.height * 0.06;

  return GestureDetector(
    onTap: onPressed,
    child: Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: buttonColor ?? AppColors.primaryAccentColor,
        borderRadius: BorderRadius.circular(15)
      ),
      child: reusableText(
        text: text,
        fontWeight: FontWeight.w600,
        color: textColor
      )
    ),
  );
}


Widget continueWithGoogleButton({
  required Size size,
  VoidCallback? onPressed,
}) {
  double width = size.width * 0.85;
  double height = size.height * 0.06;

  return GestureDetector(
    onTap: onPressed,
    child: Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bodyTextColor,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(googleLogo, width: 20, height: 20, fit: BoxFit.cover),
          SizedBox(width: 5,),
          reusableText(
            text: 'Continue with Google',
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBackgroundColor
          ),
        ],
      )
    ),
  );
}

Widget leadingButton(BuildContext context){
  return GestureDetector(
    onTap:() => context.pop(),
    child: SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: FaIcon(FontAwesomeIcons.chevronLeft, size: 25, color: AppColors.bodyTextColor)),
    ),
  );
}

Widget longLoadingButton({
  required Size size,
  Color? buttonColor,
  Color? iconColor,
}) {
  double width = size.width * 0.85;
  double height = size.height * 0.06;

  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: buttonColor ?? AppColors.primaryAccentColor.withAlpha(179),
      borderRadius: BorderRadius.circular(15)
    ),
    child: Center(child: Lottie.asset(threeDotsLoading, height: height-8)),
  );
}

Widget shortLoadingButton({
  required Size size,
  Color? buttonColor,
  Color? iconColor,
}) {
  double width = size.width * 0.33;
  double height = size.height * 0.06;

  return Container(
    alignment: Alignment.center,
    width: width,
    height: height,
    decoration: BoxDecoration(
        color: buttonColor ?? AppColors.primaryAccentColor.withAlpha(179),
        borderRadius: BorderRadius.circular(15)
    ),
    child: Center(child: Lottie.asset(threeDotsLoading, height: height-8)),
  );
}