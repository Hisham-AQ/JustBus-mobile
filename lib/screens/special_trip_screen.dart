import 'package:flutter/material.dart';
import '../services/special_trip_service.dart';
import 'special_trip_details_screen.dart';

enum TripCategory {desert,        
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
      appBar: AppBar(
        title: const Text('Special Trip',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTabs(),
              ),
              const SizedBox(height: 16),
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
              Expanded(
                child: ListView.builder(
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: TripCategory.values.map((cat) {
        final isSelected = selectedCategory == cat;

        return GestureDetector(
          onTap: () => setState(() => selectedCategory = cat),
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              children: [
                Text(
                  cat.name.capitalize(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 2,
                    width: 20,
                    color: Colors.black,
                  )
              ],
            ),
          ),
        );
      }).toList(),
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
          width: 240,
          height: 330,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            image: DecorationImage(
              image: NetworkImage(trip['image_url']),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
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
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
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
