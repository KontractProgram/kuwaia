import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../system/constants.dart';
import '../../../widgets/texts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String subscription = 'Free';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _){
        if (authProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColors.dashaSignatureColor,));
        }

        if (authProvider.error != null) {
          return Center(
            child: reusableText(
              text: 'Error: ${authProvider.error}',
              color: AppColors.warningColor,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height*0.1,),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackgroundColor,
                shape: BoxShape.circle,
                border: BoxBorder.all(color: AppColors.dashaSignatureColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dashaSignatureColor.withAlpha(150),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.secondaryAccentColor.withAlpha(150),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              ),
              child: FaIcon(FontAwesomeIcons.user, color: AppColors.headingTextColor, size: 50),
            ),

            SizedBox(height: 20,),
            
            reusableText(
              text: authProvider.profile!.username,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.secondaryAccentColor
              ),
              child: reusableText(text: '$subscription plan'),
            ),

            SizedBox(height: 20,),

            Card(
              color: AppColors.secondaryBackgroundColor,
              surfaceTintColor: AppColors.secondaryBackgroundColor,
              child: Column(
                children: [
                  reusableText(text: 'Upgrade to KUWAIA Pro unlimited tools, advanced AI features, and more'),
                  SizedBox(height: 20),
                  shortActionButton(
                    text: 'Go Pro',
                    size: size
                  )
                ],
              ),
            ),

            SizedBox(height: 20,),

            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                singleTrailCardWidget(
                  leadingIcon: FontAwesomeIcons.chartPie,
                  title: 'Cost Dashboard',
                  onPressed: () {}
                ),
                singleTrailCardWidget(
                  leadingIcon: FontAwesomeIcons.creditCard,
                  title: 'Manage Subscription',
                  onPressed: () {}
                ),
                singleTrailCardWidget(
                  leadingIcon: FontAwesomeIcons.download,
                  title: 'Export My Data',
                  onPressed: () {}
                ),
                singleTrailCardWidget(
                  leadingIcon: FontAwesomeIcons.gear,
                  title: 'Settings',
                  onPressed: () {}
                ),

              ],
            ),

            longActionButton(
              text: 'Log Out',
              size: size,
              textColor: AppColors.warningColor,
              buttonColor: AppColors.warningColor.withAlpha(100),
              onPressed: () => authProvider.signOut()
            )
          ],
        );
      },
    );
  }
}
