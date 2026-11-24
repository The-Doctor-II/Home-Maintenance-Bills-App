import 'package:flutter/material.dart';

import '../../services/local_db.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final currentPinController = TextEditingController();
  final newPinController = TextEditingController();
  final confirmPinController = TextEditingController();

  bool hideCurrentPin = true;
  bool hideNewPin = true;
  bool hideConfirmPin = true;

  String errorMessage = '';

  @override
  void dispose() {
    currentPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  Future<void> changePin() async {
    final currentPin = currentPinController.text.trim();
    final newPin = newPinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (currentPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      setState(() {
        errorMessage = 'يرجى تعبئة جميع الحقول';
      });
      return;
    }

    if (newPin.length < 4) {
      setState(() {
        errorMessage = 'الرقم السري الجديد يجب أن يكون 4 أرقام على الأقل';
      });
      return;
    }

    if (newPin != confirmPin) {
      setState(() {
        errorMessage = 'الرقم السري الجديد غير متطابق';
      });
      return;
    }

    final success = await LocalDb.changePin(
      currentPin: currentPin,
      newPin: newPin,
    );

    if (!success) {
      setState(() {
        errorMessage = 'الرقم السري الحالي غير صحيح';
      });
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تغيير الرقم السري بنجاح'),
      ),
    );

    Navigator.pop(context);
  }

  Widget buildPinField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        letterSpacing: 6,
      ),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تغيير الرقم السري'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 52,
                ),
                SizedBox(height: 12),
                Text(
                  'تحديث الرقم السري',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'أدخل الرقم الحالي ثم الرقم الجديد',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          buildPinField(
            controller: currentPinController,
            label: 'الرقم السري الحالي',
            obscureText: hideCurrentPin,
            onToggleVisibility: () {
              setState(() {
                hideCurrentPin = !hideCurrentPin;
              });
            },
          ),

          const SizedBox(height: 14),

          buildPinField(
            controller: newPinController,
            label: 'الرقم السري الجديد',
            obscureText: hideNewPin,
            onToggleVisibility: () {
              setState(() {
                hideNewPin = !hideNewPin;
              });
            },
          ),

          const SizedBox(height: 14),

          buildPinField(
            controller: confirmPinController,
            label: 'تأكيد الرقم السري الجديد',
            obscureText: hideConfirmPin,
            onToggleVisibility: () {
              setState(() {
                hideConfirmPin = !hideConfirmPin;
              });
            },
          ),

          if (errorMessage.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: changePin,
            icon: const Icon(Icons.save),
            label: const Text('حفظ الرقم السري الجديد'),
          ),
        ],
      ),
    );
  }
}