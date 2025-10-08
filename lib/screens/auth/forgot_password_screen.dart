import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../services/profile_service.dart';
import '../../system/constants.dart';
import '../../widgets/buttons.dart';
import '../../widgets/text_fields.dart';
import '../../widgets/texts.dart';
import '../../widgets/toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonEnabledState);
  }

  void _updateButtonEnabledState() {
    setState(() {
      _isButtonEnabled = validateEmail(_emailController.text) == null;
    });
  }

  Future<void> _checkEmail() async {
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String email = _emailController.text;

      try {
        final ProfileService profileService = ProfileService();

        _profile = await profileService.getProfileByEmail(email);

      } catch(e) {
        showToast('Something went wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: leadingButton(context),
      ),

      body: SafeArea(
          child: Container(
            width: size.width,
            height: size.height,
            padding: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5),
                Column(
                  children: [
                    reusableText(
                        text: 'Enter email to recover password',
                        fontSize: 24,
                        fontWeight: FontWeight.w500
                    ),

                    SizedBox(height: size.height*0.05),

                    Form(
                      key: _formKey,
                      child: authTextField(
                        controller: _emailController,
                        label: 'Email',
                        size: size,
                        validator: (value) => validateEmail(value),
                        onSaved: (value) => _emailController.text = value ?? '',
                        textInputType: TextInputType.emailAddress
                      ),
                    ),
                  ],
                ),


                _isLoading ? longLoadingButton(size: size)
                    : longActionButton(
                    text: 'Send Email',
                    size: size,
                    buttonColor: _isButtonEnabled ? AppColors.primaryAccentColor : AppColors.bodyTextColor.withAlpha(39),

                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if(_isButtonEnabled) {
                        setState(() {
                          _isLoading = true;
                        });

                        // supabase function to check if mail exists
                        await _checkEmail();

                        if(context.mounted) {
                          if(_profile == null) {
                            showToast('No account with the above email. Create a new Account');
                            context.go('/continue_with_email');
                          } else {
                            //send code to email
                            String email = _emailController.text;
                            await Provider.of<AuthProvider>(context, listen: false).sendPasswordResetOtp(email);
                            //push to code screen
                            if(context.mounted){
                              context.push('/reset_password_verification/$email');
                            }
                          }
                        }

                        await Future.delayed(const Duration(seconds: 5));

                        if(context.mounted){
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    }
                )
              ],
            ),
          )
      ),
    );
  }
}
