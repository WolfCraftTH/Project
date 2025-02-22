import 'dart:convert';
import 'package:flutter/foundation.dart'; // ใช้สำหรับ kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';
import 'services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Duration get loginTime => const Duration(milliseconds: 2000);

  get users => null;

  @override
  void initState() {
    super.initState();
    checkBiometricAuth();
  }

  Future<void> checkBiometricAuth() async {
    if (kIsWeb) {
      debugPrint('Biometric authentication is not supported on the web.');
      return;
    }

    try {
      final String? savedId = await _storage.read(key: 'saved_id');
      final String? savedPassword = await _storage.read(key: 'password');
      final String? savedUserData = await _storage.read(key: 'user_data');

      if (savedId != null && savedPassword != null && savedUserData != null) {
        final bool canAuthenticate = await _localAuth.canCheckBiometrics ||
            await _localAuth.isDeviceSupported();

        if (canAuthenticate) {
          final List<BiometricType> availableBiometrics =
              await _localAuth.getAvailableBiometrics();

          String authMessage = 'กรุณายืนยันตัวตนด้วย ';
          if (availableBiometrics.contains(BiometricType.face)) {
            authMessage += 'Face Unlock';
          } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
            authMessage += 'ลายนิ้วมือ';
          } else {
            authMessage += 'Biometric';
          }

          final bool didAuthenticate = await _localAuth.authenticate(
            localizedReason: authMessage,
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          );

          if (didAuthenticate && mounted) {
            try {
              final response = await ApiService.login(savedId, savedPassword);

              if (response['status'] == 'success') {
                await _storage.write(
                    key: 'user_id', value: response['user_id'].toString());
                await _storage.write(
                    key: 'user_data',
                    value: json.encode(response['user_data']));
                // เพิ่มการบันทึก password
                await _storage.write(key: 'password', value: savedPassword);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else {
                await _storage.delete(key: 'saved_id');
                await _storage.delete(key: 'password');
                await _storage.delete(key: 'user_data');
              }
            } catch (e) {
              debugPrint('Auto-login failed: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error during biometric auth: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการยืนยันตัวตน: $e')),
        );
      }
    }
  }

  Future<String?> _authUser(LoginData data) async {
    try {
      final response = await ApiService.login(data.name, data.password);

      if (response['status'] == 'success') {
        // บันทึกข้อมูลผู้ใช้
        await _storage.write(key: 'user_id', value: data.name);
        await _storage.write(
            key: 'user_data', value: json.encode(response['user_data']));
        // บันทึก password สำหรับใช้แสดง barcode
        await _storage.write(key: 'password', value: data.password);

        if (!kIsWeb && await _localAuth.canCheckBiometrics) {
          bool? shouldSetupBiometric = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('ตั้งค่าการยืนยันตัวตน'),
              content: const Text(
                  'คุณต้องการใช้ Face Unlock หรือลายนิ้วมือสำหรับการเข้าสู่ระบบครั้งต่อไปหรือไม่?'),
              actions: [
                TextButton(
                  child: const Text('ไม่ใช้'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('ใช้'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );

          if (shouldSetupBiometric == true) {
            await _storage.write(key: 'saved_id', value: data.name);
            await _storage.write(key: 'password', value: data.password);
          }
        }
        return null;
      } else {
        return response['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  Future<void> clearLoginData() async {
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'password');
    await _storage.delete(key: 'saved_id');
    await _storage.delete(key: 'user_data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        title: 'Library Assistant',
        logo: const AssetImage('lib/images/RMUTP.png'),
        onLogin: _authUser,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
        },
        onRecoverPassword: _recoverPassword,
        hideForgotPasswordButton: true,
        messages: LoginMessages(
          userHint: 'อีเมลนักศึกษา/บุคลากร',
          passwordHint: 'รหัสผ่าน',
          confirmPasswordHint: 'ยืนยันรหัสผ่าน',
          loginButton: 'เข้าสู่ระบบ',
          goBackButton: 'ย้อนกลับ',
          confirmPasswordError: 'รหัสผ่านไม่ตรงกัน!',
        ),
      ),
    );
  }
}
