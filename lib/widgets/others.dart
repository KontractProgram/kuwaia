import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/system/constants.dart';

Widget glowingIcon({
  required IconData icon,
  required bool isActive,
  double? size,
}) {
  if (!isActive) {
    return FaIcon(
      icon,
      size: size ?? 25,
      color: AppColors.bodyTextColor.withAlpha(150),
    );
  }

  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppColors.dashaSignatureColor.withAlpha(150),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Center(child: FaIcon(
        icon,
        size: size != null ? size+size*0.2 : 30,
        color: AppColors.dashaSignatureColor
    )),
  );
}