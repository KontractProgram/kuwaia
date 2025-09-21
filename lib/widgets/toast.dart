import 'package:fluttertoast/fluttertoast.dart';
import 'package:kuwaia/system/constants.dart';

void showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,  // LENGTH_SHORT = 2s, LENGTH_LONG = 5s
    gravity: ToastGravity.BOTTOM,     // TOP, CENTER, BOTTOM
    backgroundColor: AppColors.dashaSignatureColor.withAlpha(70),
    textColor: AppColors.bodyTextColor,
    fontSize: 14.0,
  );
}