import 'package:flutter/material.dart';

class MenuGrid extends StatefulWidget {
  const MenuGrid({super.key});

  @override
  State<MenuGrid> createState() => _MenuGridState();
}

class _MenuGridState extends State<MenuGrid> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final icons = [
    Icons.send,
    Icons.savings,
    Icons.payment,
    Icons.account_balance_wallet,
    Icons.payments,
    Icons.mobile_friendly,
    Icons.contactless,
    Icons.history,
    Icons.support,
    Icons.receipt,
    Icons.card_giftcard,
    Icons.more_horiz,
    // page 2
    Icons.credit_card,
    Icons.account_balance,
    Icons.contacts,
    Icons.star,
    Icons.home,
    Icons.settings
  ];

  final titles = [
    // page 1
    'Chuyển tiền',
    'Tiết kiệm',
    'Thanh toán',
    'Nạp tiền',
    'Rút tiền',
    'Nạp ĐT',
    'QR Pay',
    'Lịch sử',
    'Hỗ trợ',
    'Hóa đơn',
    'Ưu đãi',
    'Khác',
    // page 2
    'Thẻ',
    'Vay vốn',
    'Danh bạ thụ hưởng',
    'Tài khoản số đẹp',
    'Vay mua nhà',
    'Cài đặt chung',
  ];

  final newMenuTitles = {
    'Thẻ',
    'Vay vốn',
    'Danh bạ thụ hưởng',
    'Tài khoản số đẹp',
    'Vay mua nhà',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Indicator (fixed height so it reliably shows under the PageView)
        SizedBox(
          height: 16,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(2, (index) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                  ),
                );
              }),
            ),
          ),
        ),

        // PageView chứa nhiều Grid
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // Page 1
              GridView.count(
                crossAxisCount: 4,
                children: List.generate(12, (i) {
                  return _buildMenuItem(icons[i], titles[i], false);
                }),
              ),
              // Page 2
              GridView.count(
                crossAxisCount: 4,
                children: List.generate(icons.length - 12, (i) {
                  final index = i + 12;
                  final isNew = newMenuTitles.contains(titles[index]);
                  return _buildMenuItem(icons[index], titles[index], isNew);
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isNew) {
    return InkWell(
      onTap: () {
        switch (title) {
          case 'Cài đặt chung':
            Navigator.of(context).pushNamed('/settings');
            break;

          // TODO: xử lý các menu khác

          default:
            break;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDEDED),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: Colors.black87),
              ),
              if (isNew)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Mới',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
