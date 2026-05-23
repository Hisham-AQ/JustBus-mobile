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
  int driverRating = 0;
  int tripRating = 0;
  int serviceRating = 0;

  final commentController = TextEditingController();

  bool isLoading = false;

  Widget buildStars({
    required int currentRating,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) {
              final star = index + 1;

              return IconButton(
                onPressed: () {
                  onChanged(star);
                },
                icon: AnimatedScale(
                  scale: star <= currentRating ? 1.15 : 1,
                  duration: const Duration(
                    milliseconds: 160,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: star <= currentRating
                        ? Colors.amber
                        : Colors.grey.shade300,
                    size: 36,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _ratingLabel(currentRating),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> submitRating() async {
    try {
      if (driverRating == 0 || tripRating == 0 || serviceRating == 0) {
        await showDialog(
          context: context,
          builder: (_) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_outline_rounded,
                        color: Colors.orange,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Incomplete Rating",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please rate all sections before submitting your feedback.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4B63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        return;
      }
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
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Rating Submitted 💫",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Thank you for sharing your experience with us.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.4,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F4B63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/student-home',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Back to Home",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return "Very Bad";

      case 2:
        return "Bad";

      case 3:
        return "Good";

      case 4:
        return "Very Good";

      case 5:
        return "Excellent";

      default:
        return "Tap to rate";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            const Icon(
              Icons.rate_review_rounded,
              size: 80,
              color: Color(0xFF1F4B63),
            ),
            Text(
              "Your feedback helps us improve",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/student-home',
                  (route) => false,
                );
              },
              child: Text(
                'Skip for now',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();

    super.dispose();
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
