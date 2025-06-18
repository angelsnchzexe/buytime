import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SliderField extends StatefulWidget {
  final double min;
  final double max;
  final double value;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;
  final double salario; // ← NUEVO

  const SliderField({
    Key? key,
    required this.min,
    required this.max,
    required this.value,
    required this.divisions,
    required this.label,
    required this.onChanged,
    required this.salario, // ← NUEVO
  }) : super(key: key);

  @override
  State<SliderField> createState() => _SliderFieldState();
}

class _SliderFieldState extends State<SliderField> {
  late double currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant SliderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        currentValue = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ahorro = widget.salario * currentValue;
    final formatter = NumberFormat.currency(locale: 'es', symbol: '€');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.label}: ${(currentValue * 100).toStringAsFixed(0)}% → ${formatter.format(ahorro)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            valueIndicatorColor: Theme.of(context).colorScheme.primary,
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: Slider(
            value: currentValue,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: formatter.format(ahorro),
            onChanged: (value) {
              setState(() {
                currentValue = value;
              });
              widget.onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
