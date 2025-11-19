import 'package:flutter/material.dart';

class SelectItem {
  final int id;
  final String value;
  final Widget? customWidget;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final IconData? customIcon;

  const SelectItem({
    required this.id,
    required this.value,
    this.customWidget,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.customIcon,
  });

  @override
  String toString() => value;
}

class CustomSelect extends StatelessWidget {
  final String labelText;
  final List<SelectItem> items;
  final int? selectedId;
  final ValueChanged<SelectItem?>? onChanged;
  final bool enabled;
  final bool isRequired;
  final String? requiredErrorText;
  final String? errorText;
  final double borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double bottom;
  final String? hintText;
  final EdgeInsets? contentPadding;
  final IconData? prefixIcon;
  final bool autoSelectFirst;

  // Personalización del dropdown
  final double? dropdownMaxHeight;
  final Color? dropdownBackgroundColor;
  final double? dropdownBorderRadius;
  final EdgeInsets? dropdownItemPadding;
  final Color? dropdownHoverColor;
  final Color? dropdownSelectedColor;
  final TextStyle? dropdownTextStyle;
  final TextStyle? dropdownSelectedTextStyle;
  final IconData? selectedIcon;
  final IconData? unselectedIcon;
  final double? iconSize;
  final Color? defaultIconColor;
  final Color? defaultSelectedIconColor;

  const CustomSelect({
    Key? key,
    required this.labelText,
    required this.items,
    this.selectedId,
    this.onChanged,
    this.enabled = true,
    this.isRequired = false,
    this.requiredErrorText,
    this.errorText,
    this.borderRadius = 20,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.bottom = 20,
    this.hintText,
    this.contentPadding,
    this.prefixIcon,
    this.autoSelectFirst = true,

    // Personalización del dropdown
    this.dropdownMaxHeight = 200,
    this.dropdownBackgroundColor,
    this.dropdownBorderRadius,
    this.dropdownItemPadding,
    this.dropdownHoverColor,
    this.dropdownSelectedColor,
    this.dropdownTextStyle,
    this.dropdownSelectedTextStyle,
    this.selectedIcon = Icons.check,
    this.unselectedIcon = Icons.remove,
    this.iconSize = 16,
    this.defaultIconColor,
    this.defaultSelectedIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedId = _getEffectiveSelectedId();
    final isEmpty = effectiveSelectedId == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor ?? Colors.grey.shade400,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: borderColor ?? Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: focusedBorderColor ?? Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: errorBorderColor ?? Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: errorBorderColor ?? Colors.red,
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            labelText: labelText + (isRequired ? ' *' : ''),
            errorText: errorText,
            hintText: null,
            contentPadding:
                contentPadding ?? const EdgeInsets.fromLTRB(12, 2.5, 12, 2.5),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          isEmpty: isEmpty,
          child: _buildDropdownContent(effectiveSelectedId),
        ),

        if (isRequired && effectiveSelectedId == null && errorText == null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              requiredErrorText ?? 'Este campo es requerido',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],

        SizedBox(height: bottom),
      ],
    );
  }

  int? _getEffectiveSelectedId() {
    if (!items.isNotEmpty) return null;
    if (selectedId != null) {
      final exists = items.any((item) => item.id == selectedId);
      if (exists) return selectedId;
    }
    if (autoSelectFirst && items.isNotEmpty) {
      return items.first.id;
    }
    return null;
  }

  Widget _buildDropdownContent(int? effectiveSelectedId) {
    final hasItems = items.isNotEmpty;
    final isEnabled = enabled && hasItems;

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        key: ValueKey(effectiveSelectedId),
        value: effectiveSelectedId,
        onChanged: isEnabled ? _handleOnChanged : null,
        items: _buildDropdownItems(),
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: isEnabled ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
        style: TextStyle(
          color: isEnabled ? Colors.black : Colors.grey.shade400,
          fontSize: 16,
        ),
        hint: null,
        disabledHint: null,
        underline: Container(),
        dropdownColor: dropdownBackgroundColor ?? Colors.white,
        menuMaxHeight: dropdownMaxHeight ?? 200,
        borderRadius: BorderRadius.circular(dropdownBorderRadius ?? 8),
      ),
    );
  }

  void _handleOnChanged(int? selectedId) {
    if (onChanged == null) return;
    if (selectedId == null) {
      onChanged!(null);
      return;
    }
    final selectedItem = items.firstWhere(
      (item) => item.id == selectedId,
      orElse: () => const SelectItem(id: -1, value: ''),
    );
    if (selectedItem.id != -1) {
      onChanged!(selectedItem);
    } else {
      onChanged!(null);
    }
  }

  List<DropdownMenuItem<int>> _buildDropdownItems() {
    if (!items.isNotEmpty) {
      return [
        DropdownMenuItem<int>(
          value: -1,
          enabled: false,
          child: Padding(
            padding:
                dropdownItemPadding ??
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              'Sin datos disponibles',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ),
        ),
      ];
    }

    return items.map((SelectItem item) {
      final isSelected = item.id == _getEffectiveSelectedId();

      return DropdownMenuItem<int>(
        value: item.id,
        child: Container(
          color:
              item.backgroundColor ??
              (isSelected ? dropdownSelectedColor : Colors.transparent),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding:
                  dropdownItemPadding ??
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: item.customWidget ?? _buildDefaultItem(item, isSelected),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildDefaultItem(SelectItem item, bool isSelected) {
    return Row(
      children: [
        Icon(
          item.customIcon ?? (isSelected ? selectedIcon : unselectedIcon),
          size: iconSize,
          color:
              item.iconColor ??
              (isSelected
                  ? (defaultSelectedIconColor ?? Colors.green)
                  : (defaultIconColor ?? Colors.grey)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.value,
            style: _getItemTextStyle(item, isSelected),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  TextStyle _getItemTextStyle(SelectItem item, bool isSelected) {
    final baseStyle = isSelected
        ? (dropdownSelectedTextStyle ?? const TextStyle(fontSize: 16))
        : (dropdownTextStyle ?? const TextStyle(fontSize: 16));

    return baseStyle.copyWith(
      color:
          item.textColor ??
          (isSelected
              ? (dropdownSelectedTextStyle?.color ?? Colors.black)
              : (dropdownTextStyle?.color ?? Colors.grey.shade700)),
    );
  }
}
