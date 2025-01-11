import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String CategoryName;
  final String logoimagepath;

  const CategoryCard({
    super.key,
    required this.CategoryName,
    required this.logoimagepath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          color: Colors.grey[200],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 70,
                    child: Image.asset(logoimagepath),
                  ),
                  Text(CategoryName),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
