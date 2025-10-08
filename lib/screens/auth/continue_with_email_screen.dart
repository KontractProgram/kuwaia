import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/services/profile_service.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/text_fields.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:kuwaia/widgets/toast.dart';

class ContinueWithEmailScreen extends StatefulWidget {
  const ContinueWithEmailScreen({super.key});

  @override
  State<ContinueWithEmailScreen> createState() => _ContinueWithEmailScreenState();
}

class _ContinueWithEmailScreenState extends State<ContinueWithEmailScreen> {
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

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonEnabledState);
    super.dispose();
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
                    text: 'Continue with Email',
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
                  text: 'Continue',
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
                          context.push('/username/${_emailController.text}');
                        } else {
                          context.push('/password_to_login/${_emailController.text}');
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