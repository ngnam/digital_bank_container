import 'package:flutter/material.dart';
import '../../data/payment_repository.dart';
import '../../domain/models/template.dart';
import 'template_edit_screen.dart';

class TemplateListScreen extends StatefulWidget {
  final PaymentRepository repository;
  const TemplateListScreen({super.key, required this.repository});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  List<TemplateModel> _templates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
  final list = await widget.repository.getTemplates();
  setState(() => _templates = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: _templates.isEmpty ? const Center(child: Text('No templates')) : ListView.builder(
        itemCount: _templates.length,
        itemBuilder: (c, i) => ListTile(
          title: Text(_templates[i].name),
          subtitle: Text(_templates[i].accountNumber),
          onTap: () async {
            final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateEditScreen(repository: widget.repository, template: _templates[i])));
            if (updated == true) _load();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateEditScreen(repository: widget.repository)));
          if (created == true) _load();
        },
      ),
    );
  }
}

