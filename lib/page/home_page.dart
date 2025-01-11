import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../utill/Category_Card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 103, 80, 164),
              elevation: 0,
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // do something
                  },
                  icon: const Icon(Icons.account_circle),
                ),
              ],
            ),

            // category
            body: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 250),
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: 6,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return const CategoryCard(
                        CategoryName: 'Drama',
                        logoimagepath: 'lib/images/drama.png',
                      );
                    },
                  ),
                )
              ],
            ),

            //bottomNaviationbar
            bottomNavigationBar: Container(
              color: const Color.fromARGB(255, 103, 80, 164),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: GNav(
                  backgroundColor: const Color.fromARGB(255, 103, 80, 164),
                  color: Colors.white,
                  activeColor: Colors.white,
                  tabBackgroundColor: const Color.fromARGB(200, 102, 46, 145),
                  gap: 6,
                  padding: const EdgeInsets.all(16),
                  tabs: const [
                    GButton(
                      icon: Icons.home,
                      text: 'Home',
                    ),
                    GButton(
                      icon: Icons.favorite,
                      text: 'Favorites',
                    ),
                    GButton(
                      icon: Icons.access_time_filled,
                      text: 'Booking',
                    ),
                    GButton(
                      icon: Icons.comment,
                      text: 'AI Chart',
                    ),
                    GButton(
                      icon: Icons.settings,
                      text: 'Settings',
                    ),
                  ],
                ),
              ),
            )));
  }
}
