import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'profile_state.dart';
import '../../../core/di.dart' as di;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;
  ProfileCubit(this._authRepository) : super(ProfileInitial());

  Future<void> logout() async {
    try {
      emit(ProfileLoggingOut());
      await _authRepository.logout();

      // If FlutterSecureStorage is registered in DI, clear tokens (defensive)
      if (di.sl.isRegistered<FlutterSecureStorage>()) {
        try {
          final storage = di.sl<FlutterSecureStorage>();
          await storage.deleteAll();
        } catch (_) {
          // ignore storage errors
        }
      }

      emit(ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
