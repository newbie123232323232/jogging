import 'dart:async';
import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/format.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/fake_location_service.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';

class EntryListItem extends StatefulWidget {
  const EntryListItem({
    super.key,
    required this.entry,
    required this.job,
    this.onTap,
  });

  final Entry entry;
  final Job job;
  final VoidCallback? onTap;

  @override
  State<EntryListItem> createState() => _EntryListItemState();
}

class _EntryListItemState extends State<EntryListItem> {
  late Timer _timer;
  late DateTime _now;
  late double _fakeDistance; // Accumulated fake distance in meters
  late double _lastUpdateDistance; // Last distance update for speed calculation
  int _lastUpdateTime = 0; // Last update timestamp for 5-second intervals

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _fakeDistance = widget.entry.distance * 1000; // Convert km to meters
    _lastUpdateDistance = _fakeDistance;
    _lastUpdateTime = _now.millisecondsSinceEpoch;
    
    // Update every second to check if entry has ended and simulate GPS drift
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
          
          // Add GPS drift every 5 seconds (simulate GPS position error)
          final currentTime = _now.millisecondsSinceEpoch;
          if (currentTime - _lastUpdateTime >= 5000) {
            _lastUpdateTime = currentTime;
            _lastUpdateDistance = _fakeDistance;
            _fakeDistance += FakeLocationService.simulateGpsDrift();
          }
        });
        
        // Stop timer if entry has ended
        if (widget.entry.end.isBefore(_now)) {
          _timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool get _hasEnded => widget.entry.end.isBefore(_now);
  
  // Calculate current distance in meters
  double get _currentDistance => _fakeDistance;

  Widget _buildMetric({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
    required bool isActive,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? color : Colors.grey.shade400,
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isActive ? color : Colors.grey.shade400,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Calculate average speed based on last 5 seconds of movement (in km/h)
  double get _currentSpeed {
    if (!_hasEnded) {
      // Calculate speed from last 5 seconds of GPS drift
      final distanceChange = _fakeDistance - _lastUpdateDistance; // in meters
      final hours = 5 / 3600.0; // 5 seconds in hours
      return (distanceChange / 1000) / hours; // Convert meters to km and calculate km/h
    }
    return widget.entry.avgSpeed;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _buildContents(context),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_run, 
                color: Colors.white, 
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final dayOfWeek = Format.dayOfWeek(widget.entry.start);
    final startDate = Format.date(widget.entry.start);
    final startTime = TimeOfDay.fromDateTime(widget.entry.start).format(context);
    final endTime = TimeOfDay.fromDateTime(widget.entry.end).format(context);
    final durationFormatted = Format.hours(widget.entry.durationInHours);

    final pay = widget.job.ratePerHour * widget.entry.durationInHours;
    final payFormatted = Format.currency(pay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dayOfWeek.toUpperCase(),
              style: const TextStyle(
                fontSize: 12.0, 
                color: Colors.white, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            startDate, 
            style: const TextStyle(
              fontSize: 16.0, 
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          if (widget.job.ratePerHour > 0.0) ...<Widget>[
            Expanded(child: Container()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                payFormatted,
                style: const TextStyle(
                  fontSize: 13.0, 
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Icon(Icons.access_time, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 4),
            Text(
              '$startTime - $endTime', 
              style: TextStyle(
                fontSize: 14.0, 
                color: Colors.blueGrey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(child: Container()),
            Icon(Icons.timer_outlined, size: 16, color: Colors.purple.shade600),
            const SizedBox(width: 4),
            Text(
              durationFormatted, 
              style: TextStyle(
                fontSize: 14.0, 
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        // Show real-time jogging metrics (with GPS drift simulation)
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                icon: Icons.straighten,
                value: '${_currentDistance.toStringAsFixed(1)}',
                unit: 'm',
                color: Colors.blue.shade600,
                isActive: _currentDistance > 0,
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade300),
              _buildMetric(
                icon: Icons.speed,
                value: '${_currentSpeed.toStringAsFixed(2)}',
                unit: 'km/h',
                color: Colors.orange.shade600,
                isActive: _currentSpeed > 0,
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade300),
              _buildMetric(
                icon: Icons.local_fire_department,
                value: '${widget.entry.calories.toStringAsFixed(0)}',
                unit: 'kcal',
                color: Colors.red.shade600,
                isActive: widget.entry.calories > 0,
              ),
            ],
          ),
        ),
        if (!_hasEnded)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade400, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Running...',
                        style: TextStyle(
                          fontSize: 12.0, 
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (widget.entry.comment.isNotEmpty)
          Text(
            widget.entry.comment,
            style: const TextStyle(fontSize: 12.0),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }
}

class DismissibleEntryListItem extends StatelessWidget {
  const DismissibleEntryListItem({
    super.key,
    required this.dismissibleKey,
    required this.entry,
    required this.job,
    this.onDismissed,
    this.onTap,
  });

  final Key dismissibleKey;
  final Entry entry;
  final Job job;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: dismissibleKey,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismissed?.call(),
      child: EntryListItem(
        entry: entry,
        job: job,
        onTap: onTap,
      ),
    );
  }
}
