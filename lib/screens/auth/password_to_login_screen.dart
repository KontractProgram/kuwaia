import 'package:flutter/material.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/text_fields.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/toast.dart';

class PasswordToLoginScreen extends StatefulWidget {
  final String email;
  const PasswordToLoginScreen({super.key, required this.email});

  @override
  State<PasswordToLoginScreen> createState() => _PasswordToLoginScreenState();
}

class _PasswordToLoginScreenState extends State<PasswordToLoginScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;
  bool _isPasswordObscured = true;


  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateButtonEnabledState);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateButtonEnabledState);
    super.dispose();
  }

  void _updateButtonEnabledState() {
    setState(() {
      _isButtonEnabled = validatePassword(_passwordController.text) == null;
    });
  }

  Future<void> _signIn() async {
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String password = _passwordController.text;

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        await authProvider.signIn(email: widget.email, password: password);
      } catch(e) {showToast('Unable to sign in');}
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
                    text: 'Enter your Password',
                    fontSize: 24,
                    fontWeight: FontWeight.w500
                  ),

                  SizedBox(height: size.height*0.05),

                  Stack(
                    children: [
                      Form(
                        key: _formKey,
                        child: authTextField(
                          controller: _passwordController,
                          label: 'Password',
                          size: size,
                          obscureText: _isPasswordObscured,
                          validator: (value) => validatePassword(value),
                          onSaved: (value) => _passwordController.text = value ?? ''
                        ),
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
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                            color: AppColors.bodyTextColor.withAlpha(126),
                            size: size.height*0.04,
                          )
                        )
                      )
                    ],
                  ),

                  SizedBox(height: size.height*0.01,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          //supabase forgot password function
                        },
                        child: reusableText(
                          text: 'Forgot Password?',
                          color: AppColors.bodyTextColor.withAlpha(128)
                        )
                      )
                    ],
                  )
                ],
              ),


              _isLoading ? longLoadingButton(size: size)
                : longActionButton(
                  text: 'Sign In',
                  size: size,
                  buttonColor: _isButtonEnabled ? AppColors.primaryAccentColor : AppColors.bodyTextColor.withAlpha(39),

                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if(_isButtonEnabled) {
                      setState(() {
                        _isLoading = true;
                      });

                      // supabase function to sign in
                      await _signIn();

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