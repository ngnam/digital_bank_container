// lib/presentation/transfer/transfer_state.dart
import '../../../domain/entities/transfer_entity.dart';

abstract class TransferState {
  const TransferState();
}

class TransferInitial extends TransferState {
  const TransferInitial();
}

class TransferLoading extends TransferState {
  const TransferLoading();
}

class TransferSuccess extends TransferState {
  final TransferEntity transaction;
  const TransferSuccess(this.transaction);
}

class TransferFailure extends TransferState {
  final String message;
  const TransferFailure(this.message);
}
