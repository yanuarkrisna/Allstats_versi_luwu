import 'package:flutter/material.dart';
import 'infinite_carousel.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  // final PageController _pageController = PageController();
  // final List<String> imageUrls = [
  //   'assets/images/icon-LontaraQ.png',
  //   'assets/images/logo_antrian.png',
  //   'assets/images/quiz-logo.png',
  // ];

  // int _currentPage = 0;
  // //  late Timer _timer;

  // @override
  // void initState() {
  //   super.initState();
  //   _startAutoScroll();
  // }

  // void _startAutoScroll() {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     if (!mounted) return;
  //     _pageController.nextPage(
  //       duration: const Duration(milliseconds: 500),
  //       curve: Curves.easeInOut,
  //     );
  //     _startAutoScroll(); // Loop terus
  //   });
  // }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 5, 85, 74),
                  Color.fromARGB(255, 5, 85, 74),
                  Color.fromARGB(255, 5, 85, 74),
                  Colors.amberAccent,
                ],
              ),
            ),
          ),
          title: Container(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset(
              'assets/images/logo_bpsluwu.png',
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person, size: 28),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.info, size: 28),
            ),
          ],
          centerTitle: false,
          backgroundColor: Colors.amber,
          elevation: 2,
        ),
        body: Column(
          children: [
            // Carousel Section
            InfiniteCarousel(
              images: [
                'assets/images/icon-LontaraQ.png',
                'assets/images/logo_antrian.png',
                'assets/images/quiz-logo.png',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
