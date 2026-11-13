import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/music.dart';
import '../services/api_service.dart';
import '../widgets/site_background.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late Future<List<Music>> musicFuture;

  int? currentTrackId;
  bool loadingTrack = false;

  @override
  void initState() {
    super.initState();

    musicFuture = ApiService.getMusic();

    // When a song finishes, reset the selected track.
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        setState(() {
          currentTrackId = null;
          loadingTrack = false;
        });
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadMusic() async {
    setState(() {
      musicFuture = ApiService.getMusic();
    });
  }

  Future<void> playMusic(Music music) async {
    try {
      setState(() {
        loadingTrack = true;
        currentTrackId = music.id;
      });

      final url = ApiService.getFileUrl(music.audioUrl);

      // Stop the previous song completely.
      await _audioPlayer.stop();

      // Remove the previous audio source and load the new one.
      await _audioPlayer.setUrl(url);

      // Always start the newly selected song from the beginning.
      await _audioPlayer.seek(Duration.zero);

      // Start the new song.
      await _audioPlayer.play();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        currentTrackId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to play ${music.title}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingTrack = false;
        });
      }
    }
  }

  Future<void> toggleMusic(Music music) async {
    // Different song selected.
    if (currentTrackId != music.id) {
      await playMusic(music);
      return;
    }

    // Same song selected.
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music'),
        actions: [
          IconButton(
            onPressed: loadMusic,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SiteBackground(
        child: FutureBuilder<List<Music>>(
          future: musicFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Unable to load music',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: loadMusic,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final music = snapshot.data ?? [];

            if (music.isEmpty) {
              return const Center(
                child: Text(
                  'No music available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Listen to AudioPlayer state changes so the UI
            // always knows whether the current song is playing.
            return StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (context, playerSnapshot) {
                final playerState = playerSnapshot.data;

                final isPlaying = playerState?.playing ?? false;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: music.length,
                  itemBuilder: (context, index) {
                    final track = music[index];

                    return _MusicCard(
                      music: track,
                      isCurrentTrack: currentTrackId == track.id,
                      isPlaying: currentTrackId == track.id && isPlaying,
                      isLoading: loadingTrack && currentTrackId == track.id,
                      onPlay: () => toggleMusic(track),
                      audioPlayer: _audioPlayer,
                    );
                  },
                );
              },
            );
          },
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

  const _MusicCard({
    required this.music,
    required this.isCurrentTrack,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlay,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: music.coverImage == null || music.coverImage!.isEmpty
                        ? const ColoredBox(
                            color: Color(0xFF32230D),
                            child: Icon(
                              Icons.graphic_eq_rounded,
                              size: 36,
                              color: Color(0xFFD9A441),
                            ),
                          )
                        : Image.network(
                            ApiService.getFileUrl(music.coverImage!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const ColoredBox(
                              color: Color(0xFF32230D),
                              child: Icon(
                                Icons.graphic_eq_rounded,
                                size: 36,
                                color: Color(0xFFD9A441),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        music.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        music.artist ?? 'Unknown artist',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${music.price} UGX',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 48,
                  onPressed: isLoading ? null : onPlay,
                  icon: isLoading
                      ? const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(),
                        )
                      : Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                        ),
                ),
              ],
            ),
            if (isCurrentTrack) ...[
              const SizedBox(height: 12),
              StreamBuilder<Duration>(
                stream: audioPlayer.positionStream,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;

                  return StreamBuilder<Duration?>(
                    stream: audioPlayer.durationStream,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;

                      final max = duration.inMilliseconds.toDouble();

                      final value = position.inMilliseconds
                          .clamp(
                            0,
                            max > 0 ? max : 1,
                          )
                          .toDouble();

                      return Column(
                        children: [
                          Slider(
                            min: 0,
                            max: max > 0 ? max : 1,
                            value: value,
                            onChanged: max > 0
                                ? (newValue) {
                                    audioPlayer.seek(
                                      Duration(
                                        milliseconds: newValue.round(),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                              ),
                              Text(
                                _formatDuration(duration),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
}
