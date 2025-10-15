import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_history_cubit.dart';
import '../bloc/transaction_history_state.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final int accountId;
  const TransactionHistoryScreen({Key? key, required this.accountId}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  final int _pageSize = 20;
  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isLoading && _hasMore) {
      _fetchTransactions();
    }
  }

  void _fetchTransactions() {
    setState(() => _isLoading = true);
    context.read<TransactionHistoryCubit>().fetchTransactions(widget.accountId, page: _page, pageSize: _pageSize).then((_) {
      final state = context.read<TransactionHistoryCubit>().state;
      if (state is TransactionHistoryLoaded) {
        setState(() {
          if (state.transactions.length < _pageSize) _hasMore = false;
          _transactions.addAll(state.transactions);
          _page++;
        });
      } else if (state is TransactionHistoryError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
      }
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionHistoryCubit(context.read()),
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
                subtitle: Text('${tx.date} - ${tx.amount}'),
                trailing: tx.isOffline ? const Icon(Icons.cloud_off, color: Colors.orange) : null,
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
