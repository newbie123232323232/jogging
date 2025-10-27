import 'package:equatable/equatable.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';

typedef EntryID = String;

class Entry extends Equatable {
  const Entry({
    required this.id,
    required this.jobId,
    required this.start,
    required this.end,
    required this.comment,
    this.distance = 0.0,
    this.avgSpeed = 0.0,
    this.calories = 0.0,
  });
  final EntryID id;
  final JobID jobId;
  final DateTime start;
  final DateTime end;
  final String comment;
  final double distance;
  final double avgSpeed;
  final double calories;

  @override
  List<Object> get props => [id, jobId, start, end, comment, distance, avgSpeed, calories];

  @override
  bool get stringify => true;

  double get durationInHours =>
      end.difference(start).inMinutes.toDouble() / 60.0;

  factory Entry.fromMap(Map<dynamic, dynamic> value, EntryID id) {
    final startMilliseconds = value['start'] as int;
    final endMilliseconds = value['end'] as int;
    return Entry(
      id: id,
      jobId: value['jobId'] as String,
      start: DateTime.fromMillisecondsSinceEpoch(startMilliseconds),
      end: DateTime.fromMillisecondsSinceEpoch(endMilliseconds),
      comment: value['comment'] as String? ?? '',
      distance: (value['distance'] as num?)?.toDouble() ?? 0.0,
      avgSpeed: (value['avgSpeed'] as num?)?.toDouble() ?? 0.0,
      calories: (value['calories'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jobId': jobId,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'comment': comment,
      'distance': distance,
      'avgSpeed': avgSpeed,
      'calories': calories,
    };
  }
}
