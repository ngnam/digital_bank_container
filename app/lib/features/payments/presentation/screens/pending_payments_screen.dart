import 'dart:convert';

import 'package:flutter/material.dart';
import '../../data/payment_repository.dart';

class PendingPaymentsScreen extends StatefulWidget {
  final PaymentRepository repository;
  const PendingPaymentsScreen({super.key, required this.repository});

  @override
  State<PendingPaymentsScreen> createState() => _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends State<PendingPaymentsScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  final Set<int> _loadingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    try {
      final rows = await widget.repository.getPendingRaw();
      setState(() { _rows = rows; });
    } catch (e) {
      // ignore
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _remove(int id) async {
    setState(() => _loadingIds.add(id));
    try {
      await widget.repository.removePendingById(id);
    } finally {
      setState(() => _loadingIds.remove(id));
      await _load();
    }
  }

  Future<void> _retry(int id) async {
    setState(() => _loadingIds.add(id));
    try {
      await widget.repository.retryPendingById(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retry attempted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Retry failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _loadingIds.remove(id));
        await _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending payments (debug)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rows.isEmpty
              ? const Center(child: Text('No pending payments'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _rows.length,
                    itemBuilder: (context, index) {
                      final r = _rows[index];
                      final id = r['id'] as int;
                      final payloadStr = r['payload'] as String;
                      final createdAt = r['createdAt'] as String? ?? '';
                      final attempts = r['attempts'] as int? ?? 0;
                      String pretty = payloadStr;
                      try {
                        final p = jsonDecode(payloadStr);
                        pretty = const JsonEncoder.withIndent('  ').convert(p);
                      } catch (_) {}
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('id: $id', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('createdAt: $createdAt'),
                              Text('attempts: $attempts'),
                              const SizedBox(height: 8),
                              Text(pretty),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_loadingIds.contains(id)) const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  TextButton(onPressed: _loadingIds.contains(id) ? null : () => _remove(id), child: const Text('Remove')),
                                  const SizedBox(width: 8),
                                  ElevatedButton(onPressed: _loadingIds.contains(id) ? null : () => _retry(id), child: const Text('Retry')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
