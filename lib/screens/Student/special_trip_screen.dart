import 'package:flutter/material.dart';
import '../../services/special_trip_service.dart';
import 'special_trip_details_screen.dart';

enum TripCategory {
  desert,
  historical,
  water,
  nature,
  camping,
}

class SpecialTripScreen extends StatefulWidget {
  const SpecialTripScreen({super.key});

  @override
  State<SpecialTripScreen> createState() => _SpecialTripScreenState();
}

class _SpecialTripScreenState extends State<SpecialTripScreen> {
  TripCategory selectedCategory = TripCategory.desert;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Special Trip',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: SpecialTripService.fetchTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading trips'));
          }

          final allTrips = snapshot.data!;

          final filteredTrips = allTrips
              .where(
                (t) => t['category'] == selectedCategory.name,
              )
              .toList();

          final topTrips = List.of(allTrips)
            ..sort(
              (a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0),
            );

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1F4B63),
                        Color(0xFF2B6B8A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Explore Jordan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Discover unique trips, adventures and unforgettable destinations.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTabs(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 360,
                child: filteredTrips.isEmpty
                    ? const Center(child: Text('No trips found'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTrips.length,
                        itemBuilder: (context, index) {
                          return _TripCard(
                            trip: filteredTrips[index],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Top Destinations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: topTrips.take(3).length,
                itemBuilder: (context, index) {
                  final trip = topTrips[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TopDestinationItem(
                      title: trip['title'],
                      subtitle: trip['category'].toString().capitalize(),
                      imageUrl: trip['image_url'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpecialTripDetailsScreen(
                              tripId: trip['id'],
                              title: trip['title'],
                              description: trip['description'],
                              price: trip['price'].toString(),
                              duration: trip['duration'],
                              rating: trip['rating'].toString(),
                              imageUrl: trip['image_url'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    final icons = {
      TripCategory.desert: Icons.landscape_rounded,
      TripCategory.historical: Icons.account_balance_rounded,
      TripCategory.water: Icons.water_rounded,
      TripCategory.nature: Icons.eco_rounded,
      TripCategory.camping: Icons.forest_rounded,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: TripCategory.values.map((cat) {
          final isSelected = selectedCategory == cat;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1F4B63) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color:
                      isSelected ? Colors.transparent : const Color(0xFFEAEAEA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icons[cat],
                    size: 18,
                    color: isSelected ? Colors.white : const Color(0xFF1F4B63),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.name.capitalize(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Map trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpecialTripDetailsScreen(
              tripId: trip['id'],
              title: trip['title'],
              description: trip['description'],
              price: trip['price'].toString(),
              duration: trip['duration'],
              rating: trip['rating'].toString(),
              imageUrl: trip['image_url'],
            ),
          ),
        );
      },
      child: Hero(
        tag: trip['image_url'],
        child: Container(
          width: 260,
          height: 360,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            image: DecorationImage(
              image: NetworkImage(trip['image_url']),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      trip['rating'].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopDestinationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const _TopDestinationItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 105,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 105,
                  height: 105,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

extension Cap on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
