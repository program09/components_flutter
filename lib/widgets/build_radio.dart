import 'package:flutter/material.dart';

class RadioOption {
  final int id;
  final String label;

  const RadioOption({required this.id, required this.label});
}

class CustomRadioGroup extends StatefulWidget {
  final List<RadioOption> options;
  final int? initialValue;
  final ValueChanged<int>? onChanged;
  final String? label;

  const CustomRadioGroup({
    Key? key,
    required this.options,
    this.initialValue,
    this.onChanged,
    this.label,
  }) : super(key: key);

  @override
  _CustomRadioGroupState createState() => _CustomRadioGroupState();
}

class _CustomRadioGroupState extends State<CustomRadioGroup> {
  int? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _onSelect(int? value) {
    if (value == null) return;

    setState(() => _selectedValue = value);

    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

        ...widget.options.map((option) {
          return InkWell(
            onTap: () => _onSelect(option.id),
            child: Row(
              children: [
                Radio<int>(
                  value: option.id,
                  groupValue: _selectedValue,
                  onChanged: _onSelect,
                ),
                Text(option.label, style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
