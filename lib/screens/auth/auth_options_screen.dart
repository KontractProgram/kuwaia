import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/texts.dart';

import '../../routing/app_router.dart';

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;


    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.primaryBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            children: [

              SizedBox(
                width: size.width,
                height: size.height*0.6,
                child: Stack(
                  children: [
                    Container(
                      width: size.width,
                      height: size.height*0.6,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(authBg),
                          fit: BoxFit.cover
                        )
                      ),
                    ),
              
              
                    Container(
                      width: size.width,
                      height: size.height*0.6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primaryBackgroundColor.withAlpha(0), AppColors.primaryBackgroundColor.withAlpha(255)]
                        )
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            child: Image.asset(logoTrans),
                          ),
                          reusableText(
                            text: 'KUWAIA',
                            fontSize: 48,
                            fontWeight: FontWeight.w600
                          ),
                          SizedBox(height: 100)
                        ],
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: size.height*0.02,),

              continueWithGoogleButton(
                  size: size,
                  //integrate function for google sign in/up
              ),

              SizedBox(height: size.height*0.02,),

              longActionButton(
                text: 'Continue with Email',
                size: size,
                onPressed: () => context.push('/continue_with_email')
              ),

              SizedBox(height: size.height*0.03),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        print('privacy policies');
                      }, 
                      child: reusableText(
                        text: 'Privacy Policy',
                        color: AppColors.bodyTextColor.withAlpha(178),
                      ),
                    ),

                    SizedBox(width: size.width*0.1,),

                    TextButton(
                      onPressed: () {
                        print('terms');
                      }, 
                      child: reusableText(
                        text: 'Terms of Service',
                        color: AppColors.bodyTextColor.withAlpha(178),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}