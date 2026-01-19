import 'package:flutter/material.dart';

class SpecialTripDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String duration;
  final String rating;
  final String imageUrl;

  const SpecialTripDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  height: 380,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 48,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoBox('Duration', '$duration km'),
                      _infoBox('Rating', '$rating ★'),
                      _infoBox('Price', '$price JD'),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
