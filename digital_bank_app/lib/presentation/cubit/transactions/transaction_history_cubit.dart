// lib/presentation/transactions/transaction_history_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';
import 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  final TransactionRepository repository;
  static const int _pageSize = 10;
  List<String> _accounts = const [];

  TransactionHistoryCubit(this.repository)
      : super(const TransactionHistoryInitial());

  Future<void> initAndLoad({
    String? accountId,
    TransactionType type = TransactionType.all,
    DateTime? from,
    DateTime? to,
  }) async {
    final filters = TransactionFilters(
        accountId: accountId, type: type, from: from, to: to);
    emit(TransactionHistoryLoading(filters, _accounts));
    try {
      _accounts = await repository.fetchAccounts();
      final list = await repository.fetchTransactions(
          page: 1, pageSize: _pageSize, filters: filters);
      emit(TransactionHistoryLoaded(
        transactions: list,
        hasMore: list.length == _pageSize,
        filters: filters,
        currentPage: 1,
        accounts: _accounts,
      ));
    } catch (e) {
      emit(TransactionHistoryError(
          'Không thể tải lịch sử giao dịch', filters, _accounts));
    }
  }

  Future<void> loadTransactions({
    int page = 1,
    TransactionFilters? filters,
  }) async {
    final effectiveFilters = filters ??
        (state is TransactionHistoryLoaded
            ? (state as TransactionHistoryLoaded).filters
            : const TransactionFilters());

    emit(TransactionHistoryLoading(effectiveFilters, _accounts));
    try {
      final list = await repository.fetchTransactions(
        page: page,
        pageSize: _pageSize,
        filters: effectiveFilters,
      );
      emit(TransactionHistoryLoaded(
        transactions: list,
        hasMore: list.length == _pageSize,
        filters: effectiveFilters,
        currentPage: page,
        accounts: _accounts,
      ));
    } catch (e) {
      emit(TransactionHistoryError(
          'Không thể tải lịch sử giao dịch', effectiveFilters, _accounts));
    }
  }

  Future<void> loadMoreTransactions() async {
    final current = state;
    if (current is! TransactionHistoryLoaded) return;
    if (!current.hasMore) return;

    final nextPage = current.currentPage + 1;
    try {
      final more = await repository.fetchTransactions(
        page: nextPage,
        pageSize: _pageSize,
        filters: current.filters,
      );
      emit(TransactionHistoryLoaded(
        transactions: [...current.transactions, ...more],
        hasMore: more.length == _pageSize,
        filters: current.filters,
        currentPage: nextPage,
        accounts: current.accounts,
      ));
    } catch (_) {
      // giữ nguyên state nếu lỗi, có thể hiện snackbar bên ngoài nếu cần
    }
  }

  Future<void> applyFilter({
    String? accountId,
    required TransactionType type,
    required DateTime? from,
    required DateTime? to,
  }) async {
    final filters = TransactionFilters(
        accountId: accountId, type: type, from: from, to: to);
    await loadTransactions(page: 1, filters: filters);
  }

  Future<void> refresh() async {
    final current = state;
    final filters = current is TransactionHistoryLoaded
        ? current.filters
        : const TransactionFilters();
    await loadTransactions(page: 1, filters: filters);
  }
}
