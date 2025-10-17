import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_history_cubit.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_transactions.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final int accountId;
  final GetTransactions getTransactions;
  const TransactionHistoryScreen({super.key, required this.accountId, required this.getTransactions});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  final int _pageSize = 20;
  final List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  bool _hasMore = true;
  late final TransactionHistoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TransactionHistoryCubit(widget.getTransactions);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchTransactions();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isLoading && _hasMore) {
      _fetchTransactions();
    }
  }

  void _fetchTransactions() {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    _cubit.fetchTransactions(widget.accountId, page: _page, pageSize: _pageSize).then((_) {
      if (!mounted) return;
      final state = _cubit.state;
      if (state is TransactionHistoryLoaded) {
        setState(() {
          if (state.transactions.length < _pageSize) _hasMore = false;
          _transactions.addAll(state.transactions);
          _page++;
        });
      } else if (state is TransactionHistoryError) {
        messenger.showSnackBar(SnackBar(content: Text(state.message)));
      }
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Transaction History')),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: _transactions.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _transactions.length) {
              final tx = _transactions[index];
              return ListTile(
                title: Text(tx.description),
                subtitle: Text('${tx.timestamp} - ${tx.amount}'),
              );
            } else {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            }
          },
        ),
      ),
    );
  }
}
