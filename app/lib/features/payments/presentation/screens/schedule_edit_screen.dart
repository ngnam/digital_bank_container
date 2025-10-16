import 'package:flutter/material.dart';
import '../../data/payment_repository.dart';
import '../../domain/models/schedule.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../accounts/domain/entities/account_entity.dart';

class ScheduleEditScreen extends StatefulWidget {
  final PaymentRepository repository;
  final AccountRepository? accountRepository;
  final ScheduleModel? schedule;
  const ScheduleEditScreen({super.key, required this.repository, this.accountRepository, this.schedule});

  @override
  State<ScheduleEditScreen> createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends State<ScheduleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC;
  late TextEditingController _cronC;
  late TextEditingController _amountC;
  List<AccountEntity> _accounts = [];
  int? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.schedule?.name ?? '');
    _cronC = TextEditingController(text: widget.schedule?.cron ?? '');
    _amountC = TextEditingController(text: widget.schedule?.amount.toString() ?? '');
    _selectedAccountId = widget.schedule?.fromAccountId;
    _loadAccountsIfNeeded();
  }

  Future<void> _loadAccountsIfNeeded() async {
    if (widget.accountRepository != null) {
      try {
        final list = await widget.accountRepository!.getAccounts();
        if (!mounted) return;
        setState(() => _accounts = list);
      } catch (_) {
        // ignore failures, user can still type id
      }
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _cronC.dispose();
    _amountC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final fromId = _selectedAccountId ?? int.tryParse(_accounts.isEmpty ? '' : _accounts.first.id.toString()) ?? (widget.schedule?.fromAccountId ?? 0);
    final s = ScheduleModel(
      id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: _nameC.text.trim(),
      cron: _cronC.text.trim(),
      fromAccountId: fromId,
      amount: double.tryParse(_amountC.text.trim()) ?? 0.0,
    );
    await widget.repository.saveSchedule(s);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.schedule == null ? 'Create Schedule' : 'Edit Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(controller: _nameC, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null),
                TextFormField(controller: _cronC, decoration: const InputDecoration(labelText: 'Cron expression'), validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 8),
                if (_accounts.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedAccountId,
                    decoration: const InputDecoration(labelText: 'From account'),
                    items: _accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.accountNumber} — ${a.ownerName}'))).toList(),
                    onChanged: (v) => setState(() => _selectedAccountId = v),
                    validator: (v) => v == null ? 'Select account' : null,
                  ),
                ] else ...[
                  TextFormField(decoration: const InputDecoration(labelText: 'From account id'), keyboardType: TextInputType.number, initialValue: widget.schedule?.fromAccountId.toString(), validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null, onChanged: (v) => _selectedAccountId = int.tryParse(v)),
                ],
                TextFormField(controller: _amountC, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
