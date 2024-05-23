import 'package:flutter/material.dart';
import 'package:notes_app/constants/route.dart';
import 'package:notes_app/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const Text(
              'A Verification email has been sent to your email. Please check it to verify your email'),
          const Text(
              "Haven't received a verification email yet? Click button below to resend an Email Verification"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send Email Verification'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
