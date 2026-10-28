import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final targetController = TextEditingController();
  UserProfile? profile;
  bool loading = false;
  String? message;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      loading = true;
      message = null;
    });
    final data = await apiClient.getProfile();
    if (data['error'] == true) {
      setState(() {
        loading = false;
        message = data['detail']?.toString() ?? 'Failed to load profile';
      });
      return;
    }
    final user = UserProfile.fromJson(data);
    setState(() {
      profile = user;
      nameController.text = user.name ?? '';
      targetController.text = user.dailyCalorieTarget?.toString() ?? '';
      loading = false;
    });
  }

  Future<void> saveProfile() async {
    setState(() {
      loading = true;
      message = null;
    });
    final data = await apiClient.updateProfile({
      'name': nameController.text,
      'daily_calorie_target': int.tryParse(targetController.text),
    });
    if (data['error'] == true) {
      setState(() {
        loading = false;
        message = data['detail']?.toString() ?? 'Failed to update profile';
      });
      return;
    }
    setState(() {
      profile = UserProfile.fromJson(data);
      loading = false;
      message = 'Profile updated';
    });
  }

  Future<void> logout() async {
    await apiClient.clearToken();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (profile != null) Text(profile!.email),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  TextField(
                    controller: targetController,
                    decoration: const InputDecoration(labelText: 'Daily calorie target'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: saveProfile, child: const Text('Save')),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: logout, child: const Text('Logout')),
                  if (message != null) ...[
                    const SizedBox(height: 12),
                    Text(message!, style: TextStyle(color: message == 'Profile updated' ? Colors.green : Colors.red)),
                  ],
                ],
              ),
            ),
    );
  }
}
