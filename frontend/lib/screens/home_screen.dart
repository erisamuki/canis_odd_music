import 'package:flutter/material.dart';

import 'booking_screen.dart';
import 'donation_screen.dart';
import 'music_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openMusic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MusicScreen(),
      ),
    );
  }

  void _openBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingScreen(),
      ),
    );
  }

  void _openSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DonationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CANIS ODD MUSIC',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          if (isWide) ...[
            TextButton(
              onPressed: () => _openMusic(context),
              child: const Text('Music'),
            ),
            TextButton(
              onPressed: () => _openBooking(context),
              child: const Text('Booking'),
            ),
            TextButton(
              onPressed: () => _openSupport(context),
              child: const Text('Support'),
            ),
          ] else
            PopupMenuButton<String>(
              tooltip: 'Open menu',
              onSelected: (value) {
                switch (value) {
                  case 'music':
                    _openMusic(context);
                    break;
                  case 'booking':
                    _openBooking(context);
                    break;
                  case 'support':
                    _openSupport(context);
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'music', child: Text('Music')),
                PopupMenuItem(value: 'booking', child: Text('Booking')),
                PopupMenuItem(value: 'support', child: Text('Support')),
              ],
            ),
          IconButton(
            tooltip: 'Admin dashboard',
            onPressed: () => Navigator.pushNamed(context, '/admin'),
            icon: const Icon(Icons.admin_panel_settings_outlined),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildLatestMusic(context),
            _buildActions(context),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 480,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 70,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CANIS ODD MUSIC',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Official music, releases and digital content.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => _openMusic(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Text('EXPLORE MUSIC'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _openBooking(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Text('BOOK CANIS ODD'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestMusic(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latest Music',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Listen to the latest CANIS ODD MUSIC releases.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latest releases',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'View available music and listen online.',
                                style: TextStyle(
                                  color: Color(0xFFFFC107),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _openMusic(context),
                          child: const Text('VIEW MUSIC'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 750;

              final cards = [
                _ActionCard(
                  title: 'Listen',
                  description:
                      'Listen to available CANIS ODD MUSIC releases.',
                  buttonText: 'LISTEN',
                  icon: Icons.headphones,
                  onPressed: () => _openMusic(context),
                ),
                _ActionCard(
                  title: 'Download',
                  description:
                      'Purchase music downloads for 700 UGX.',
                  buttonText: 'DOWNLOAD',
                  icon: Icons.download,
                  onPressed: () => _openMusic(context),
                ),
                _ActionCard(
                  title: 'Booking',
                  description:
                      'Send a booking request for Canis Odd.',
                  buttonText: 'BOOK NOW',
                  icon: Icons.event,
                  onPressed: () => _openBooking(context),
                ),
                _ActionCard(
                  title: 'Support',
                  description:
                      'Support CANIS ODD MUSIC through a donation.',
                  buttonText: 'SUPPORT',
                  icon: Icons.favorite_border,
                  onPressed: () => _openSupport(context),
                ),
              ];

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards
                      .map(
                        (card) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            child: card,
                          ),
                        ),
                      )
                      .toList(),
                );
              }

              return Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 14),
                        child: card,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 45,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CANIS ODD MUSIC',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Official music, releases, bookings and digital content.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 22),
              Text(
                'Soroti, Uganda',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'canisodd23@gmail.com',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 25),
              Divider(
                color: Colors.white24,
              ),
              SizedBox(height: 18),
              Text(
                '© CANIS ODD MUSIC',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 30,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFFFFC107),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}