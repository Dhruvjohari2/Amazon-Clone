import 'package:amazon_clone/signup/sign_up_screen.dart';
import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authService.signInWithEmailPassword(
                    _emailController.text,
                    _passwordController.text,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  print('Error signing in: $e');
                }
              },
              child: const Text('Log In'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              onPressed: () async {
                try {
                  await authService.signInWithGoogle();
                } catch (e) {
                  print('Error with Google Sign-In: $e');
                }
              },
              label: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
