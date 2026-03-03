import 'package:flutter/material.dart';
import 'event_details_screen.dart';

class UpcomingEventsScreen extends StatelessWidget {
  const UpcomingEventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Upcoming Events'),
      ),
      body: Container(
        color: Colors.grey[50],
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildEventCard(
              context,
              'Symphony',
              'assets/images/symphony.jpg',
              'Annual cultural fest showcasing music, dance, and drama performances',
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Abhiyantriki',
              'assets/images/abhiyantriki.jpg',
              'Technical festival featuring robotics, coding competitions, and workshops',
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Techmaze',
              'assets/images/techmaze.jpg',
              'Inter-college technical competition with various engineering challenges',
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Sports Meet',
              'assets/images/sports.jpg',
              'Annual sports day with various athletic events and competitions',
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Hackathon',
              'assets/images/hackathon.jpg',
              '24-hour coding challenge to innovate and create solutions',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String eventName, String imagePath, String description) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventName: eventName,
              imagePath: imagePath,
              description: description,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    // If image fails to load, use a placeholder
                  },
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
