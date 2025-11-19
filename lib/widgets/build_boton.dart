import 'package:flutter/material.dart';

Widget buildBoton({
  required String text,
  Color? textColor = Colors.white,
  Color? color = Colors.black,
  bool? hasIcon = false,
  IconData? icon,
  bool? isDisabled = false,
  bool? isLoading = false,
  double? width = 100, // Ancho personalizado
  double? height = 50, // Alto personalizado
  bool fullWidth = false, // Ocupar el 100% del ancho disponible
  VoidCallback? onPressed,
  bool? isOutlined = false,
  Color? outlineColor, // Color del borde (opcional)
  double? outlineWidth = 1.0, // Grosor del borde
  double borderRadius = 20, // Nuevo parámetro para border radius
}) {
  return Container(
    color: Colors.transparent,
    width: fullWidth ? double.infinity : width,
    height: height,
    child: isOutlined == true
        ? OutlinedButton(
            onPressed: isDisabled == true || isLoading == true
                ? null
                : onPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              backgroundColor:
                  Colors.transparent, // Fondo transparente para outline
              foregroundColor: isDisabled == true
                  ? const Color.fromARGB(255, 177, 177, 177)
                  : textColor,
              side: BorderSide(
                color: isDisabled == true
                    ? const Color.fromARGB(255, 177, 177, 177)
                    : outlineColor ?? color ?? Colors.black,
                width: outlineWidth ?? 1.0,
              ),
              disabledForegroundColor: const Color.fromARGB(255, 177, 177, 177),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: _buildChild(
              isLoading: isLoading,
              hasIcon: hasIcon,
              icon: icon,
              text: text,
              textColor: isDisabled == true
                  ? const Color.fromARGB(255, 177, 177, 177)
                  : textColor,
              isDisabled: isDisabled,
            ),
          )
        : ElevatedButton(
            onPressed: isDisabled == true || isLoading == true
                ? null
                : onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              backgroundColor: color,
              foregroundColor: textColor,
              disabledBackgroundColor: const Color.fromARGB(255, 238, 238, 238),
              disabledForegroundColor: const Color.fromARGB(255, 177, 177, 177),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: _buildChild(
              isLoading: isLoading,
              hasIcon: hasIcon,
              icon: icon,
              text: text,
              textColor: textColor,
              isDisabled: isDisabled,
            ),
          ),
  );
}

// Widget auxiliar para construir el contenido del botón
Widget _buildChild({
  required bool? isLoading,
  required bool? hasIcon,
  required IconData? icon,
  required String text,
  required Color? textColor,
  required bool? isDisabled,
}) {
  return isLoading == true
      ? const SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        )
      : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasIcon == true && icon != null)
              Icon(
                icon,
                size: 20,
                color: isDisabled == true
                    ? const Color.fromARGB(255, 177, 177, 177)
                    : textColor,
              ),
            if (hasIcon == true && icon != null) const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isDisabled == true
                    ? const Color.fromARGB(255, 177, 177, 177)
                    : textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
}
