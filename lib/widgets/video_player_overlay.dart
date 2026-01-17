import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../models/iptv_models.dart';
import '../services/iptv_provider.dart';
import '../theme.dart';
import 'media_kit_player.dart';

class VideoPlayerOverlay extends StatefulWidget {
  final ChannelModel channel;
  const VideoPlayerOverlay({super.key, required this.channel});

  @override
  State<VideoPlayerOverlay> createState() => _VideoPlayerOverlayState();
}

class _VideoPlayerOverlayState extends State<VideoPlayerOverlay> {
  int _currentStreamIndex = 0;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _initialized = false;
  String? _errorMessage;
  bool _useMediaKit = false;

  @override
  void initState() {
    super.initState();
    _useMediaKit = context.read<IPTVProvider>().useMediaKitByDefault;
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.channel.streams.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No stream URLs available for this channel.';
        });
      }
      return;
    }

    if (_currentStreamIndex >= widget.channel.streams.length) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'All available streams failed to load. Please try another channel.';
        });
      }
      return;
    }

    final url = widget.channel.streams[_currentStreamIndex].url;
    debugPrint('Trying Stream [$_currentStreamIndex]: $url');

    try {
      // Clean up previous controllers if retrying
      _chewieController?.dispose();
      await _videoPlayerController?.dispose();
      _chewieController = null;
      _videoPlayerController = null;

      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoPlayerController = controller;

      await controller.initialize().timeout(const Duration(seconds: 15));

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        allowFullScreen: true,
        isLive: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: CodeThemes.primaryColor),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          // If playback fails after initialization, we could also try fallback here
          // but for now let's just show the error if it was already playing.
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Playback Error: $errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  if (!_useMediaKit)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _useMediaKit = true;
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('Try Media Kit Player'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  if (_currentStreamIndex < widget.channel.streams.length - 1)
                    TextButton.icon(
                      onPressed: () => _tryNextStream(),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('Try Alternative Stream'),
                    ),
                ],
              ),
            ),
          );
        },
      );

      setState(() {
        _initialized = true;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Stream $_currentStreamIndex failed: $e');
      if (mounted) {
        String errorText = 'Failed to load stream.';
        bool canTryMediaKit = !_useMediaKit;

        if (e.toString().contains('MEDIA_ERR_SRC_NOT_SUPPORTED')) {
          errorText =
              'This stream format is not supported by your browser\'s default player.';
        }

        if (_currentStreamIndex < widget.channel.streams.length - 1) {
          _tryNextStream();
        } else {
          setState(() {
            _errorMessage =
                '$errorText ${canTryMediaKit ? "Try switching to the Media Kit player." : "All alternative URLs exhausted."}';
          });
        }
      }
    }
  }

  void _tryNextStream() {
    if (mounted) {
      setState(() {
        _currentStreamIndex++;
        _initialized = false;
        _errorMessage = null;
      });
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 20),

              // Video Player Area
              Expanded(
                child: Hero(
                  tag: widget.channel.channel.id,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: CodeThemes.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildPlayerContent(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (widget.channel.logo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.channel.logo!.url,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.live_tv_rounded, color: Colors.white70),
              ),
            )
          else
            const Icon(Icons.live_tv_rounded, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.channel.channel.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Text(
                      'Live Performance Streaming',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                _useMediaKit = !_useMediaKit;
              });
            },
            icon: Icon(
              _useMediaKit
                  ? Icons.video_library_rounded
                  : Icons.movie_filter_rounded,
              size: 24,
              color: _useMediaKit ? CodeThemes.primaryColor : Colors.white70,
            ),
            tooltip: _useMediaKit
                ? 'Switch to Default Player'
                : 'Switch to Media Kit',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              context.read<IPTVProvider>().playChannel(null);
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 28,
              color: Colors.white70,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              hoverColor: Colors.redAccent.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerContent() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _initialized = false;
                  });
                  _initializePlayer();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CodeThemes.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_useMediaKit) {
      final currentStream = widget.channel.streams.isNotEmpty
          ? widget.channel.streams[_currentStreamIndex >=
                    widget.channel.streams.length
                ? 0
                : _currentStreamIndex]
          : null;
      if (currentStream != null) {
        return MediaKitPlayer(videoUrl: currentStream.url);
      }
    }

    if (_initialized && _chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: CodeThemes.primaryColor),
          const SizedBox(height: 20),
          Text(
            'Buffering Stream...',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
