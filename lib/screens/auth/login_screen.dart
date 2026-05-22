import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('login_title'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: context.tr('email')),
              validator: (value) =>
                  Validators.requiredField(value, context.tr('field_required')),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: context.tr('password')),
              validator: (value) =>
                  Validators.requiredField(value, context.tr('field_required')),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: authProvider.isLoading ? null : _login,
              child: authProvider.isLoading
                  ? Text(context.tr('loading'))
                  : Text(context.tr('login')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('error_generic'))),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    final route = user?.role == UserRole.admin
        ? AppRoutes.adminDashboard
        : AppRoutes.staffDashboard;
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }
}
