import 'package:flutter/material.dart';

class NewsSlider extends StatefulWidget {
  const NewsSlider({super.key});

  @override
  State<NewsSlider> createState() => _NewsSliderState();
}

class _NewsSliderState extends State<NewsSlider> {
  final PageController _newsController = PageController();
  int _newsPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Indicator
        SizedBox(
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _newsPage == i ? Colors.blue : Colors.grey,
                ),
              );
            }),
          ),
        ),

        // Slider
        SizedBox(
          height: 100,
          child: PageView(
            controller: _newsController,
            onPageChanged: (i) {
              setState(() => _newsPage = i);
            },
            children: [
              _newsCard('Khuyến mãi lớn tháng 10', Colors.orange),
              _newsCard('Ưu đãi thẻ tín dụng', Colors.blue),
              _newsCard('Tin tức ngân hàng mới nhất', Colors.green),
            ],
          ),
        ),
        
      ],
    );
  }

  Widget _newsCard(String title, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
