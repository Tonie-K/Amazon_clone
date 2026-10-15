import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/custom_textfield.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = '/otp-screen';
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;
  bool _resending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateOtp(String? value) {
    final otp = value?.trim() ?? '';
    if (otp.length != 6 || int.tryParse(otp) == null) {
      return 'Enter the 6-digit code';
    }
    return null;
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    // Grab these before the async gap so we don't use context after await
    final userProvider = context.read<UserProvider>();
    final navigator = Navigator.of(context);

    setState(() => _loading = true);
    final result =
        await AuthService.verifyOtp(widget.email, _otpController.text.trim());
    if (!mounted) return;

    if (result.success && result.token != null) {
      await userProvider.login(result.token!, result.user);
      // Back to the first route (the bottom-nav shell)
      navigator.popUntil((route) => route.isFirst);
    } else {
      setState(() => _loading = false);
      _showMessage(result.message);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final result = await AuthService.sendOtp(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    _showMessage(result.success ? 'A new code has been sent' : result.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify your email',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit code to ${widget.email}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                CustomTextfield(
                  controller: _otpController,
                  hintText: 'Enter code',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: _validateOtp,
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: _loading ? 'Verifying...' : 'Verify',
                  onTap: _loading ? () {} : _verify,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: (_loading || _resending) ? null : _resend,
                    child: Text(_resending ? 'Sending...' : 'Resend code'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
