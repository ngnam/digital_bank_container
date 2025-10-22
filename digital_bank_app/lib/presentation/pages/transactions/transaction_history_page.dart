// lib/presentation/transactions/transaction_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../../cubit/transactions/transaction_history_cubit.dart';
import '../../cubit/transactions/transaction_history_state.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String? _selectedAccount;
  TransactionType _selectedType = TransactionType.all;
  DateTime? _fromDate;
  DateTime? _toDate;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionHistoryCubit>().initAndLoad();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<TransactionHistoryCubit>().loadMoreTransactions();
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final initialDateRange = (_fromDate != null && _toDate != null)
        ? DateTimeRange(start: _fromDate!, end: _toDate!)
        : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final range = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1),
      initialDateRange: initialDateRange,
      helpText: 'Chọn khoảng thời gian',
      saveText: 'Xong',
    );
    if (range != null) {
      setState(() {
        _fromDate =
            DateTime(range.start.year, range.start.month, range.start.day);
        _toDate = DateTime(
            range.end.year, range.end.month, range.end.day, 23, 59, 59);
      });
    }
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.all:
        return 'Tất cả';
      case TransactionType.deposit:
        return 'Nạp tiền';
      case TransactionType.withdrawal:
        return 'Rút tiền';
      case TransactionType.transfer:
        return 'Chuyển khoản';
      case TransactionType.payment:
        return 'Thanh toán';
    }
  }

  IconData _iconForType(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.payment:
        return Icons.receipt_long;
      case TransactionType.all:
        return Icons.list_alt;
    }
  }

  Color _amountColor(double amount) {
    return amount >= 0 ? Colors.green : Colors.red;
  }

  String _formatAmount(double amount, String currency) {
    final sign = amount >= 0 ? '+' : '-';
    final value = amount.abs().toStringAsFixed(0);
    return '$sign$value $currency';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child:
                BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
              builder: (context, state) {
                if (state is TransactionHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TransactionHistoryError) {
                  return Center(child: Text(state.message));
                }
                if (state is TransactionHistoryLoaded) {
                  final items = state.transactions;
                  if (_selectedAccount == null && state.accounts.isNotEmpty) {
                    // set default selected account lần đầu
                    _selectedAccount ??= state.accounts.first;
                  }

                  if (items.isEmpty) {
                    return _buildEmpty();
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<TransactionHistoryCubit>().refresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final t = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading:
                                Icon(_iconForType(t.type), color: Colors.blue),
                            title: Text(
                              _typeLabel(t.type),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.description),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(t.date),
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  switch (t.status) {
                                    TransactionStatus.pending => 'Đang xử lý',
                                    TransactionStatus.success => 'Thành công',
                                    TransactionStatus.failed => 'Thất bại',
                                  },
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: switch (t.status) {
                                      TransactionStatus.pending =>
                                        Colors.orange,
                                      TransactionStatus.success => Colors.green,
                                      TransactionStatus.failed => Colors.red,
                                    },
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              _formatAmount(t.amount, t.currency),
                              style: TextStyle(
                                color: _amountColor(t.amount),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                // Initial: show loader
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
        buildWhen: (prev, next) =>
            next is TransactionHistoryLoaded ||
            next is TransactionHistoryLoading,
        builder: (context, state) {
          final accounts = state is TransactionHistoryLoaded
              ? state.accounts
              : const <String>[];
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedAccount,
                      decoration: const InputDecoration(
                        labelText: 'Tài khoản',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text(acc),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedAccount = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TransactionType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Loại giao dịch',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: TransactionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_typeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(_fromDate == null || _toDate == null
                          ? 'Từ ngày – Đến ngày'
                          : '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year} - ${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'),
                      onPressed: _pickDateRange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.filter_alt),
                    label: const Text('Lọc'),
                    onPressed: () {
                      context.read<TransactionHistoryCubit>().applyFilter(
                            accountId: _selectedAccount,
                            type: _selectedType,
                            from: _fromDate,
                            to: _toDate,
                          );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Không có giao dịch', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
