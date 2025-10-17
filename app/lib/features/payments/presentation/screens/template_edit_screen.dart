import 'package:flutter/material.dart';
import '../../data/payment_repository.dart';
import '../../domain/models/template.dart';

class TemplateEditScreen extends StatefulWidget {
  final PaymentRepository repository;
  final TemplateModel? template;
  const TemplateEditScreen({super.key, required this.repository, this.template});

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC;
  late TextEditingController _accountC;
  late TextEditingController _bankC;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.template?.name ?? '');
    _accountC = TextEditingController(text: widget.template?.accountNumber ?? '');
    _bankC = TextEditingController(text: widget.template?.bankCode ?? '');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _accountC.dispose();
    _bankC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final t = TemplateModel(
      id: widget.template?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: _nameC.text.trim(),
      accountNumber: _accountC.text.trim(),
      bankCode: _bankC.text.trim(),
    );
    final navigator = Navigator.of(context);
    await widget.repository.saveTemplate(t);
    if (!mounted) return;
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.template == null ? 'Create Template' : 'Edit Template')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameC, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null),
              TextFormField(controller: _accountC, decoration: const InputDecoration(labelText: 'Account number'), validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null),
              TextFormField(controller: _bankC, decoration: const InputDecoration(labelText: 'Bank code'), validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
