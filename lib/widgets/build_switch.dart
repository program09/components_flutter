import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final Color activeColor;
  final Color inactiveColor;

  const CustomSwitch({
    Key? key,
    this.initialValue = false, // 👉 valor por defecto apagado
    this.onChanged,
    this.label,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue; // 👉 se setea el valor inicial
  }

  void _toggle(bool newValue) {
    setState(() => _value = newValue);
    if (widget.onChanged != null) {
      widget.onChanged!(newValue); // 👉 Notifica al padre
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.label != null)
          Text(widget.label!, style: const TextStyle(fontSize: 16)),

        Switch(
          value: _value,
          onChanged: _toggle,
          activeColor: widget.activeColor,
          inactiveThumbColor: widget.inactiveColor,
        ),
      ],
    );
  }
}
