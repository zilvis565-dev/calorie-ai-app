import 'package:flutter/material.dart';

import '../api_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? message;
  bool loading = false;

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty || passwordController.text.length < 6) {
      setState(() => message = 'Enter valid email and password of at least 6 characters');
      return;
    }
    setState(() {
      loading = true;
      message = null;
    });
    final result = await apiClient.register(
      emailController.text,
      passwordController.text,
      nameController.text,
    );
    if (result['error'] == true) {
      setState(() => message = result['detail']?.toString() ?? 'Registration failed');
    } else {
      setState(() => message = 'Registration successful. You can now login.');
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loading ? null : submit, child: Text(loading ? 'Loading...' : 'Register')),
            if (message != null) Text(message!, style: TextStyle(color: message!.contains('successful') ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}
