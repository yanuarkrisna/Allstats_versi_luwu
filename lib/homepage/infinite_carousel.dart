import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class InfiniteCarousel extends StatefulWidget {
  final List<String> images;
  final Function(int)? onDownload;

  const InfiniteCarousel({super.key, required this.images, this.onDownload});

  @override
  State<InfiniteCarousel> createState() => _InfiniteCarouselState();
}

class _InfiniteCarouselState extends State<InfiniteCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startAutoScroll(); // Loop terus
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width * 0.8,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index % widget.images.length;
            });
          },
          itemBuilder: (context, index) {
            final imageIndex = index % widget.images.length;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text("Zoom")),
                      body: PhotoView(
                        imageProvider: AssetImage(widget.images[imageIndex]),
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      ),
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.images[imageIndex],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () {
                          if (widget.onDownload != null) {
                            widget.onDownload!(imageIndex);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
