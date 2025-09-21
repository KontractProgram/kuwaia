import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:kuwaia/services/profile_service.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:kuwaia/widgets/toast.dart';
import 'package:provider/provider.dart';

import '../../system/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<Map<String, dynamic>>? _allProfessions;

  final Set<Map<String, dynamic>> _selectedProfessions = {};
  bool _isLoading = false;
  bool get isButtonEnabled => _selectedProfessions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchProfession();
  }

  Future<void> _fetchProfession() async {
    try {
      final profileService = ProfileService();
      final professions = await profileService.fetchProfessions();
      setState(() {
        _allProfessions = professions;
      });
    } catch (e) {
      print("❌ Error fetching professions: $e");
      setState(() => _isLoading = false);
    }
  }


  Future<void> _onboard() async {
    if(_selectedProfessions.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try{
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.onboard(_selectedProfessions.toList());
      showToast('Onboarding complete!');
      setState(() {
        _isLoading = false;
      });
    } catch(e) {
      print(e);
      showToast('Unable to onboard');
    }
  }

  void _toggleSelection(Map<String, dynamic> profession) {
    setState(() {
      if (_selectedProfessions.contains(profession)) {
        _selectedProfessions.remove(profession);
      } else if (_selectedProfessions.length < 5) {
        _selectedProfessions.add(profession);
      } else {
        showToast('You can select up to 5 roles only');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              reusableText(
                text: 'Tell us about yourself',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              reusableText(text: 'Select multiple roles. This helps us tailor your experience'),
              SizedBox(height: size.height*0.02),

              Expanded(
                child: _allProfessions != null ? SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allProfessions!.map((profession) {
                      final isSelected = _selectedProfessions.contains(profession);
                      final isDisabled = !isSelected && _selectedProfessions.length >= 5;
                      final name = profession['name'] as String;

                      return ChoiceChip(
                        label: Text(
                            name,
                            style: TextStyle(color: AppColors.secondaryBackgroundColor)
                        ),
                        selected: isSelected,
                        onSelected: isDisabled ? null : (_) => _toggleSelection(profession),
                        selectedColor: AppColors.dashaSignatureColor,
                        backgroundColor: AppColors.bodyTextColor.withAlpha(129),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.bodyTextColor : AppColors.secondaryBackgroundColor,
                        ),
                      );
                    }).toList(),
                  ),
                ) : Center(child: CircularProgressIndicator(),),
              ),

              _isLoading ? longLoadingButton(size: size)
                : longActionButton(
                text: 'Continue',
                size: size,
                buttonColor: isButtonEnabled ? AppColors.primaryAccentColor : AppColors.bodyTextColor.withAlpha(39),
                onPressed: isButtonEnabled ? _onboard : null
              )
            ],
          ),
        ),
      ),
    );
  }

}