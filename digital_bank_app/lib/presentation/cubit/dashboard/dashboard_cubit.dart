import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/account_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AccountRepository repository;

  DashboardCubit(this.repository) : super(const DashboardState());

  Future<void> loadAccounts() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final accounts = await repository.getAccounts();
      emit(state.copyWith(status: DashboardStatus.loaded, accounts: accounts));
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.failure, message: e.toString()));
    }
  }
}
