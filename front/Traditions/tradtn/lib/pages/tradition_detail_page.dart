import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/tradition.dart';

class TraditionDetailPage extends StatefulWidget {
  final Tradition tradition;

  const TraditionDetailPage({super.key, required this.tradition});

  @override
  State<TraditionDetailPage> createState() => _TraditionDetailPageState();
}

class _TraditionDetailPageState extends State<TraditionDetailPage> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.tradition.youtubeUrl.isNotEmpty) {
      final videoId =
      YoutubePlayer.convertUrlToId(widget.tradition.youtubeUrl);

      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // 🔥 ОБЯЗАТЕЛЬНО
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tradition;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_controller != null) ...[
              YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
              ),
              const SizedBox(height: 16),
            ],

            Text(
              t.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              t.description,
              style: const TextStyle(fontSize: 16),
            ),

            if (t.meaning.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Значение',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(t.meaning),
            ],
          ],
        ),
      ),
    );
  }
}
