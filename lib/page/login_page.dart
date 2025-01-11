import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Duration get loginTime => const Duration(milliseconds: 2000);

  static const users = {
    'test@gmail.com': '123456',
    'name@rmutp.ac.th': '1150',
  };

  @override
  void initState() {
    super.initState();
    checkBiometricAuth();
  }

  // ตรวจสอบและทำ Biometric Authentication
  Future<void> checkBiometricAuth() async {
    try {
      final String? savedEmail = await _storage.read(key: 'email');
      final String? savedPassword = await _storage.read(key: 'password');

      if (savedEmail != null && savedPassword != null) {
        // ตรวจสอบว่าอุปกรณ์รองรับ biometric หรือไม่
        final bool canAuthenticateWithBiometrics =
            await _localAuth.canCheckBiometrics;
        final bool canAuthenticate = canAuthenticateWithBiometrics ||
            await _localAuth.isDeviceSupported();

        if (canAuthenticate) {
          // ตรวจสอบประเภทของ biometric ที่มี
          List<BiometricType> availableBiometrics =
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

          if (didAuthenticate) {
            if (users.containsKey(savedEmail) &&
                users[savedEmail] == savedPassword) {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error during biometric auth: $e');
    }
  }

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }

      // ตรวจสอบว่าอุปกรณ์รองรับ biometric หรือไม่
      final bool canAuthenticate = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (canAuthenticate && mounted) {
        // ถามผู้ใช้ว่าต้องการใช้ biometric ไหม
        bool? shouldSetupBiometric = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ตั้งค่าการยืนยันตัวตน'),
              content: const Text(
                  'คุณต้องการใช้ Face Unlock หรือลายนิ้วมือสำหรับการเข้าสู่ระบบครั้งต่อไปหรือไม่?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('ไม่ใช้'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('ใช้'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );

        if (shouldSetupBiometric == true) {
          await _storage.write(key: 'email', value: data.name);
          await _storage.write(key: 'password', value: data.password);
        }
      }

      return null;
    });
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
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        title: 'Library Assistant',
        logo: const AssetImage('lib/images/RMUTP.png'),
        onLogin: _authUser,
        onSignup: _signupUser,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomePage(),
          ));
        },
        onRecoverPassword: _recoverPassword,
      ),
    );
  }
}
