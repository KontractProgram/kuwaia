import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/services/profile_service.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/text_fields.dart';
import 'package:kuwaia/widgets/texts.dart';
import '../../widgets/toast.dart';

class UsernameScreen extends StatefulWidget {
  final String email;
  const UsernameScreen({super.key, required this.email});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonEnabledState);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateButtonEnabledState);
    super.dispose();
  }

  void _updateButtonEnabledState() {
    setState(() {
      _isButtonEnabled = validateUsername(_usernameController.text) == null;
    });
  }

  Future<void> _checkUsername() async {
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String username = _usernameController.text;

      try {
        final profileService = ProfileService();

        _profile = await profileService.getProfileByUsername(username);

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
              SizedBox(height: size.height*0.06),
              Column(
                children: [
                  reusableText(
                    text: 'Enter your Username',
                    fontSize: 24,
                    fontWeight: FontWeight.w500
                  ),

                  SizedBox(height: size.height*0.05),

                  Form(
                    key: _formKey,
                    child: authTextField(
                      controller: _usernameController,
                      label: 'Username',
                      size: size,
                      validator: (value) => validateUsername(value),
                      onSaved: (value) => _usernameController.text = value ?? ''
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

                      // supabase function to check if username is valid
                      await _checkUsername();

                      if(context.mounted) {
                        if(_profile == null) {
                          context.push('/password_to_register/${widget.email}/${_usernameController.text}');
                        } else {
                          showToast('Username already exists! Try another.');
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