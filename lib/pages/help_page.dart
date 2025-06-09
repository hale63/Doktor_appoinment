import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  late VideoPlayerController _controller;
  bool _isVideoError = false;
  bool _isVideoInitializing = false;
  double _videoHeight = 200; // Smaller initial height

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      setState(() {
        _isVideoInitializing = true;
        _isVideoError = false;
      });

      _controller = VideoPlayerController.asset('assets/videos/app_intro.mp4');

      await _controller.initialize();
      await _controller.setLooping(true);

      if (mounted) {
        setState(() {
          _isVideoInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoError = true;
          _isVideoInitializing = false;
        });
      }
      debugPrint('Video player error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _retryVideoLoading() async {
    await _initializeVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final Color mor = const Color(0xFF6B46C1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım Sayfası'),
        backgroundColor: mor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Section
            _buildSectionTitle('Uygulama Hakkında'),
            const SizedBox(height: 10),
            const Text(
              'Bu uygulama sayesinde doktor randevularınızı kolayca planlayabilir, '
                  'randevu geçmişinizi görüntüleyebilir ve doktor bilgilerine hızlıca ulaşabilirsiniz. '
                  'Kullanıcı dostu arayüzü ile işlemlerinizi kolayca gerçekleştirebilirsiniz.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Video Section
            _buildSectionTitle('Uygulama Nasıl Kullanılıyor?'),
            const SizedBox(height: 10),
            _buildVideoPlayerSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final Color mor = const Color(0xFF6B46C1);

    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: mor,
      ),
    );
  }

  Widget _buildVideoPlayerSection() {
    if (_isVideoError) {
      return Column(
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 10),
          const Text(
            'Video yüklenirken bir hata oluştu',
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _retryVideoLoading,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      );
    }

    if (_isVideoInitializing) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Video yükleniyor...'),
          ],
        ),
      );
    }

    return Container(
      // Constrained video size
      height: _videoHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF6B46C1),
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
            Center(
              child: IconButton(
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 48,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
            ),
            // Size adjustment buttons
            Positioned(
              right: 8,
              top: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _videoHeight = (_videoHeight - 50).clamp(150, 400).toDouble();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _videoHeight = (_videoHeight + 50).clamp(150, 400).toDouble();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}