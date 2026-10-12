import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 850;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.brand,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (isWide) ...[
            _navButton('Music'),
            _navButton('Videos'),
            _navButton('Booking'),
            _navButton('Support'),
            IconButton(
              tooltip: 'Admin dashboard',
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
            const SizedBox(width: 12),
          ] else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'admin') {
                  Navigator.pushNamed(context, '/admin');
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'music', child: Text('Music')),
                PopupMenuItem(value: 'videos', child: Text('Videos')),
                PopupMenuItem(value: 'booking', child: Text('Booking')),
                PopupMenuItem(value: 'support', child: Text('Support')),
                PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined),
                      SizedBox(width: 12),
                      Text('Admin dashboard'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _hero(context, isWide),
            _section(
              context,
              title: 'Latest Music',
              subtitle: 'New releases from Canis Odd.',
              child: _musicCards(isWide),
            ),
            _section(
              context,
              title: 'Featured Video',
              subtitle: 'Watch the latest visual release.',
              child: _videoCard(isWide),
            ),
            _supportSection(context, isWide),
            _bookingSection(context, isWide),
            _footer(context),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 72 : 24,
        vertical: isWide ? 110 : 72,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF242424), Color(0xFF0A0A0A)],
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CANIS ODD',
              style: TextStyle(
                color: Color(0xFFD9A441),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Music from Teso.\nMade to be heard.',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 18),
            const SizedBox(
              width: 600,
              child: Text(
                'Discover releases, watch videos, support the music, and book Canis Odd for your next event.',
                style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.6),
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(onPressed: () {}, child: const Text('Listen')),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Download — 700 UGX'),
                ),
                OutlinedButton(onPressed: () {}, child: const Text('Support')),
                OutlinedButton(onPressed: () {}, child: const Text('Book Now')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _musicCards(bool isWide) {
    final cards = [
      _MusicCard(title: 'Latest Release', meta: 'New release', price: AppConstants.downloadPriceUgx),
      _MusicCard(title: 'Featured Track', meta: 'Single', price: AppConstants.downloadPriceUgx),
      _MusicCard(title: 'Popular Track', meta: 'Single', price: AppConstants.downloadPriceUgx),
    ];

    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: cards
          .map((card) => SizedBox(width: isWide ? 340 : double.infinity, child: card))
          .toList(),
    );
  }

  Widget _videoCard(bool isWide) {
    return Container(
      width: double.infinity,
      height: isWide ? 320 : 220,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, size: 64, color: Color(0xFFD9A441)),
            SizedBox(height: 12),
            Text('Featured video will appear here', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _supportSection(BuildContext context, bool isWide) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF151515),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 24),
                      child: _SupportCopy(),
                    ),
                  ),
                  FilledButton(onPressed: () {}, child: const Text('Support Canis Odd')),
                ],
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SupportCopy(),
                  SizedBox(height: 24),
                  FilledButton(onPressed: null, child: Text('Support Canis Odd')),
                ],
              ),
      ),
    );
  }

  Widget _bookingSection(BuildContext context, bool isWide) {
    return _section(
      context,
      title: 'Book Canis Odd',
      subtitle: 'For events, performances and appearances.',
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Send your event details and booking request. The team will respond with availability and next steps.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87, height: 1.6),
            ),
          ),
          if (isWide) const SizedBox(width: 32),
          if (isWide) OutlinedButton(onPressed: () {}, child: const Text('Book Now')),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      color: const Color(0xFF050505),
      child: const Wrap(
        spacing: 28,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          Text(AppConstants.email, style: TextStyle(color: Colors.white60)),
          Text(AppConstants.whatsapp, style: TextStyle(color: Colors.white60)),
          Text(AppConstants.telephone, style: TextStyle(color: Colors.white60)),
          Text(AppConstants.location, style: TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _navButton(String label) {
    return TextButton(onPressed: () {}, child: Text(label));
  }
}

class _MusicCard extends StatelessWidget {
  const _MusicCard({required this.title, required this.meta, required this.price});

  final String title;
  final String meta;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: 1.5,
            child: ColoredBox(
              color: Color(0xFF202020),
              child: Center(child: Icon(Icons.album_outlined, size: 52, color: Colors.white38)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.black),
                ),
                const SizedBox(height: 5),
                Text(meta, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Listen'))),
                    const SizedBox(width: 10),
                    Expanded(child: FilledButton(onPressed: () {}, child: Text('$price UGX'))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCopy extends StatelessWidget {
  const _SupportCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support the music',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        SizedBox(height: 10),
        Text(
          'Choose any amount. There is no maximum donation.',
          style: TextStyle(color: Colors.white60, height: 1.5),
        ),
      ],
    );
  }
}