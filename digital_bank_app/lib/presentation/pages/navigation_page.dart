import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di.dart' as di;
import '../../domain/repositories/account_repository.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/navigation_state.dart';
import '../cubit/dashboard/dashboard_cubit.dart';
import '../cubit/profile/profile_cubit.dart';
import 'dashboard/dashboard_page.dart';
import 'profile/profile_page.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: const _NavigationView(),
    );
  }
}

class _NavigationView extends StatelessWidget {
  const _NavigationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create pages here so we can wrap DashboardPage with its DashboardCubit provider
    final pages = [
      // Provide DashboardCubit (use DI singleton if registered, otherwise create a new one)
      di.sl.isRegistered<DashboardCubit>()
          ? BlocProvider.value(
              value: di.sl<DashboardCubit>(), child: const DashboardPage())
          : BlocProvider(
              create: (_) =>
                  DashboardCubit(di.sl<AccountRepository>())..loadAccounts(),
              child: const DashboardPage()),
      const _AccountsPage(),
      const _QrPage(),
      const _InboxPage(),
      // Profile
      const ProfilePage(), // để ProfilePage tự lo BlocProvider
    ];

    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              // Key the child by the selected index so AnimatedSwitcher knows when to animate
              key: ValueKey<int>(state.index),
              child: SizedBox.expand(child: pages[state.index]),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<NavigationCubit>().changeIndex(2),
            child: const Icon(Icons.qr_code_scanner, size: 32),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDDDDDD).withOpacity(1.0),
                  blurRadius: 4,
                  offset: const Offset(0, -2), // đổ bóng lên trên
                ),
              ],
            ),
            child: BottomAppBar(
              color: Colors.transparent, // để màu nền lấy từ Container
              elevation: 0, // bỏ shadow mặc định
              shape: const CircularNotchedRectangle(),
              notchMargin: 6.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _navItem(context,
                          icon: Icons.home,
                          label: 'Trang chủ',
                          index: 0,
                          current: state.index),
                      _navItem(context,
                          icon: Icons.account_balance,
                          label: 'Tài khoản',
                          index: 1,
                          current: state.index),
                    ],
                  ),
                  Row(
                    children: [
                      _navItem(context,
                          icon: Icons.inbox,
                          label: 'Hộp thư',
                          index: 3,
                          current: state.index),
                      _navItem(context,
                          icon: Icons.person,
                          label: 'Cá nhân',
                          index: 4,
                          current: state.index),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(BuildContext context,
      {required IconData icon,
      required String label,
      required int index,
      required int current}) {
    final selected = index == current;
    return MaterialButton(
      minWidth: 64,
      onPressed: () => context.read<NavigationCubit>().changeIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: selected ? Theme.of(context).primaryColor : Colors.grey),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color:
                      selected ? Theme.of(context).primaryColor : Colors.grey,
                  fontSize: 11)),
        ],
      ),
    );
  }
}

class _AccountsPage extends StatelessWidget {
  const _AccountsPage();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Tài khoản'));
}

class _QrPage extends StatelessWidget {
  const _QrPage();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Quét QR'));
}

class _InboxPage extends StatelessWidget {
  const _InboxPage();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Hộp thư'));
}

// class _ProfilePage extends StatelessWidget {
//   const _ProfilePage();
//   @override
//   Widget build(BuildContext context) => const Center(child: Text('Cá nhân'));
// }
