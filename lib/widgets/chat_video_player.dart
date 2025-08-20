import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class ChatVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double? width;
  final double? height;
  final bool autoPlay;
  final bool showControls;
  final bool useRealAspectRatio;

  const ChatVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.width,
    this.height,
    this.autoPlay = false,
    this.showControls = true,
    this.useRealAspectRatio = true,
  }) : super(key: key);

  @override
  State<ChatVideoPlayer> createState() => _ChatVideoPlayerState();
}

class _ChatVideoPlayerState extends State<ChatVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      print('🎬 [ChatVideoPlayer] Initializing video: ${widget.videoUrl}');
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      await _controller.initialize();
      print('🎬 [ChatVideoPlayer] Video initialized successfully');
      
      _controller.addListener(_videoListener);
      
      setState(() {
        _isInitialized = true;
      });

      if (widget.autoPlay) {
        print('🎬 [ChatVideoPlayer] Auto-playing video');
        _controller.play();
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      print('❌ [ChatVideoPlayer] Error initializing video: $e');
    }
  }

  void _videoListener() {
    final bool isBuffering = _controller.value.isBuffering;
    final bool isPlaying = _controller.value.isPlaying;

    if (isBuffering != _isBuffering || isPlaying != _isPlaying) {
      setState(() {
        _isBuffering = isBuffering;
        _isPlaying = isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onVideoTap() {
    print('🎬 [ChatVideoPlayer] Video tapped! isPlaying: $_isPlaying, showControls: $_showControls');
    
    if (!_isPlaying) {
      // Always start playing when tapped and paused
      print('🎬 [ChatVideoPlayer] Starting video playback');
      _controller.play();
      _showControlsTemporarily();
    } else {
      // If playing, toggle based on controls visibility
      if (_showControls) {
        print('🎬 [ChatVideoPlayer] Pausing video (controls visible)');
        _controller.pause();
      } else {
        print('🎬 [ChatVideoPlayer] Showing controls (video playing)');
        _showControlsTemporarily();
      }
    }
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          videoUrl: widget.videoUrl,
          controller: _controller,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: widget.width ?? 250,
        height: widget.height ?? 200,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(
                color: Colors.blue,
                radius: 16,
              ),
              SizedBox(height: 12),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final videoAspectRatio = _controller.value.aspectRatio;
    
    double containerWidth;
    double containerHeight;
    
    if (widget.useRealAspectRatio) {
      // Use real video aspect ratio
      containerWidth = widget.width ?? 250;
      containerHeight = containerWidth / videoAspectRatio;
      
      // Ensure reasonable height limits
      if (containerHeight > 400) {
        containerHeight = 400;
        containerWidth = containerHeight * videoAspectRatio;
      }
    } else {
      // Use fixed dimensions
      containerWidth = widget.width ?? 250;
      containerHeight = widget.height ?? (containerWidth / videoAspectRatio);
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
              child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: _onVideoTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video player
              SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoPlayer(_controller),
                    
                    // Subtle overlay when paused to indicate it's tappable
                    if (!_isPlaying)
                      Container(
                        color: Colors.black.withOpacity(0.2),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'TAP TO PLAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Loading indicator when buffering
              if (_isBuffering)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 16,
                    ),
                  ),
                ),

              // Controls overlay
              if (widget.showControls && _showControls)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top controls (if needed for fullscreen, etc.)
                      const Spacer(),
                      
                      // Center play/pause button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _togglePlayPause,
                          icon: Icon(
                            _isPlaying 
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Bottom controls
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // Current time
                            Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Progress bar
                            Expanded(
                              child: VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.blue,
                                  bufferedColor: Colors.white30,
                                  backgroundColor: Colors.white12,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Total duration
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Fullscreen button
                            GestureDetector(
                              onTap: _openFullscreen,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  CupertinoIcons.fullscreen,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Play button when paused and controls hidden
              if (!_isPlaying && !_showControls && widget.showControls)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: const Icon(
                      CupertinoIcons.play_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              
              // Always show play button overlay when video is paused (even without controls)
              if (!_isPlaying && !widget.showControls)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: const Icon(
                      CupertinoIcons.play_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VideoPlayerController controller;

  const FullscreenVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.controller,
  }) : super(key: key);

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    // Set landscape orientation for fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system UI for true fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _showControlsTemporarily();
  }

  @override
  void dispose() {
    // Restore orientation and system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    _showControlsTemporarily();
  }

  void _onVideoTap() {
    if (_showControls) {
      _togglePlayPause();
    } else {
      _showControlsTemporarily();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onVideoTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            
            // Controls overlay
            if (_showControls)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Top controls
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.xmark,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Center play/pause button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          widget.controller.value.isPlaying 
                            ? CupertinoIcons.pause_fill
                            : CupertinoIcons.play_fill,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bottom controls
                    SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Current time
                            Text(
                              _formatDuration(widget.controller.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Progress bar
                            Expanded(
                              child: VideoProgressIndicator(
                                widget.controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.blue,
                                  bufferedColor: Colors.white30,
                                  backgroundColor: Colors.white12,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Total duration
                            Text(
                              _formatDuration(widget.controller.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
