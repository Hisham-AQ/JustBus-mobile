import 'package:flutter/material.dart';
import '../../services/rating_service.dart';

class RatingScreen extends StatefulWidget {
  final int tripId;

  const RatingScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int driverRating = 5;
  int tripRating = 5;
  int serviceRating = 5;

  final commentController = TextEditingController();

  bool isLoading = false;

  Widget buildStars({
    required int currentRating,
    required Function(int) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          final star = index + 1;

          return IconButton(
            onPressed: () {
              onChanged(star);
            },
            icon: Icon(
              Icons.star,
              color:
                  star <= currentRating ? Colors.amber : Colors.grey.shade300,
              size: 34,
            ),
          );
        },
      ),
    );
  }

  Future<void> submitRating() async {
    try {
      setState(() {
        isLoading = true;
      });

      await RatingService.submitRating(
        tripId: widget.tripId,
        driverRating: driverRating,
        tripRating: tripRating,
        serviceRating: serviceRating,
        comment: commentController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully'),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/student-home',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1F4B63),
        title: const Text(
          'Rate Your Trip',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            buildSection(
              title: 'Driver Rating',
              icon: Icons.person,
              child: buildStars(
                currentRating: driverRating,
                onChanged: (value) {
                  setState(() {
                    driverRating = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 18),
            buildSection(
              title: 'Trip Rating',
              icon: Icons.directions_bus,
              child: buildStars(
                currentRating: tripRating,
                onChanged: (value) {
                  setState(() {
                    tripRating = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 18),
            buildSection(
              title: 'Service Rating',
              icon: Icons.support_agent,
              child: buildStars(
                currentRating: serviceRating,
                onChanged: (value) {
                  setState(() {
                    serviceRating = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 18),
            buildSection(
              title: 'Comment',
              icon: Icons.comment,
              child: TextField(
                controller: commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tell us about your experience...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F4B63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF1F4B63),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
