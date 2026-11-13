import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';
import '../models/music.dart';
import '../services/api_service.dart';
import 'booking_screen.dart';
import 'donation_screen.dart';
import 'music_screen.dart';
import '../widgets/site_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _heroImages = [
    'assets/images/IMG-20241017-WA0109.jpg',
    'assets/images/IMG-20241017-WA0099.jpg',
    'assets/images/1789678898712.jpg',
    'assets/images/1789679397834.jpg',
    'assets/images/1789680735024.jpg',
    'assets/images/SAVE_20260929_232704.jpg',
    'assets/images/_MG_4462.jpg',
    'assets/images/file_00000000735c821191e7d6fce0c34da8.png',
  ];

  final PageController _heroPageController = PageController();
  Timer? _heroTimer;
  int _currentHeroImage = 0;
  late Future<List<Music>> _musicFuture;

  @override
  void initState() {
    super.initState();
    _musicFuture = ApiService.getMusic();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final nextPage = (_currentHeroImage + 1) % _heroImages.length;
      _heroPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
    super.dispose();
  }

  void _reloadMusic() {
    setState(() {
      _musicFuture = ApiService.getMusic();
    });
  }

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
      backgroundColor: Colors.transparent,
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
      body: SiteBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(context),
              _buildLatestMusic(context),
              _buildActions(context),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSideBySide = width >= 680;
    final isWide = width >= 920;

    return SizedBox(
      width: double.infinity,
      height: isSideBySide ? 560 : 720,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xD9000000),
                  Color(0x99000000),
                  Color(0x26000000),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSideBySide ? 32 : 24,
              vertical: isSideBySide ? 48 : 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isSideBySide
                    ? Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildHeroCopy(context, isWide),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 4,
                            child: _buildHeroSlideshow(),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 250,
                            child: _buildHeroSlideshow(),
                          ),
                          const SizedBox(height: 24),
                          Expanded(child: _buildHeroCopy(context, isWide)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCopy(BuildContext context, bool isWide) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INDEPENDENT SOUND  /  FROM TESO, UGANDA',
          style: TextStyle(
            color: Color(0xFFD9A441),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        SizedBox(height: isWide ? 18 : 12),
        Text(
          'Sound from Teso.\nMade to be heard.',
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 50 : 34,
            fontWeight: FontWeight.w800,
            height: 1.04,
            letterSpacing: -1.2,
          ),
        ),
        SizedBox(height: isWide ? 18 : 12),
        const Text(
          'Original music, live shows, and stories from Teso.',
          style: TextStyle(
            fontSize: 17,
            color: Colors.white70,
            height: 1.55,
          ),
        ),
        SizedBox(height: isWide ? 28 : 18),
        Wrap(
          spacing: isWide ? 12 : 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => _openMusic(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 14,
                  vertical: 14,
                ),
                minimumSize: const Size(0, 48),
              ),
              child: const Text('LISTEN NOW'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 14,
                  vertical: 14,
                ),
                minimumSize: const Size(0, 48),
              ),
              onPressed: () => _openBooking(context),
              child: const Text('BOOK A SHOW'),
            ),
          ],
        ),
        SizedBox(height: isWide ? 24 : 14),
        const Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: Color(0xFFD9A441), size: 18),
            SizedBox(width: 6),
            Text(
              'SOROTI  /  UGANDA',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSlideshow() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _heroPageController,
            itemCount: _heroImages.length,
            onPageChanged: (index) {
              setState(() => _currentHeroImage = index);
            },
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset(
                _heroImages[index],
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: List.generate(_heroImages.length, (index) {
            return GestureDetector(
              onTap: () => _heroPageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: index == _currentHeroImage ? 10 : 7,
                  height: index == _currentHeroImage ? 10 : 7,
                  decoration: BoxDecoration(
                    color: index == _currentHeroImage
                        ? Colors.white
                        : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLatestMusic(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE CATALOG',
                          style: TextStyle(
                            color: Color(0xFFD9A441),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Latest releases',
                          style: TextStyle(
                            fontSize: 34,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openMusic(context),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('ALL MUSIC'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'New sounds and fan favorites from Canis Odd.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              FutureBuilder<List<Music>>(
                future: _musicFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _musicMessage(
                      "Couldn't load the latest releases.",
                      action: TextButton.icon(
                        onPressed: _reloadMusic,
                        icon: const Icon(Icons.refresh),
                        label: const Text('TRY AGAIN'),
                      ),
                    );
                  }

                  final releases = snapshot.data!.take(3).toList();
                  if (releases.isEmpty) {
                    return _musicMessage(
                      'New music is on the way.',
                      action: TextButton(
                        onPressed: () => _openMusic(context),
                        child: const Text('EXPLORE THE CATALOG'),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 760;
                      final cardWidth = isWide
                          ? (constraints.maxWidth - 36) / 3
                          : constraints.maxWidth;

                      return Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        children: [
                          for (var index = 0; index < releases.length; index++)
                            SizedBox(
                              width: cardWidth,
                              child: _ReleaseCard(
                                music: releases[index],
                                index: index,
                                onOpen: () => _openMusic(context),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _musicMessage(
    String message, {
    required Widget action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xCC111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Text(message, style: const TextStyle(color: Colors.white70)),
          action,
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MORE THAN THE MUSIC',
                style: TextStyle(
                  color: Color(0xFFD9A441),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Find your way in.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 750;

                  final cards = [
                    _ActionCard(
                      title: 'Listen',
                      description: 'Explore releases and play your favorites.',
                      buttonText: 'LISTEN NOW',
                      icon: Icons.headphones,
                      onPressed: () => _openMusic(context),
                    ),
                    _ActionCard(
                      title: 'Downloads',
                      description: 'Get your favorite tracks for 700 UGX.',
                      buttonText: 'VIEW MUSIC',
                      icon: Icons.download_outlined,
                      onPressed: () => _openMusic(context),
                    ),
                    _ActionCard(
                      title: 'Booking',
                      description:
                          'Bring the Canis Odd live show to your event.',
                      buttonText: 'BOOK A SHOW',
                      icon: Icons.mic_none,
                      onPressed: () => _openBooking(context),
                    ),
                    _ActionCard(
                      title: 'Support',
                      description: 'Help keep independent music moving.',
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
                                padding: const EdgeInsets.symmetric(
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
                            padding: const EdgeInsets.only(bottom: 14),
                            child: card,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xE6090909),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final brand = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.brand.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Independent music from Soroti, Uganda.',
                    style: TextStyle(color: Colors.white60, height: 1.5),
                  ),
                ],
              );
              final contact = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONTACT & BOOKINGS',
                    style: TextStyle(
                      color: Color(0xFFD9A441),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 22,
                    runSpacing: 12,
                    children: [
                      _contactItem(
                        context,
                        Icons.email_outlined,
                        AppConstants.email,
                        Uri(scheme: 'mailto', path: AppConstants.email),
                      ),
                      _contactItem(
                        context,
                        Icons.chat_bubble_outline,
                        AppConstants.whatsapp,
                        Uri.https(
                          'wa.me',
                          '/${AppConstants.whatsapp.replaceAll(RegExp(r'\D'), '')}',
                        ),
                      ),
                      _contactItem(
                        context,
                        Icons.phone_outlined,
                        AppConstants.telephone,
                        Uri(
                          scheme: 'tel',
                          path: AppConstants.telephone.replaceAll(' ', ''),
                        ),
                      ),
                      _contactItem(
                        context,
                        Icons.location_on_outlined,
                        AppConstants.location,
                        null,
                      ),
                    ],
                  ),
                ],
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: brand),
                        const SizedBox(width: 48),
                        Expanded(flex: 2, child: contact),
                      ],
                    )
                  else ...[
                    brand,
                    const SizedBox(height: 30),
                    contact,
                  ],
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 18),
                  const Text(
                    '© CANIS ODD MUSIC',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _contactItem(
    BuildContext context,
    IconData icon,
    String label,
    Uri? destination,
  ) {
    final item = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: const Color(0xFFD9A441)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );

    if (destination == null) return item;

    return InkWell(
      onTap: () async {
        final launched = await launchUrl(
          destination,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open this contact link.')),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: item,
      ),
    );
  }
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({
    required this.music,
    required this.index,
    required this.onOpen,
  });

  final Music music;
  final int index;
  final VoidCallback onOpen;

  Widget _fallbackCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF32230D), Color(0xFF111111), Color(0xFF202020)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.graphic_eq_rounded,
              size: 44,
              color: Color(0xFFD9A441),
            ),
            const SizedBox(height: 10),
            Text(
              'CANIS ODD  /  ${index + 1}'.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coverImage = music.coverImage;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: const Color(0xF0151515),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.45,
            child: coverImage == null || coverImage.isEmpty
                ? _fallbackCover()
                : Image.network(
                    ApiService.getFileUrl(coverImage),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackCover(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  music.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  music.artist?.isNotEmpty == true
                      ? music.artist!
                      : 'Canis Odd',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${music.price} UGX',
                        style: const TextStyle(
                          color: Color(0xFFD9A441),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('LISTEN'),
                    ),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0x1FD9A441),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 25,
                color: const Color(0xFFD9A441),
              ),
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
                color: Colors.white70,
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
