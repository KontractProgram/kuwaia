import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: shortActionButton(
        text: 'Sign out',
        size: MediaQuery.of(context).size,
        onPressed: () async {
          await Provider.of<AuthProvider>(
            context,
            listen: false,
          ).signOut();
        },
      ),
    );
  }

}
