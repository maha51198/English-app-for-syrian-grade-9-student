import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/activation_service.dart';
import 'home_screen.dart';
import '../utils/constants.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final ActivationService _activationService = ActivationService();
  final TextEditingController _keyController = TextEditingController();
  bool _isLoading = false;
  String _deviceId = '...';

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final id = await _activationService.getDeviceId();
    if (mounted) setState(() => _deviceId = id);
  }

  void _copyDeviceId() {
    Clipboard.setData(ClipboardData(text: _deviceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ قم بالارسال')),
    );
  }

  Future<void> _contactEngineer() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+963934693780');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم التواصل: +963934693780')),
      );
    }
  }

  Future<void> _activate() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مفتاح التفعيل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValid = await _activationService.verifyKey(key);

      if (isValid) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isActivated', true);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'مفتاح التفعيل غير صحيح لهذا الجهاز. يرجى التواصل مع المهندسة.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Activation error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الاتصال بالخادم: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
              const SizedBox(height: 20),

              Text(
                'تفعيل التطبيق',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'هذه النسخة مقفلة. يرجى إدخال مفتاح التفعيل الخاص بك لبدء الاستخدام.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),

              // معلومات التواصل
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'للحصول على مفتاح التفعيل، يرجى التواصل مع:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'المهندسة مها بدر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _contactEngineer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+963934693780',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // معرف الجهاز
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ' أرسل هذا: $_deviceId',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: _copyDeviceId,
                      icon: const Icon(Icons.copy),
                      tooltip: 'نسخ',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // حقل إدخال المفتاح
              TextField(
                controller: _keyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'مفتاح التفعيل',
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // زر التفعيل
              ElevatedButton(
                onPressed: _isLoading ? null : _activate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'تفعيل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}