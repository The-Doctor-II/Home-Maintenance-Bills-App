import 'package:flutter/material.dart';

import '../../services/local_db.dart';

class PinPage extends StatefulWidget {
  final bool isSetup;
  final VoidCallback onSuccess;

  const PinPage({
    super.key,
    required this.isSetup,
    required this.onSuccess,
  });

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final pinController = TextEditingController();
  String? firstPin;
  String errorMessage = '';

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final pin = pinController.text.trim();

    if (pin.length < 4) {
      setState(() {
        errorMessage = 'الرقم السري يجب أن يكون 4 أرقام على الأقل';
      });
      return;
    }

    if (widget.isSetup) {
      if (firstPin == null) {
        setState(() {
          firstPin = pin;
          pinController.clear();
          errorMessage = '';
        });
      } else {
        if (pin != firstPin) {
          setState(() {
            errorMessage = 'الرقم السري غير متطابق، حاول مرة أخرى';
            pinController.clear();
          });
          return;
        }

        await LocalDb.savePin(pin);
        widget.onSuccess();
      }
    } else {
      if (LocalDb.verifyPin(pin)) {
        widget.onSuccess();
      } else {
        setState(() {
          errorMessage = 'الرقم السري غير صحيح';
          pinController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isSetup
        ? firstPin == null
        ? 'إنشاء رقم سري'
        : 'تأكيد الرقم السري'
        : 'أدخل الرقم السري';

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
              Color(0xFF64B5F6),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.lock,
                          color: Colors.blue.shade700,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'لحماية بيانات فواتير الصيانة الخاصة بك',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 8,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'الرقم السري',
                          counterText: '',
                          prefixIcon: Icon(Icons.pin),
                        ),
                        onSubmitted: (_) => submit(),
                      ),
                      if (errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: submit,
                          icon: const Icon(Icons.login),
                          label: Text(
                            widget.isSetup ? 'حفظ' : 'دخول',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}