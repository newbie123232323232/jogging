import 'package:flutter/material.dart';

class BodyInfo {
  final double height; // in cm
  final double weight; // in kg
  final bool isMale; // true for male, false for female

  const BodyInfo({
    required this.height,
    required this.weight,
    required this.isMale,
  });
}

class BodyInfoDialog extends StatefulWidget {
  const BodyInfoDialog({super.key});

  @override
  State<BodyInfoDialog> createState() => _BodyInfoDialogState();
}

class _BodyInfoDialogState extends State<BodyInfoDialog> {
  double _height = 170.0; // cm
  double _weight = 70.0; // kg
  bool _isMale = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Body Information'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Height: ${_height.toStringAsFixed(1)} cm'),
            Slider(
              value: _height,
              min: 140,
              max: 200,
              divisions: 120,
              onChanged: (value) => setState(() => _height = value),
            ),
            const SizedBox(height: 16),
            Text('Weight: ${_weight.toStringAsFixed(1)} kg'),
            Slider(
              value: _weight,
              min: 40,
              max: 120,
              divisions: 160,
              onChanged: (value) => setState(() => _weight = value),
            ),
            const SizedBox(height: 16),
            const Text('Gender:'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Male'),
                    value: true,
                    groupValue: _isMale,
                    onChanged: (value) => setState(() => _isMale = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Female'),
                    value: false,
                    groupValue: _isMale,
                    onChanged: (value) => setState(() => _isMale = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final bodyInfo = BodyInfo(
              height: _height,
              weight: _weight,
              isMale: _isMale,
            );
            Navigator.of(context).pop(bodyInfo);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

Future<BodyInfo?> showBodyInfoDialog(BuildContext context) {
  return showDialog<BodyInfo>(
    context: context,
    builder: (context) => const BodyInfoDialog(),
  );
}
