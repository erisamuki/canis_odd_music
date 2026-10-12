import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/music.dart';
import '../../services/api_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late Future<List<Music>> _musicFuture;

  int? _currentTrackId;
  bool _loadingTrack = false;

  @override
  void initState() {
    super.initState();
    _musicFuture = ApiService.getMusic();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _refreshMusic() async {
    setState(() {
      _musicFuture = ApiService.getMusic();
    });
  }

  Future<void> _playTrack(Music track) async {
    try {
      setState(() {
        _loadingTrack = true;
        _currentTrackId = track.id;
      });

      final audioUrl = ApiService.getFileUrl(track.audioUrl);

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to play ${track.title}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingTrack = false;
        });
      }
    }
  }

  Future<void> _toggleTrack(Music track) async {
    if (_currentTrackId != track.id) {
      await _playTrack(track);
      return;
    }

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _seek(double value) async {
    await _audioPlayer.seek(
      Duration(milliseconds: value.round()),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CANIS ODD MUSIC'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshMusic,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Music>>(
        future: _musicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error.toString(),
            );
          }

          final music = snapshot.data ?? [];

          if (music.isEmpty) {
            return const Center(
              child: Text(
                'No music available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshMusic,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: music.length,
              itemBuilder: (context, index) {
                final track = music[index];

                return _MusicCard(
                  music: track,
                  isCurrentTrack: _currentTrackId == track.id,
                  isPlaying: _currentTrackId == track.id &&
                      _audioPlayer.playing,
                  isLoading: _loadingTrack &&
                      _currentTrackId == track.id,
                  onPlay: () => _toggleTrack(track),
                  audioPlayer: _audioPlayer,
                  formatDuration: _formatDuration,
                  onSeek: _seek,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load music',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshMusic,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicCard extends StatelessWidget {
  final Music music;
  final bool isCurrentTrack;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlay;
  final AudioPlayer audioPlayer;
  final String Function(Duration) formatDuration;
  final Future<void> Function(double) onSeek;

  const _MusicCard({
    required this.music,
    required this.isCurrentTrack,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlay,
    required this.audioPlayer,
    required this.formatDuration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildCover(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTrackInfo(),
                ),
                const SizedBox(width: 8),
                _buildPlayButton(),
              ],
            ),
            if (isCurrentTrack) ...[
              const SizedBox(height: 16),
              _buildProgress(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: music.coverImage != null &&
              music.coverImage!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ApiService.getFileUrl(music.coverImage!),
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.music_note,
                    size: 36,
                  );
                },
              ),
            )
          : const Icon(
              Icons.music_note,
              size: 36,
            ),
    );
  }

  Widget _buildTrackInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          music.title.isNotEmpty
              ? music.title
              : 'Untitled',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          music.artist ?? 'Unknown artist',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          '${music.price} UGX',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return IconButton(
      tooltip: isPlaying ? 'Pause' : 'Play',
      iconSize: 48,
      onPressed: isLoading ? null : onPlay,
      icon: isLoading
          ? const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            )
          : Icon(
              isPlaying
                  ? Icons.pause_circle
                  : Icons.play_circle,
            ),
    );
  }

  Widget _buildProgress() {
    return StreamBuilder<Duration>(
      stream: audioPlayer.positionStream,
      builder: (context, positionSnapshot) {
        final position =
            positionSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration?>(
          stream: audioPlayer.durationStream,
          builder: (context, durationSnapshot) {
            final duration =
                durationSnapshot.data ?? Duration.zero;

            final maximum =
                duration.inMilliseconds.toDouble();

            final sliderMaximum =
                maximum > 0 ? maximum : 1.0;

            final sliderValue = position
                .inMilliseconds
                .clamp(
                  0,
                  maximum > 0 ? maximum : 1,
                )
                .toDouble();

            return Column(
              children: [
                Slider(
                  min: 0,
                  max: sliderMaximum,
                  value: sliderValue,
                  onChanged: maximum > 0
                      ? onSeek
                      : null,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(position)),
                    Text(formatDuration(duration)),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
