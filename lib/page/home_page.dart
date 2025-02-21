import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'chatAI_page.dart';
import 'book_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String userPassword = "056450405018-3";

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
                      userId: 'test@gmail.com',
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
                text: 'Home',
              ),
              GButton(
                icon: Icons.comment,
                text: 'AI Chat',
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
