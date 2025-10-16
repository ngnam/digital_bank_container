import 'package:flutter/material.dart';
import '../../data/payment_repository.dart';
import '../../domain/models/schedule.dart';
import 'schedule_edit_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  final PaymentRepository repository;
  const ScheduleListScreen({super.key, required this.repository});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  List<ScheduleModel> _schedules = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await widget.repository.getSchedules();
    setState(() => _schedules = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedules')),
      body: _schedules.isEmpty ? const Center(child: Text('No schedules')) : ListView.builder(
        itemCount: _schedules.length,
        itemBuilder: (c, i) => ListTile(
          title: Text(_schedules[i].name),
          subtitle: Text(_schedules[i].cron),
          onTap: () async {
            final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleEditScreen(repository: widget.repository, schedule: _schedules[i])));
            if (updated == true) _load();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleEditScreen(repository: widget.repository)));
          if (created == true) _load();
        },
      ),
    );
  }
}
