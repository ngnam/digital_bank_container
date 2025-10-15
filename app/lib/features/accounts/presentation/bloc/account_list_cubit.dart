import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_accounts.dart';
import '../../domain/entities/account_entity.dart';

part 'account_list_state.dart';

class AccountListCubit extends Cubit<AccountListState> {
  final GetAccounts getAccounts;
  AccountListCubit(this.getAccounts) : super(AccountListInitial());

  Future<void> fetchAccounts() async {
    emit(AccountListLoading());
    try {
      final accounts = await getAccounts();
      emit(AccountListLoaded(accounts));
    } catch (e) {
      emit(AccountListError('Failed to load accounts'));
    }
  }
}
