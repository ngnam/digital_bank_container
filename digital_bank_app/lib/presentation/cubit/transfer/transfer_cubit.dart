// lib/presentation/transfer/transfer_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repositories/transfer_repository_impl.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/transfer_entity.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../domain/repositories/transfer_repository.dart';
import 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  final TransferRepository repository;
  final AccountRepository accountRepository;

  TransferCubit(this.repository, this.accountRepository)
      : super(const TransferInitial());

  Future<List<Account>> loadAccounts() async {
    return accountRepository.getAccounts();
  }

  String formatCurrency(double amount, String currency) {
    final value = amount.toStringAsFixed(0);
    return '$value $currency';
  }

  String generateIdempotencyKey() => const Uuid().v4();

  String? validateForm({
    required TransferType type,
    required String? sourceAccountId,
    required String? targetAccount,
    required double? amount,
  }) {
    if (sourceAccountId == null || sourceAccountId.isEmpty) {
      return 'Vui lòng chọn tài khoản nguồn';
    }
    if (targetAccount == null || targetAccount.isEmpty) {
      return 'Vui lòng nhập số tài khoản người nhận';
    }
    if (amount == null || amount <= 0) {
      return 'Số tiền không hợp lệ';
    }
    // thêm validate khác nếu cần
    return null;
  }

  Future<void> transferMoney({
    required TransferType type,
    required String sourceAccountId,
    required String targetAccount,
    required double amount,
    required String currency,
    required String description,
  }) async {
    emit(const TransferLoading());
    try {
      final payload = TransferPayload(
        sourceAccountId: sourceAccountId,
        targetAccount: targetAccount,
        amount: amount,
        currency: currency,
        type: type,
        description: description,
        idempotencyKey: generateIdempotencyKey(),
      );
      final tx = await repository.postTransfer(payload);
      emit(TransferSuccess(tx));
    } on TransferDuplicateException catch (e) {
      emit(TransferFailure(e.message));
    } on TransferApiException catch (e) {
      emit(TransferFailure(e.message));
    } catch (_) {
      emit(const TransferFailure('Có lỗi xảy ra, vui lòng thử lại'));
    }
  }
}
