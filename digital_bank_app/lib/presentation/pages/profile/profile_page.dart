import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/profile/profile_cubit.dart';
import '../../cubit/profile/profile_state.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/di.dart' as di;

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  void _navigateToLogin(BuildContext ctx) {
    Navigator.of(ctx).pushNamedAndRemoveUntil(
      '/', // route name đã khai báo cho LoginPage
      (route) => false, // xoá toàn bộ stack
    );
  }

  Future<bool?> _confirmLogout(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ok')),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(di.sl<AuthRepository>()),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoggedOut) {
            _navigateToLogin(context);
          } else if (state is ProfileError) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Cá nhân'),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Thông tin cá nhân'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Thay đổi mật khẩu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Cài đặt phương thức xác thực'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Hỗ trợ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất',
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final profileCubit = context.read<ProfileCubit>();
                    final confirmed = await _confirmLogout(context);
                    if (confirmed == true) {
                      await profileCubit.logout();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
