import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class VideoApiService {
  final String baseUrl = "https://potato.galen.life";
  final String targetUrl = "https://www.dmla7.com";

  Future<T> fetchData<T>(
    String endpoint, {
    required String targetUrlPath,
    required T Function(dynamic data) parseData,
    bool isFullUrl = false,
  }) async {
    // 判断是否为完整链接
    final url = isFullUrl
        ? Uri.parse(targetUrlPath)
        : Uri.parse('$targetUrl$targetUrlPath');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final htmlContent = response.body;
      final compressedContent = gzip.encode(utf8.encode(htmlContent));
      final encodedContent = base64.encode(compressedContent);

      final apiUrl = Uri.parse('$baseUrl$endpoint');
      final apiResponse = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'html_content': encodedContent}),
      );

      if (apiResponse.statusCode == 200) {
        final data = json.decode(utf8.decode(apiResponse.bodyBytes));
        return parseData(data);
      } else {
        throw Exception('Failed to load data from $endpoint');
      }
    } else {
      throw Exception('Failed to fetch HTML content from $targetUrlPath');
    }
  }

  // 搜索视频
  Future<List<Map<String, dynamic>>> searchVideos(String query,)
   async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/search/search_kw',
      targetUrlPath: '/search/-------------.html?wd=$query',
      parseData: (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  // 获取搜索结果
  Future<Map<String, dynamic>> fetchVideoInfo(String link,
    ) async {
    return fetchData<Map<String, dynamic>>(
      '/api/video_info/detail_page',
      targetUrlPath: link,
      parseData: (data) => Map<String, dynamic>.from(data),

    );
  }

  // 获取视频播放地址
  Future<String> getEpisodeInfo(String episodeLink,
     ) async {
    return fetchData<String>(
      '/api/episodes/episode_info',
      targetUrlPath: episodeLink,
      parseData: (data) => data['video_source'] as String,
      
    );
  }

  // 获取视频详细地址
  Future<String> getDecryptedUrl(String videoSource,
     ) async {
    return fetchData<String>(
      '/api/episodes/get_decrypted_url',
      targetUrlPath: videoSource, // 直接传递完整的链接
      parseData: (data) => data['decrypted_url'] as String,
      isFullUrl: true, // 设置为 true，表示 targetUrlPath 是完整的链接
      
    );
  }

  // 获取主页轮播视频
  Future<List<Map<String, dynamic>>> getCarouselVideos(
     ) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/home/carousel_videos',
      targetUrlPath: '/',
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      
    );
  }

  // 获取主页推荐视频
  Future<List<Map<String, dynamic>>> getRecommendedVideos(
     ) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/home/recommended_videos',
      targetUrlPath: '/',
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      
    );
  }

  // 获取指定分类的所有视频
  Future<List<Map<String, dynamic>>> getCategoryVideos(String categoryUrl,
     ) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/home/get_page_total_videos',
      targetUrlPath: categoryUrl,
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      
    );
  }

  // 获取总页数量
  Future<int> getTotalPages(String categoryUrl,
     ) async {
    return fetchData<int>(
      '/api/home/total_pages',
      targetUrlPath: categoryUrl,
      parseData: (data) => data['total_pages'] as int,
      
    );
  }

  // 获取年份信息
  Future<List<Map<String, dynamic>>> getYears(String categoryUrl,
     ) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/home/years',
      targetUrlPath: categoryUrl,
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      
    );
  }

  // 获取公告信息
  Future<List<Map<String, dynamic>>> fetchAnnouncements(
     ) async {
    final url = Uri.parse('$baseUrl/api/home/announcements');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = utf8.decode(response.bodyBytes);
      return List<Map<String, dynamic>>.from(json.decode(data));
    } else {
      throw Exception('Failed to load announcements');
    }
  }
}
