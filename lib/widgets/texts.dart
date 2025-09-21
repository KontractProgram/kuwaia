import 'package:flutter/material.dart';
import 'package:kuwaia/system/constants.dart';

Widget reusableText({
  required String text,
  double? fontSize,
  String? fontFamily,
  FontWeight? fontWeight,
  Color? color,
  TextAlign? textAlign,
  int? maxLines,
  TextOverflow? overflow
}) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: fontFamily ?? montserratRegular,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.bodyTextColor,
    ),
    textAlign: textAlign ?? TextAlign.center,
    maxLines: maxLines ?? 3,
    overflow: overflow ?? TextOverflow.ellipsis,
  );
}