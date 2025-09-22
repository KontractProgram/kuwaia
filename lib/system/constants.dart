import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppColors {
  static final Color primaryBackgroundColor = Color(0xFF121212);
  static final Color secondaryBackgroundColor = Color(0xFF1E1E1E);
  static final Color primaryAccentColor = Color(0xFF00A3FF);
  static final Color secondaryAccentColor = Color(0xFF8087C0);
  static final Color dashaSignatureColor = Color(0xFFFF6B81);
  static final Color bodyTextColor = Color(0xFFEAEAEA);
  static final Color headingTextColor = Color(0xFFFFFFFF);
  static final Color warningColor = Color(0xFFFF1111);
  static final Color confirmColor = Color(0xFF00FF11);
}

//images
const authBg = "assets/images/auth_bg.jpg";
const logoTrans = "assets/images/logo_trans.png";
const googleLogo = "assets/images/google.png";
const youtubeLogo = "assets/images/youtube_logo.png";

//fonts
const montserratRegular = "assets/fonts/Montserrat-Regular.ttf";


//animations
const threeDotsLoading = "assets/anim/loading.json";
const emptyDiary = "assets/anim/empty_diary.json";
const emptyBox = "assets/anim/empty_box.json";



//validators
String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }

    // Check for email length
    if (value.length > 100) {
      return "Email is too long";
    }

    // Check for valid email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email address";
    }

    return null;
  }


String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your name";
  }

  // Check for character length
  if (value.length < 6) {
    return "username too short";
  } else if(value.length > 32) {
    return "username is too long";
  }

  return null;

}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your password";
  } else if (value.length < 6) {
    return "Password must be at least 6 characters";
  } else if (value.contains(' ')) {
    return "Password cannot contain spaces";
  } else {
    //print(value);
    return null;
  }
}

String? validateConfirmPassword(String? cp, String? p) {
  if (cp == null || cp.isEmpty) {
    return "Please enter your password";
  } else if (cp!= p) {
    return "Password does not match";
  } else {
    
    return null;
  }
}
