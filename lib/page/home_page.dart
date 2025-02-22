import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'chatAI_page.dart';
import 'book_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = const FlutterSecureStorage();
  String userPassword = "";

  @override
  void initState() {
    super.initState();
    _loadUserPassword();
  }

  Future<void> _loadUserPassword() async {
    try {
      final storedPassword = await _storage.read(key: 'password');
      if (storedPassword != null) {
        setState(() {
          userPassword = storedPassword;
        });
      } else {
        debugPrint('No password stored');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณาเข้าสู่ระบบใหม่อีกครั้ง'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading password: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 103, 80, 164),
        elevation: 0,
        title: const Text(
          'ยินดีต้อนรับ',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Barcode สำหรับเข้าใช้ห้องสมุด',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 103, 80, 164),
                ),
              ),
              const SizedBox(height: 30),
              if (userPassword
                  .isNotEmpty) // แสดง barcode เมื่อมี password เท่านั้น
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: userPassword,
                    width: 400,
                    height: 160,
                    drawText: false,
                    color: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                ),
              const SizedBox(height: 10),
              if (userPassword.isNotEmpty) // แสดงรหัสเมื่อมี password เท่านั้น
                Text(
                  'รหัสผ่านของคุณ: $userPassword',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 103, 80, 164),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: const Color.fromARGB(255, 103, 80, 164),
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: const Color.fromARGB(200, 102, 46, 145),
            gap: 6,
            padding: const EdgeInsets.all(16),
            selectedIndex: 0,
            onTabChange: (index) {
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIChatPage(
                      apiUrl: 'http://26.100.59.12:8000',
                    ),
                  ),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookPage(),
                  ),
                );
              }
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'หน้าหลัก',
              ),
              GButton(
                icon: Icons.comment,
                text: 'AI แชท',
              ),
              GButton(
                icon: Icons.book,
                text: 'จองหนังสือ',
              )
            ],
          ),
        ),
      ),
    );
  }
}
