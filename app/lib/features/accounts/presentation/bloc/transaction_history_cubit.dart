import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/entities/transaction_entity.dart';

part 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  final GetTransactions getTransactions;
  TransactionHistoryCubit(this.getTransactions) : super(TransactionHistoryInitial());

  Future<void> fetchTransactions(int accountId, {int page = 1, int pageSize = 20}) async {
    emit(TransactionHistoryLoading());
    try {
      final transactions = await getTransactions(accountId, page: page, pageSize: pageSize);
      emit(TransactionHistoryLoaded(transactions));
    } catch (e) {
      emit(TransactionHistoryError('Failed to load transactions'));
    }
  }
}
