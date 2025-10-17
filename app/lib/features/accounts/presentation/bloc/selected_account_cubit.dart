import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account_entity.dart';

class SelectedAccountCubit extends Cubit<AccountEntity?> {
  SelectedAccountCubit(): super(null);

  void select(AccountEntity account) => emit(account);
  void clear() => emit(null);
}
