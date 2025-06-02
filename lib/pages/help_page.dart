import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/app_intro.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color mor = const Color(0xFF6B46C1); // Mor tema

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
            // Tanıtım Başlık
            Text(
              'Uygulama Hakkında',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: mor,
              ),
            ),
            const SizedBox(height: 10),

            // Tanıtım Metni
            const Text(
              'Bu uygulama sayesinde doktor randevularınızı kolayca planlayabilir, '
                  'randevu geçmişinizi görüntüleyebilir ve doktor bilgilerine hızlıca ulaşabilirsiniz. '
                  'Kullanıcı dostu arayüzü ile işlemlerinizi kolayca gerçekleştirebilirsiniz.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            // Kullanım Başlığı
            Text(
              'Uygulama Nasıl Kullanılıyor?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mor,
              ),
            ),
            const SizedBox(height: 10),

            // Video
            _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  Center(
                    child: IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        size: 64,
                        color: Colors.white,
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
                ],
              ),
            )
                : const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
