// 🆕 lib/widgets/detail/hero_image_carousel.dart
import 'package:flutter/material.dart';

class HeroImageCarousel extends StatefulWidget {
  final List<String>? imageUrls;
  final String? categoria;
  final bool isOpen;

  const HeroImageCarousel({super.key, this.imageUrls, this.categoria, this.isOpen = true});

  @override
  State<HeroImageCarousel> createState() => _HeroImageCarouselState();
}

class _HeroImageCarouselState extends State<HeroImageCarousel> {
  //int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: Colors.grey[300],
      child: const Center(child: Text('HeroImageCarousel — TODO Laura')),
    );
  }
}
