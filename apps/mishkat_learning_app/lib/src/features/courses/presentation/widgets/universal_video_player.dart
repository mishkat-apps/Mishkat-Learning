import 'package:flutter/material.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class UniversalVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const UniversalVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
  });

  @override
  State<UniversalVideoPlayer> createState() => _UniversalVideoPlayerState();
}

class _UniversalVideoPlayerState extends State<UniversalVideoPlayer> {
  late final YoutubePlayerController _ytController;
  bool _isYoutube = false;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(UniversalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    final ytId = _extractYoutubeId(widget.videoUrl);
    
    if (ytId != null) {
      _isYoutube = true;
      _videoId = ytId;
      _ytController = YoutubePlayerController.fromVideoId(
        videoId: ytId,
        autoPlay: widget.autoPlay,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    } else {
      _isYoutube = false;
      _videoId = _extractVimeoId(widget.videoUrl);
      // Vimeo player handles its own initialization via key
    }
  }

  @override
  void dispose() {
    if (_isYoutube) {
      _ytController.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.white, size: 48),
        ),
      );
    }

    if (_isYoutube) {
      return YoutubePlayer(
        controller: _ytController,
        aspectRatio: 16 / 9,
      );
    } else {
      // Vimeo
      return VimeoVideoPlayer(
        key: ValueKey(_videoId),
        videoId: _videoId!,
      );
    }
  }

  static String? _extractYoutubeId(String url) {
    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  static String? _extractVimeoId(String url) {
    final regExp = RegExp(r'vimeo\.com\/(?:.*#|.*videos\/)?([0-9]+)');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}
