import 'package:flutter/material.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:lottie/lottie.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Lottie.asset(noInternet, width: MediaQuery.of(context).size.width*0.7),
            SizedBox(height: 20),
            reusableText(
              text: 'Please check your internet connection',
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ],
        ),
      ),
    );
  }
}
