import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/text_fields.dart';
import 'package:kuwaia/widgets/toast.dart';
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

  void _showChangeUsernameModal({required BuildContext context, required AuthProvider authProvider, required Size size,}) {
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool isButtonEnabled = false;

        return StatefulBuilder(
          builder: (context, setState) {
            // Listeners to detect input changes dynamically
            usernameController.addListener(() {
              final usernameValid = validateUsername(usernameController.text) == null;
              final passwordValid = validatePassword(passwordController.text) == null;
              setState(() => isButtonEnabled = usernameValid && passwordValid);
            });

            passwordController.addListener(() {
              final usernameValid = validateUsername(usernameController.text) == null;
              final passwordValid = validatePassword(passwordController.text) == null;
              setState(() => isButtonEnabled = usernameValid && passwordValid);
            });

            return Container(
              height: size.height * 0.9,
              decoration: BoxDecoration(
                color: AppColors.primaryBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reusableText(
                      text: "Change Username",
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    const SizedBox(height: 15),

                    authTextField(
                      controller: usernameController,
                      obscureText: false,
                      label: 'New username',
                      size: size,
                      validator: validateUsername,
                      onSaved: (value) =>
                      usernameController.text = value ?? '',
                    ),
                    const SizedBox(height: 10),

                    authTextField(
                      controller: passwordController,
                      obscureText: true,
                      label: 'Password',
                      size: size,
                      validator: validatePassword,
                      onSaved: (value) =>
                      passwordController.text = value ?? '',
                    ),
                    const SizedBox(height: 20),

                    longActionButton(
                      onPressed: isButtonEnabled
                          ? () async {
                        if (formKey.currentState!.validate()) {
                          context.pop();
                          try {
                            await authProvider.changeUsername(
                              newUsername: usernameController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                            showToast('Username updated successfully');
                          } catch (e) {
                            if (e.toString().contains('wrong-password')) {
                              showToast('Wrong password. Please try again.');
                            } else if (e.toString().contains('username-exists')) {
                              showToast('Username already exists. Choose another.');
                            } else {
                              showToast('Something went wrong. Please try again.');
                            }
                          }
                        }
                      } : null, // disables click when invalid
                      text: 'Save Changes',
                      size: size,
                      buttonColor: isButtonEnabled
                          ? AppColors.primaryAccentColor
                          : AppColors.bodyTextColor.withAlpha(26),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordModal({required BuildContext context, required AuthProvider authProvider, required Size size,}) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool isButtonEnabled = false;

        return StatefulBuilder(
          builder: (context, setState) {
            // Listen dynamically for field updates
            void validateFields() {
              final currentValid = validatePassword(currentPasswordController.text) == null;
              final newValid = validatePassword(newPasswordController.text) == null;
              final confirmValid = newPasswordController.text == confirmPasswordController.text &&
                  confirmPasswordController.text.isNotEmpty;
              setState(() => isButtonEnabled = currentValid && newValid && confirmValid);
            }

            currentPasswordController.addListener(validateFields);
            newPasswordController.addListener(validateFields);
            confirmPasswordController.addListener(validateFields);

            return Container(
              height: size.height * 0.9,
              decoration: BoxDecoration(
                color: AppColors.primaryBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reusableText(
                      text: "Change Password",
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    const SizedBox(height: 15),

                    authTextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      label: 'Current Password',
                      size: size,
                      validator: validatePassword,
                      onSaved: (v) => currentPasswordController.text = v ?? '',
                    ),
                    const SizedBox(height: 10),

                    authTextField(
                      controller: newPasswordController,
                      obscureText: true,
                      label: 'New Password',
                      size: size,
                      validator: validatePassword,
                      onSaved: (v) => newPasswordController.text = v ?? '',
                    ),
                    const SizedBox(height: 10),

                    authTextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      label: 'Confirm New Password',
                      size: size,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm password';
                        } else if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onSaved: (v) => confirmPasswordController.text = v ?? '',
                    ),
                    const SizedBox(height: 20),

                    longActionButton(
                      onPressed: isButtonEnabled
                          ? () async {
                        if (formKey.currentState!.validate()) {
                          context.pop();
                          try {
                            await authProvider.changePassword(
                              currentPassword: currentPasswordController.text.trim(),
                              newPassword: newPasswordController.text.trim(),
                            );
                            showToast('Password updated successfully. Please log in again.');
                            // You may redirect to login page here
                          } catch (e) {
                            if (e.toString().contains('wrong-password')) {
                              showToast('Wrong current password');
                            } else {
                              showToast('Something went wrong. Please try again.');
                            }
                          }
                        }
                      }
                          : null,
                      text: 'Save Changes',
                      size: size,
                      buttonColor: isButtonEnabled
                          ? AppColors.primaryAccentColor
                          : AppColors.bodyTextColor.withAlpha(26),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _){
        if (authProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColors.dashaSignatureColor,));
        }

        // if (authProvider.error != null) {
        //   return Center(
        //     child: reusableText(
        //       text: 'Error: ${authProvider.error}',
        //       color: AppColors.warningColor,
        //     ),
        //   );
        // }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),

              Container(
                width: size.width*0.5,
                height: size.width*0.5,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackgroundColor,
                  shape: BoxShape.circle,
                  border: BoxBorder.all(color: AppColors.dashaSignatureColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dashaSignatureColor.withAlpha(255),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.secondaryAccentColor.withAlpha(255),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                ),
                child: Center(child: FaIcon(FontAwesomeIcons.user, color: AppColors.headingTextColor, size: 50)),
              ),

              SizedBox(height: 20,),

              reusableText(
                text: authProvider.profile!.username,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: size.height*0.02),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.secondaryBackgroundColor
                ),
                child: Column(
                  children: [
                    reusableText(text: 'Do you want to be recommended as an AI freelancer to our users?'),
                    SizedBox(height: 20),
                    shortActionButton(
                      text: 'Send Request',
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
                    title: 'Invite Friends',
                    onPressed: () {}
                  ),
                  singleTrailCardWidget(
                    leadingIcon: FontAwesomeIcons.creditCard,
                    title: 'Change Password',
                    onPressed: () => _showChangePasswordModal(context: context, authProvider: authProvider, size: size)
                  ),
                  singleTrailCardWidget(
                    leadingIcon: FontAwesomeIcons.download,
                    title: 'Change Username',
                    onPressed: () => _showChangeUsernameModal(context: context, authProvider: authProvider, size: size)
                  ),
                  singleTrailCardWidget(
                    leadingIcon: FontAwesomeIcons.gear,
                    title: 'Become a Freelancer',
                    onPressed: () {}
                  ),

                ],
              ),

              SizedBox(height: 20,),

              longActionButton(
                text: 'Log Out',
                size: size,
                textColor: AppColors.warningColor,
                buttonColor: AppColors.warningColor.withAlpha(50),
                onPressed: () => authProvider.signOut()
              )
            ],
          ),
        );
      },
    );
  }
}
