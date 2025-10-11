import 'package:flutter/material.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/text_fields.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/toast.dart';

class PasswordToRegisterScreen extends StatefulWidget {
  final String email;
  final String username;

  const PasswordToRegisterScreen({
    super.key, 
    required this.email, 
    required this.username
  });

  @override
  State<PasswordToRegisterScreen> createState() => _PasswordToRegisterScreenState();
}

class _PasswordToRegisterScreenState extends State<PasswordToRegisterScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _doesPasswordsMatch = false;
  

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateButtonEnabledState);
    _confirmPasswordController.addListener(_updateButtonEnabledState);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateButtonEnabledState);
    _confirmPasswordController.removeListener(_updateButtonEnabledState);
    super.dispose();
  }

  void _updateButtonEnabledState() {
    setState(() {
      String? passwordValidation = validatePassword(_passwordController.text);
      String? confirmPasswordValidation = validateConfirmPassword(_confirmPasswordController.text, _passwordController.text);

      _doesPasswordsMatch = confirmPasswordValidation == null;
      _isButtonEnabled = passwordValidation == null && _doesPasswordsMatch && isStrongPassword(_passwordController.text);
    });
  }

  Future<void> _register() async{
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String password = _passwordController.text;

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        await authProvider.signUpWithEmailPassword(
            email: widget.email,
            password: password,
            username: widget.username
        );
      } catch(e) {
        print('register error ${e.toString()}');
        if(e.toString().contains('user_already_exists')) {
          showToast('User already exists');
        } else if(e.toString().contains('weak_password')) {
          showToast('Weak password. Try another');
        } else {
          showToast('Unable to sign up');
        }

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
                    text: 'Choose your Password',
                    fontSize: 24,
                    fontWeight: FontWeight.w500
                  ),

                  SizedBox(height: size.height*0.05),

                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            authTextField(
                              controller: _passwordController,
                              label: 'Password',
                              size: size,
                              obscureText: _isPasswordObscured,
                              validator: (value) => validatePassword(value),
                              onSaved: (value) => _passwordController.text = value ?? ''
                            ),

                            Positioned(
                              right: 15,
                              bottom: size.height*0.01,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPasswordObscured = !_isPasswordObscured;
                                  });
                                },
                                child: Icon(
                                  _isPasswordObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                  color: AppColors.bodyTextColor.withAlpha(126),
                                  size: size.height*0.04,
                                )
                              )
                            )
                          ],
                        ),

                        SizedBox(height: size.height*0.02,),

                        Stack(
                          children: [
                            authTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              size: size,
                              obscureText: _isPasswordObscured,
                              validator: (value) => validateConfirmPassword(value, _passwordController.text),
                              onSaved: (value) => _confirmPasswordController.text = value ?? ''
                            ),

                            Positioned(
                              right: 15,
                              bottom: size.height*0.01,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPasswordObscured = !_isPasswordObscured;
                                  });
                                },
                                child: Icon(
                                  _isPasswordObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                  color: AppColors.bodyTextColor.withAlpha(126),
                                  size: size.height*0.04,
                                )
                              )
                            )
                          ],
                        ),
                        
                        SizedBox(height: 8,),
                        
                        reusableText(
                          text: 'At least 8 characters, one uppercase, one lowercase, one digit, one special character',
                          fontSize: 12,
                          textAlign: TextAlign.start,
                          color: AppColors.bodyTextColor.withAlpha(150)
                        )

                      ],
                    ),
                  ),
                ],
              ),


              _isLoading ? longLoadingButton(size: size)
                : longActionButton(
                  text: 'Sign Up',
                  size: size,
                  buttonColor: _isButtonEnabled ? AppColors.primaryAccentColor : AppColors.bodyTextColor.withAlpha(39),

                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if(_isButtonEnabled) {
                      setState(() {
                        _isLoading = true;
                      });

                      // supabase function to sign up
                      await _register();

                      await Future.delayed(const Duration(seconds: 5));

                      // take action based on response from supabase
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