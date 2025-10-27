import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/date_time_picker.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/responsive_center.dart';
import 'package:starter_architecture_flutter_firebase/src/common_widgets/body_info_dialog.dart'
    show BodyInfo, showBodyInfoDialog;
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/breakpoints.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/presentation/entry_screen/entry_screen_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/async_value_ui.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/format.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/fake_location_service.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/data/jobs_repository.dart';

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, required this.jobId, this.entryId, this.entry});
  final JobID jobId;
  final EntryID? entryId;
  final Entry? entry;

  @override
  ConsumerState<EntryScreen> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryScreen> {
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late String _comment;

  DateTime get start => DateTime(_startDate.year, _startDate.month,
      _startDate.day, _startTime.hour, _startTime.minute);
  DateTime get end => DateTime(_endDate.year, _endDate.month, _endDate.day,
      _endTime.hour, _endTime.minute);

  @override
  void initState() {
    super.initState();
    final start = widget.entry?.start ?? DateTime.now();
    _startDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay.fromDateTime(start);

    final end = widget.entry?.end ?? DateTime.now();
    _endDate = DateTime(end.year, end.month, end.day);
    _endTime = TimeOfDay.fromDateTime(end);

    _comment = widget.entry?.comment ?? '';
  }

  Future<void> _setEntryAndDismiss() async {
    // Show body info dialog for ALL jobs (demo jogging feature)
    BodyInfo? bodyInfo;
    double distance = 0.0;
    double avgSpeed = 0.0;
    double calories = 0.0;
    
    // Show body info dialog
    bodyInfo = await showBodyInfoDialog(context);
    if (bodyInfo == null) {
      return; // User cancelled
    }

    // For demo: distance = 0 (GPS stands still), calculate metrics accordingly
    final duration = end.difference(start);
    distance = 0.0; // Demo: GPS stands still
    avgSpeed = 0.0; // Demo: no movement
    calories = 0.0; // Demo: no calories consumed (no distance travelled)

    final success =
        await ref.read(entryScreenControllerProvider.notifier).submit(
              entryId: widget.entryId,
              jobId: widget.jobId,
              start: start,
              end: end,
              comment: _comment,
              distance: distance,
              avgSpeed: avgSpeed,
              calories: calories,
            );
    if (success && mounted) {
      context.pop();
    }
  }

  Future<FakeLocation?> _showLocationPicker() async {
    return showDialog<FakeLocation>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Destination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FakeLocation.destinations.map((location) {
            final distance = FakeLocationService.getDistanceToDestination(location);
            return ListTile(
              title: Text(location.name),
              subtitle: Text('${distance.toStringAsFixed(2)} km'),
              onTap: () => Navigator.of(context).pop(location),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      entryScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.jpg',
              height: 28,
              width: 28,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Text(widget.entry != null ? 'Edit Entry' : 'New Entry'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              widget.entry != null ? 'Update' : 'Create',
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            onPressed: () => _setEntryAndDismiss(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxContentWidth: Breakpoint.tablet,
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildStartDate(),
              _buildEndDate(),
              gapH8,
              _buildDuration(),
              gapH8,
              _buildJoggingMetrics(),
              gapH8,
              _buildComment(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartDate() {
    return DateTimePicker(
      labelText: 'Start',
      selectedDate: _startDate,
      selectedTime: _startTime,
      onSelectedDate: (date) => setState(() => _startDate = date),
      onSelectedTime: (time) => setState(() => _startTime = time),
    );
  }

  Widget _buildEndDate() {
    return DateTimePicker(
      labelText: 'End',
      selectedDate: _endDate,
      selectedTime: _endTime,
      onSelectedDate: (date) => setState(() => _endDate = date),
      onSelectedTime: (time) => setState(() => _endTime = time),
    );
  }

  Widget _buildDuration() {
    final durationInHours = end.difference(start).inMinutes.toDouble() / 60.0;
    final durationFormatted = Format.hours(durationInHours);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          'Duration: $durationFormatted',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildJoggingMetrics() {
    final entry = widget.entry;
    if (entry == null) {
      return const SizedBox.shrink(); // Hide for new entries
    }
    
    final distance = entry.distance;
    final avgSpeed = entry.avgSpeed;
    final calories = entry.calories;
    
    // Only show if any value is non-zero
    if (distance == 0.0 && avgSpeed == 0.0 && calories == 0.0) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jogging Metrics',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem('Distance', '${distance.toStringAsFixed(2)} km'),
                _buildMetricItem('Avg Speed', '${avgSpeed.toStringAsFixed(2)} km/h'),
                _buildMetricItem('Calories', '${calories.toStringAsFixed(0)} kcal'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildComment() {
    return TextField(
      keyboardType: TextInputType.text,
      maxLength: 50,
      controller: TextEditingController(text: _comment),
      decoration: const InputDecoration(
        labelText: 'Comment',
        labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      keyboardAppearance: Brightness.light,
      style: const TextStyle(fontSize: 20.0, color: Colors.black),
      maxLines: null,
      onChanged: (comment) => _comment = comment,
    );
  }
}
