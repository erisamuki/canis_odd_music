import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;

  const AdminDashboardScreen({
    super.key,
    required this.token,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedPage = 0;

  bool isLoading = true;
  bool backendOnline = false;

  List<Map<String, dynamic>> music = [];
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> videos = [];
  List<Map<String, dynamic>> donations = [];
  List<Map<String, dynamic>> payments = [];
  List<Map<String, dynamic>> sliders = [];
  List<Map<String, dynamic>> socialLinks = [];
  List<Map<String, dynamic>> siteSettings = [];
  Map<String, dynamic> stats = {};

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getAdminDashboard(widget.token),
        ApiService.getAdminMusic(widget.token),
        ApiService.getAdminBookings(widget.token),
        ApiService.getAdminVideos(widget.token),
        ApiService.getAdminDonations(widget.token),
        ApiService.getAdminPayments(widget.token),
        ApiService.getAdminHomepage(widget.token),
        ApiService.getAdminSettings(widget.token),
      ]);

      if (!mounted) return;

      setState(() {
        backendOnline = true;
        stats = results[0] as Map<String, dynamic>;
        music = results[1] as List<Map<String, dynamic>>;
        bookings = results[2] as List<Map<String, dynamic>>;
        videos = results[3] as List<Map<String, dynamic>>;
        donations = results[4] as List<Map<String, dynamic>>;
        payments = results[5] as List<Map<String, dynamic>>;
        final homepage = results[6] as Map<String, dynamic>;
        final settings = results[7] as List<Map<String, dynamic>>;
        sliders = (homepage['sliders'] as List<dynamic>? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        socialLinks = (homepage['socialLinks'] as List<dynamic>? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        siteSettings = settings;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _selectPage(int index) {
    setState(() {
      selectedPage = index;
    });
  }

  Future<void> _addMusic() async {
    final uploaded = await showDialog<bool>(
      context: context,
      builder: (_) => _AddMusicDialog(token: widget.token),
    );
    if (uploaded == true && mounted) {
      await _loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => Navigator.of(context).popUntil(
              (route) => route.isFirst,
            ),
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              children: [
                SizedBox(
                  width: 250,
                  child: _AdminSidebar(
                    selectedPage: selectedPage,
                    onSelected: _selectPage,
                  ),
                ),
                Expanded(
                  child: _buildPage(),
                ),
              ],
            );
          }

          return _buildPage();
        },
      ),
      drawer: MediaQuery.sizeOf(context).width < 900
          ? Drawer(
              child: _AdminSidebar(
                selectedPage: selectedPage,
                onSelected: (index) {
                  Navigator.pop(context);
                  _selectPage(index);
                },
              ),
            )
          : null,
    );
  }

  Widget _buildPage() {
    switch (selectedPage) {
      case 0:
        return _DashboardHome(
          musicCount: music.length,
          bookingCount: bookings.length,
          downloadCount: _asInt(stats['downloads']),
          musicEarnings: _asInt(stats['musicEarnings']),
          backendOnline: backendOnline,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
          onMusicPressed: () => _selectPage(1),
          onBookingsPressed: () => _selectPage(2),
          onUploadPressed: _addMusic,
        );

      case 1:
        return _MusicPage(
          music: music,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
          onAddMusic: _addMusic,
        );

      case 2:
        return _BookingsPage(
          bookings: bookings,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
        );

      case 3:
        return _VideosPage(
          videos: videos,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
        );

      case 4:
        return _DonationsPage(
          donations: donations,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
        );

      case 5:
        return _DownloadsPage(
          downloads: _asInt(stats['downloads']),
          earnings: _asInt(stats['musicEarnings']),
          music: music,
        );

      case 6:
        return _PaymentsPage(
          payments: payments,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
        );

      case 7:
        return _HomepagePage(
          sliders: sliders,
          socialLinks: socialLinks,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
        );

      case 8:
        return _SettingsPage(
          settings: siteSettings,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
        );

      default:
        return _DashboardHome(
          musicCount: music.length,
          bookingCount: bookings.length,
          downloadCount: _asInt(stats['downloads']),
          musicEarnings: _asInt(stats['musicEarnings']),
          backendOnline: backendOnline,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: _loadDashboard,
          onMusicPressed: () => _selectPage(1),
          onBookingsPressed: () => _selectPage(2),
          onUploadPressed: _addMusic,
        );
    }
  }
}

int _asInt(dynamic value) => value is num ? value.toInt() : 0;

String _formatAmount(int amount) {
  final digits = amount.toString();
  return digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

class _AdminSidebar extends StatelessWidget {
  final int selectedPage;
  final ValueChanged<int> onSelected;

  const _AdminSidebar({
    required this.selectedPage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Text(
                'CANIS ODD MUSIC',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _item(
              context,
              index: 0,
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
            ),
            _item(
              context,
              index: 1,
              icon: Icons.music_note_outlined,
              title: 'Music',
            ),
            _item(
              context,
              index: 2,
              icon: Icons.event_outlined,
              title: 'Bookings',
            ),
            _item(
              context,
              index: 3,
              icon: Icons.video_library_outlined,
              title: 'Videos',
            ),
            const Divider(height: 32),
            _item(
              context,
              index: 4,
              icon: Icons.volunteer_activism_outlined,
              title: 'Donations',
            ),
            _item(
              context,
              index: 5,
              icon: Icons.download_outlined,
              title: 'Downloads',
            ),
            _item(
              context,
              index: 6,
              icon: Icons.payments_outlined,
              title: 'Payments',
            ),
            const Divider(height: 32),
            _item(
              context,
              index: 7,
              icon: Icons.home_outlined,
              title: 'Homepage',
            ),
            _item(
              context,
              index: 8,
              icon: Icons.settings_outlined,
              title: 'Settings',
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedPage == index,
      onTap: () => onSelected(index),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final int musicCount;
  final int bookingCount;
  final int downloadCount;
  final int musicEarnings;
  final bool backendOnline;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onMusicPressed;
  final VoidCallback onBookingsPressed;
  final VoidCallback onUploadPressed;

  const _DashboardHome({
    required this.musicCount,
    required this.bookingCount,
    required this.downloadCount,
    required this.musicEarnings,
    required this.backendOnline,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onMusicPressed,
    required this.onBookingsPressed,
    required this.onUploadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage Canis Odd Music.Com from one place.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (errorMessage != null)
            _ErrorCard(
              message: errorMessage!,
              onRefresh: onRefresh,
            ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: LinearProgressIndicator(),
            ),
          _BackendStatus(
            online: backendOnline,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 4 : 2;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: [
                  _StatCard(
                    title: 'Music',
                    value: musicCount.toString(),
                    icon: Icons.music_note_outlined,
                    onTap: onMusicPressed,
                  ),
                  _StatCard(
                    title: 'Bookings',
                    value: bookingCount.toString(),
                    icon: Icons.event_outlined,
                    onTap: onBookingsPressed,
                  ),
                  _StatCard(
                    title: 'Downloads',
                    value: downloadCount.toString(),
                    icon: Icons.download_outlined,
                  ),
                  _StatCard(
                    title: 'Music earnings',
                    value: 'UGX ${_formatAmount(musicEarnings)}',
                    icon: Icons.payments_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: onMusicPressed,
                icon: const Icon(
                  Icons.music_note_outlined,
                ),
                label: const Text('Manage Music'),
              ),
              OutlinedButton.icon(
                onPressed: onBookingsPressed,
                icon: const Icon(
                  Icons.event_outlined,
                ),
                label: const Text('View Bookings'),
              ),
              OutlinedButton.icon(
                onPressed: onUploadPressed,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Upload Music'),
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text('Refresh Data'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(height: 10),
              Text(title),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendStatus extends StatelessWidget {
  final bool online;

  const _BackendStatus({
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          online ? Icons.check_circle_outline : Icons.error_outline,
        ),
        title: Text(
          online ? 'Backend Connected' : 'Backend Offline',
        ),
        subtitle: Text(
          online
              ? 'Node.js API is responding normally.'
              : 'Unable to connect to the Node.js API.',
        ),
      ),
    );
  }
}

class _MusicPage extends StatelessWidget {
  final List<Map<String, dynamic>> music;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onAddMusic;

  const _MusicPage({
    required this.music,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onAddMusic,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Music',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton.icon(
                onPressed: onAddMusic,
                icon: const Icon(Icons.add),
                label: const Text('Add Music'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${music.length} published tracks',
          ),
          const SizedBox(height: 24),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            _ErrorCard(
              message: errorMessage!,
              onRefresh: onRefresh,
            ),
          const SizedBox(height: 16),
          if (!isLoading && music.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No music found.',
                  ),
                ),
              ),
            ),
          ...music.map(
            (item) => _MusicAdminCard(
              music: item,
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicAdminCard extends StatelessWidget {
  final Map<String, dynamic> music;

  const _MusicAdminCard({
    required this.music,
  });

  @override
  Widget build(BuildContext context) {
    final title = music['title']?.toString() ?? 'Untitled';
    final artist = music['artist']?.toString() ?? 'Canis Odd';
    final price = _asInt(music['price']);
    final downloadCount = _asInt(music['downloadCount']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.music_note),
        ),
        title: Text(title),
        subtitle: Text(
          '$artist • UGX $price • $downloadCount downloads',
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}

class _DownloadsPage extends StatelessWidget {
  final int downloads;
  final int earnings;
  final List<Map<String, dynamic>> music;

  const _DownloadsPage({
    required this.downloads,
    required this.earnings,
    required this.music,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Downloads and earnings',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Counts are successfully downloaded paid links. Earnings include completed music payments only.',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final statsCards = [
              _StatCard(
                title: 'Completed downloads',
                value: downloads.toString(),
                icon: Icons.download_outlined,
              ),
              _StatCard(
                title: 'Music earnings',
                value: 'UGX ${_formatAmount(earnings)}',
                icon: Icons.payments_outlined,
              ),
            ];
            if (constraints.maxWidth < 520) {
              return Column(
                children: [
                  statsCards[0],
                  const SizedBox(height: 12),
                  statsCards[1],
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: statsCards[0]),
                const SizedBox(width: 12),
                Expanded(child: statsCards[1]),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text('Downloads by track',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (music.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No tracks available yet.'),
            ),
          ),
        ...music.map((track) => _MusicAdminCard(music: track)),
      ],
    );
  }
}

class _VideosPage extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const _VideosPage({
    required this.videos,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Videos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${videos.length} videos'),
          const SizedBox(height: 24),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            _ErrorCard(message: errorMessage!, onRefresh: onRefresh),
          const SizedBox(height: 16),
          if (!isLoading && videos.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No videos found.'),
                ),
              ),
            ),
          ...videos.map(
            (video) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: Text(video['title']?.toString() ?? 'Untitled video'),
                subtitle: Text(
                  video['description']?.toString() ??
                      video['videoUrl']?.toString() ??
                      'No description',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> donations;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const _DonationsPage({
    required this.donations,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Donations',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${donations.length} donation entries'),
          const SizedBox(height: 24),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            _ErrorCard(message: errorMessage!, onRefresh: onRefresh),
          const SizedBox(height: 16),
          if (!isLoading && donations.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No donations found.'),
                ),
              ),
            ),
          ...donations.map(
            (donation) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.volunteer_activism_outlined),
                title: Text(
                  'UGX ${_formatAmount(_asInt(donation['amount']))}',
                ),
                subtitle: Text(
                  '${donation['name']?.toString() ?? 'Anonymous'} • ${donation['email']?.toString() ?? 'No email'}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsPage extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const _PaymentsPage({
    required this.payments,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payments',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${payments.length} payment records'),
          const SizedBox(height: 24),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            _ErrorCard(message: errorMessage!, onRefresh: onRefresh),
          const SizedBox(height: 16),
          if (!isLoading && payments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No payments found.'),
                ),
              ),
            ),
          ...payments.map(
            (payment) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(
                  'UGX ${_formatAmount(_asInt(payment['amount']))}',
                ),
                subtitle: Text(
                  '${payment['status']?.toString() ?? 'PENDING'} • ${payment['method']?.toString() ?? 'Unknown'}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMusicDialog extends StatefulWidget {
  final String token;

  const _AddMusicDialog({required this.token});

  @override
  State<_AddMusicDialog> createState() => _AddMusicDialogState();
}

class _AddMusicDialogState extends State<_AddMusicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _priceController = TextEditingController(text: '700');

  PlatformFile? _audioFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp3', 'wav'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      if (file.size > 50 * 1024 * 1024) {
        throw Exception('Audio files must be 50 MB or smaller.');
      }
      if (file.bytes == null) {
        throw Exception('Could not read the selected audio file.');
      }

      setState(() {
        _audioFile = file;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    final audio = _audioFile;
    if (audio == null || audio.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose an MP3 or WAV file first.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await ApiService.uploadAdminMusic(
        token: widget.token,
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        filename: audio.name,
        bytes: audio.bytes!,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload music'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Song title'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the song title'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _artistController,
                  decoration: const InputDecoration(labelText: 'Artist'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Download price (UGX)',
                  ),
                  validator: (value) {
                    final price = int.tryParse(value?.trim() ?? '');
                    return price == null || price < 0
                        ? 'Enter a valid price'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _selectAudio,
                  icon: const Icon(Icons.audio_file_outlined),
                  label: Text(_audioFile?.name ?? 'Choose MP3 or WAV'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isUploading ? null : _upload,
          child: _isUploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }
}

class _BookingsPage extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const _BookingsPage({
    required this.bookings,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bookings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${bookings.length} bookings',
          ),
          const SizedBox(height: 24),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            _ErrorCard(
              message: errorMessage!,
              onRefresh: onRefresh,
            ),
          const SizedBox(height: 16),
          if (!isLoading && bookings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No bookings found.',
                  ),
                ),
              ),
            ),
          ...bookings.map(
            (booking) => _BookingAdminCard(
              booking: booking,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingAdminCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingAdminCard({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final name = booking['name']?.toString() ?? 'Unknown';
    final email = booking['email']?.toString() ?? '';
    final phone = booking['phone']?.toString() ?? '';
    final eventType = booking['eventType']?.toString() ?? '';
    final location = booking['location']?.toString() ?? '';
    final status = booking['status']?.toString() ?? 'PENDING';

    final eventDate = booking['eventDate']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusBadge(
                  status: status,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.event_outlined,
              text: eventType,
            ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: eventDate,
            ),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: location,
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              text: phone,
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              text: email,
            ),
            if (booking['message'] != null &&
                booking['message'].toString().isNotEmpty)
              _InfoRow(
                icon: Icons.message_outlined,
                text: booking['message'].toString(),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

class _HomepagePage extends StatelessWidget {
  final List<Map<String, dynamic>> sliders;
  final List<Map<String, dynamic>> socialLinks;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const _HomepagePage({
    required this.sliders,
    required this.socialLinks,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Homepage',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Hero sliders and social links managed from the backend.'),
          const SizedBox(height: 20),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            _ErrorCard(message: errorMessage!, onRefresh: onRefresh),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Hero sliders', count: sliders.length),
          if (sliders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No sliders configured yet.'),
              ),
            )
          else
            ...sliders.map(
              (slider) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(slider['title']?.toString() ?? 'Untitled slider'),
                  subtitle: Text(
                    '${slider['subtitle']?.toString() ?? ''} • ${slider['buttonText']?.toString() ?? 'No action'}',
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Social links', count: socialLinks.length),
          if (socialLinks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No active social links yet.'),
              ),
            )
          else
            ...socialLinks.map(
              (link) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.link_outlined),
                  title: Text(link['platform']?.toString() ?? 'Social link'),
                  subtitle: Text(link['url']?.toString() ?? ''),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  final List<Map<String, dynamic>> settings;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const _SettingsPage({
    required this.settings,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
              'Site settings currently loaded from the configured backend values.'),
          const SizedBox(height: 20),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            _ErrorCard(message: errorMessage!, onRefresh: onRefresh),
          const SizedBox(height: 20),
          if (settings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No site settings found.'),
              ),
            )
          else
            ...settings.map(
              (setting) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(setting['key']?.toString() ?? 'Setting'),
                  subtitle: Text(setting['value']?.toString() ?? ''),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Text('$count'),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRefresh;

  const _ErrorCard({
    required this.message,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to load dashboard data.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
