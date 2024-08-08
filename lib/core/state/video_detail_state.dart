import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:potato/data/api/video_api_service.dart';

class VideoDetailState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
  VideoPlayerController? _videoPlayerController;
  Map<String, dynamic>? _videoInfo;
  bool _isLoading = false;
  bool _hasError = false;
  int _currentEpisodeIndex = 0;

  Map<String, dynamic>? get videoInfo => _videoInfo;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  int get currentEpisodeIndex => _currentEpisodeIndex;
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  /// 获取视频详细信息
  Future<void> fetchVideoInfo(String link, {bool forceRefresh = false}) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _videoInfo = await _videoApiService.fetchVideoInfo(link,
          forceRefresh: forceRefresh);
    } catch (error) {
      _hasError = true;
      _videoInfo = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取指定集的详细信息
  Future<String> getEpisodeInfo(String episodeUrl) async {
    return await _videoApiService.getEpisodeInfo(episodeUrl);
  }

  /// 解密视频 URL
  Future<String> getDecryptedUrl(String videoSource) async {
    return await _videoApiService.getDecryptedUrl(videoSource);
  }

  /// 播放指定的集
  Future<void> playEpisode(String episodeUrl) async {
    try {
      final videoSource = await getEpisodeInfo(episodeUrl);
      final decryptedUrl = await getDecryptedUrl(videoSource);

      _videoPlayerController?.dispose();

      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(decryptedUrl))
            ..initialize().then((_) {
              notifyListeners(); // 更新UI
              _videoPlayerController?.play();
            });

      _videoPlayerController?.addListener(() {
        if (_videoPlayerController!.value.position ==
            _videoPlayerController!.value.duration) {
          playNextEpisode();
        }
      });

      notifyListeners();
    } catch (e) {
      print('Error: $e');
    }
  }

  /// 播放下一集
  void playNextEpisode() {
    if (_videoInfo == null || _videoInfo!['episodes'] == null) return;

    final episodes = _videoInfo!['episodes'];
    if (_currentEpisodeIndex + 1 < episodes.entries.length) {
      _currentEpisodeIndex++;
      playEpisode(
          episodes.entries.toList()[_currentEpisodeIndex].value[0]['url']);
    }
  }

  /// 设置当前集数索引
  void setCurrentEpisodeIndex(int index) {
    _currentEpisodeIndex = index;
    notifyListeners();
  }

  /// 设置 VideoPlayerController
  void setVideoPlayerController(VideoPlayerController? controller) {
    _videoPlayerController = controller;
    notifyListeners();
  }
}
