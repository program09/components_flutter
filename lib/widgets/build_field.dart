import 'package:flutter/material.dart';
import 'package:journey_unit/widgets/build_select.dart';

class CustomField extends StatefulWidget {
  final String labelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final bool isObscure;
  final TextInputType keyboardType;
  final bool enabled;
  final bool readOnly;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final String? prefixText;
  final List<SelectItem>? dropdownItems; // Cambiado a SelectItem
  final int? dropdownValue; // Cambiado a int
  final ValueChanged<SelectItem?>? onDropdownChanged; // Cambiado a SelectItem
  final int maxLines;
  final int? maxLength;
  final bool showCounter;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final String? hintText;
  final EdgeInsets? contentPadding;
  final String? initialValue;
  final bool isRequired;
  final String? requiredErrorText;
  final FieldType fieldType;
  final double borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final bool autoUnfocus;
  final double bottom;
  final bool showDocumentSelector;

  const CustomField({
    Key? key,
    required this.labelText,
    this.controller,
    this.onChanged,
    this.validator,
    this.errorText,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.prefixWidget,
    this.prefixText,
    this.dropdownItems,
    this.dropdownValue,
    this.onDropdownChanged,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.textInputAction,
    this.onTap,
    this.focusNode,
    this.hintText,
    this.contentPadding,
    this.initialValue,
    this.isRequired = false,
    this.requiredErrorText,
    this.fieldType = FieldType.text,
    this.borderRadius = 20,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.autoUnfocus = true,
    this.bottom = 20,
    this.showDocumentSelector = false,
  }) : super(key: key);

  @override
  _CustomFieldState createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  late FocusNode _focusNode;
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _focusNode = widget.focusNode ?? _internalFocusNode;
    _focusNode.addListener(_onFocusChange);

    // 👉 Seleccionar automáticamente el primer item si no hay selección
    if (widget.dropdownItems != null &&
        widget.dropdownItems!.isNotEmpty &&
        widget.dropdownValue == null &&
        widget.onDropdownChanged != null) {
      final firstItem = widget.dropdownItems!.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDropdownChanged!(firstItem);
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (widget.controller != null && widget.controller!.text.isNotEmpty) {
        _focusNode.context?.findAncestorStateOfType<FormState>()?.validate();
      }
    }
  }

  void _handleTapOutside(PointerDownEvent event) {
    if (widget.autoUnfocus && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  /*
  String? _getDisplayValue() {
    if (widget.dropdownItems == null || widget.dropdownValue == null) {
      return 'DNI';
    }

    final selectedItem = widget.dropdownItems!.firstWhere(
      (item) => item.id == widget.dropdownValue,
      orElse: () => const SelectItem(id: -1, value: 'DNI'),
    );

    return selectedItem.value;
  }
  */

  @override
  Widget build(BuildContext context) {
    final hasDocumentSelector =
        widget.showDocumentSelector &&
        widget.dropdownItems != null &&
        widget.dropdownItems!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila con el selector de documento y el input
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de documento (solo si showDocumentSelector es true)
            if (hasDocumentSelector) ...[
              Container(
                width: 100,
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.borderColor ?? Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.borderRadius),
                    bottomLeft: Radius.circular(widget.borderRadius),
                  ),
                ),
                child: _buildDocumentDropdown(),
              ),
            ],

            // Campo de texto principal
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (_) {
                  if (widget.autoUnfocus && _focusNode.hasFocus) {
                    _focusNode.unfocus();
                  }
                },
                child: Listener(
                  onPointerDown: _handleTapOutside,
                  child: TextFormField(
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    validator: _buildValidator,
                    obscureText: widget.isObscure,
                    keyboardType: _getKeyboardType(),
                    enabled: widget.enabled,
                    readOnly: widget.readOnly,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    textInputAction: widget.textInputAction,
                    onTap: widget.onTap,
                    focusNode: _focusNode,
                    initialValue: widget.initialValue,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: hasDocumentSelector
                            ? BorderRadius.only(
                                topRight: Radius.circular(widget.borderRadius),
                                bottomRight: Radius.circular(
                                  widget.borderRadius,
                                ),
                              )
                            : BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: widget.borderColor ?? Colors.grey.shade400,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: hasDocumentSelector
                            ? BorderRadius.only(
                                topRight: Radius.circular(widget.borderRadius),
                                bottomRight: Radius.circular(
                                  widget.borderRadius,
                                ),
                              )
                            : BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: widget.borderColor ?? Colors.grey.shade400,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: hasDocumentSelector
                            ? BorderRadius.only(
                                topRight: Radius.circular(widget.borderRadius),
                                bottomRight: Radius.circular(
                                  widget.borderRadius,
                                ),
                              )
                            : BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color:
                              widget.focusedBorderColor ??
                              Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: hasDocumentSelector
                            ? BorderRadius.only(
                                topRight: Radius.circular(widget.borderRadius),
                                bottomRight: Radius.circular(
                                  widget.borderRadius,
                                ),
                              )
                            : BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: widget.errorBorderColor ?? Colors.red,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: hasDocumentSelector
                            ? BorderRadius.only(
                                topRight: Radius.circular(widget.borderRadius),
                                bottomRight: Radius.circular(
                                  widget.borderRadius,
                                ),
                              )
                            : BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: widget.errorBorderColor ?? Colors.red,
                          width: 2.0,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: hasDocumentSelector
                            ? BorderRadius.only(
                                topRight: Radius.circular(widget.borderRadius),
                                bottomRight: Radius.circular(
                                  widget.borderRadius,
                                ),
                              )
                            : BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      labelText:
                          widget.labelText + (widget.isRequired ? ' *' : ''),
                      errorText: widget.errorText,
                      hintText: widget.hintText,
                      counterText: widget.showCounter ? null : '',
                      contentPadding:
                          widget.contentPadding ??
                          const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                      prefixIcon: widget.prefixIcon != null
                          ? Icon(widget.prefixIcon)
                          : null,
                      prefixText: widget.prefixText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Margen inferior
        SizedBox(height: widget.bottom),
      ],
    );
  }

  Widget _buildDocumentDropdown() {
    final hasItems =
        widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty;
    final isEnabled = widget.enabled && hasItems;

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: widget.dropdownValue,
        onChanged: isEnabled ? _handleDropdownChanged : null,
        items: _buildDropdownItems(),
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: isEnabled ? Colors.grey.shade600 : Colors.grey.shade400,
          size: 20,
        ),
        style: TextStyle(
          fontSize: 14,
          color: isEnabled ? Colors.black : Colors.grey.shade400,
        ),
        underline: Container(),
        dropdownColor: Colors.white,
      ),
    );
  }

  void _handleDropdownChanged(int? selectedId) {
    if (selectedId == null || widget.onDropdownChanged == null) return;

    final selectedItem = widget.dropdownItems!.firstWhere(
      (item) => item.id == selectedId,
      orElse: () => const SelectItem(id: -1, value: ''),
    );

    if (selectedItem.id != -1) {
      widget.onDropdownChanged!(selectedItem);
    }
  }

  List<DropdownMenuItem<int>> _buildDropdownItems() {
    if (widget.dropdownItems == null || widget.dropdownItems!.isEmpty) {
      return [
        DropdownMenuItem<int>(
          value: -1,
          enabled: false,
          child: Text(
            'Sin datos',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ),
      ];
    }

    return widget.dropdownItems!.map((SelectItem item) {
      return DropdownMenuItem<int>(
        value: item.id,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(item.value, style: const TextStyle(fontSize: 16)),
        ),
      );
    }).toList();
  }

  // Validador automático basado en el tipo de campo
  String? _buildValidator(String? value) {
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    if (widget.isRequired && (value == null || value.isEmpty)) {
      return widget.requiredErrorText ?? 'Este campo es requerido';
    }

    switch (widget.fieldType) {
      case FieldType.email:
        if (value != null && value.isNotEmpty && !_isValidEmail(value)) {
          return 'Por favor ingresa un email válido';
        }
        break;
      case FieldType.phone:
        if (value != null && value.isNotEmpty && !_isValidPhone(value)) {
          return 'Por favor ingresa un número de teléfono válido';
        }
        break;
      case FieldType.number:
        if (value != null && value.isNotEmpty && !_isValidNumber(value)) {
          return 'Por favor ingresa solo números';
        }
        break;
      case FieldType.dni:
        if (value != null && value.isNotEmpty && !_isValidDNI(value)) {
          return 'Por favor ingresa un DNI válido';
        }
        break;
      case FieldType.password:
        if (value != null && value.isNotEmpty && value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        break;
      default:
        break;
    }

    return null;
  }

  // Tipo de teclado basado en el fieldType
  TextInputType _getKeyboardType() {
    switch (widget.fieldType) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.number:
      case FieldType.dni:
        return TextInputType.number;
      default:
        return widget.keyboardType;
    }
  }

  // Validaciones
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9+\-\s()]{10,}$').hasMatch(phone);
  }

  bool _isValidNumber(String number) {
    return RegExp(r'^[0-9]+$').hasMatch(number);
  }

  bool _isValidDNI(String dni) {
    return RegExp(r'^[0-9]{8}$').hasMatch(dni);
  }
}

// Tipos de campos predefinidos
enum FieldType { text, email, phone, number, dni, password }
