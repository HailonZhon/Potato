import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:potato/core/state/home_page_state.dart';
// import 'components/carousel_section.dart'; // 注释掉轮播组件的导入
import 'components/recommended_section.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late PageController _pageController;
  // int _currentPage = 0;
  // late Timer _timer; // 使用 late 关键字表示 _timer 是稍后初始化的
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _pageController = PageController(initialPage: _currentPage);
    // _startAutoScroll();
    // 使用 addPostFrameCallback 在当前帧结束后调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    // 初始化 _timer 以避免 LateInitializationError
    // _timer = Timer(const Duration(seconds: 0), () {});
  }

  @override
  void dispose() {
    // _pageController.dispose();
    // _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // void _startAutoScroll() {
  //   _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
  //     if (_pageController.hasClients) {
  //       if (_currentPage <
  //           Provider.of<HomePageState>(context, listen: false)
  //                   .carouselVideos
  //                   .length -
  //               1) {
  //         _currentPage++;
  //       } else {
  //         _currentPage = 0;
  //       }
  //       _pageController.animateToPage(
  //         _currentPage,
  //         duration: const Duration(milliseconds: 300),
  //         curve: Curves.easeInOut,
  //       );
  //     }
  //   });
  // }

  Future<void> _fetchData() async {
    await Provider.of<HomePageState>(context, listen: false)
        .fetchHomePageData();
  }

  Future<void> _onRefresh() async {
    await _fetchData();
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      // 跳转到 VideoSearchPage，并在那边进行搜索
      context.go('/search', extra: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 1.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage:
                const NetworkImage('https://api.multiavatar.com/tom.png'),
          ),
        ),
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: _onSearchSubmitted,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<HomePageState>(
        builder: (context, HomePageState, child) {
          if (HomePageState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (HomePageState.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CarouselSection(
                    //   carouselVideos: HomePageState.carouselVideos,
                    //   pageController: _pageController,
                    // ),
                    // const SizedBox(height: 20),
                    RecommendedSection(
                        recommendedVideos: HomePageState.recommendedVideos),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
