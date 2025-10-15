import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_account_detail.dart';
import '../../domain/entities/account_entity.dart';

part 'account_detail_state.dart';

class AccountDetailCubit extends Cubit<AccountDetailState> {
  final GetAccountDetail getAccountDetail;
  AccountDetailCubit(this.getAccountDetail) : super(AccountDetailInitial());

  Future<void> fetchDetail(int id) async {
    emit(AccountDetailLoading());
    try {
      final account = await getAccountDetail(id);
      emit(AccountDetailLoaded(account));
    } catch (e) {
      emit(AccountDetailError('Failed to load account detail'));
    }
  }
}
