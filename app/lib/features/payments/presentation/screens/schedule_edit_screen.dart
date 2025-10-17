import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  final amt = widget.schedule?.amount ?? 0.0;
  _amountC = TextEditingController(text: amt == 0.0 ? '' : NumberFormat.currency(symbol: '', decimalDigits: 2).format(amt));
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
    final amountVal = double.tryParse(_amountC.text.replaceAll(',', '').trim()) ?? 0.0;
    final s = ScheduleModel(
      id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: _nameC.text.trim(),
      cron: _cronC.text.trim(),
      fromAccountId: fromId,
      amount: amountVal,
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
                // Recurrence selector (friendly)
                _RecurrenceSelector(
                  controller: _cronC,
                ),
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
                TextFormField(
                  controller: _amountC,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
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

class _RecurrenceSelector extends StatefulWidget {
  final TextEditingController controller;
  const _RecurrenceSelector({required this.controller});

  @override
  State<_RecurrenceSelector> createState() => _RecurrenceSelectorState();
}

class _RecurrenceSelectorState extends State<_RecurrenceSelector> {
  String _value = 'daily';
  final Map<String, String> _labels = {
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'custom': 'Custom (cron)'
  };

  @override
  void initState() {
    super.initState();
    final existing = widget.controller.text.trim();
    if (existing.isNotEmpty) {
      if (existing == 'daily' || existing == 'weekly' || existing == 'monthly') {
        _value = existing;
      } else {
        _value = 'custom';
      }
    }
    // ensure controller contains a friendly token if empty
    if (widget.controller.text.trim().isEmpty) widget.controller.text = 'daily';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _value,
          decoration: const InputDecoration(labelText: 'Recurrence'),
          items: _labels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _value = v);
            if (v != 'custom') {
              widget.controller.text = v;
            }
          },
        ),
        if (_value == 'custom') ...[
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Cron expression'),
            initialValue: widget.controller.text == 'custom' ? '' : widget.controller.text,
            onChanged: (v) => widget.controller.text = v,
            validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
          ),
        ],
      ],
    );
  }
}
