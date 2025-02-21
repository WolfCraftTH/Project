import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'chatAI_page.dart';
import 'Home_page.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final TextEditingController _bookNameController = TextEditingController();
  String _barcodeData = '';
  bool _showBarcode = false;
  final String studentId = "056450405018-3";

  void _generateBarcodeData() {
    if (_bookNameController.text.isEmpty) return;

    setState(() {
      _barcodeData = '$studentId${_bookNameController.text}';
      _showBarcode = true;
    });
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 103, 80, 164),
        title: const Text(
          'จองหนังสือ',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ส่วนกรอกชื่อหนังสือ
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'กรอกรหัสหนังสือที่ต้องการจอง',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bookNameController,
                      decoration: InputDecoration(
                        hintText: 'รหัสหนังสือ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _generateBarcodeData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 103, 80, 164),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'สร้างบาร์โค้ด',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ส่วนแสดงบาร์โค้ด
            if (_showBarcode) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'บาร์โค้ดสำหรับการจอง',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: _barcodeData,
                          width: 600,
                          height: 160,
                          drawText: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'รหัสหนังสือ: ${_bookNameController.text}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'รหัสการจอง: $_barcodeData',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
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
            selectedIndex: 2,
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
              } else if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
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
