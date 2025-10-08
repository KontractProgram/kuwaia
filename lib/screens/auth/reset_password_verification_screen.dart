import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons.dart';
import '../../widgets/text_fields.dart';
import '../../widgets/texts.dart';
import '../../widgets/toast.dart';
import '../../system/constants.dart';

class ResetPasswordVerificationScreen extends StatefulWidget {
  final String email;
  const ResetPasswordVerificationScreen({super.key, required this.email});

  @override
  State<ResetPasswordVerificationScreen> createState() => _ResetPasswordVerificationScreenState();
}

class _ResetPasswordVerificationScreenState extends State<ResetPasswordVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(leading: leadingButton(context)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              reusableText(
                  text: 'Enter the 6-digit code sent to your email',
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
              const SizedBox(height: 30),
              authTextField(
                controller: _otpController,
                label: 'OTP Code',
                size: size,
                validator: (value) => validateOtp(value),
                textInputType: TextInputType.number
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? longLoadingButton(size: size)
                  : longActionButton(
                text: 'Verify OTP',
                size: size,
                buttonColor: AppColors.primaryAccentColor,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  setState(() => _isLoading = true);

                  final ok = auth.verifyOtp(_otpController.text);
                  await Future.delayed(const Duration(milliseconds: 400));

                  if (context.mounted) {
                    if (ok) {
                      showToast('OTP verified');
                      context.push('/reset_password/${widget.email}');
                    } else {
                      showToast('Invalid code');
                    }
                    setState(() => _isLoading = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
