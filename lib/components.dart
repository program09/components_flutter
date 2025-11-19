import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:journey_unit/widgets/build_boton.dart';
import 'package:journey_unit/widgets/build_field.dart';
import 'package:journey_unit/widgets/build_radio.dart';
import 'package:journey_unit/widgets/build_select.dart';
import 'package:journey_unit/widgets/build_switch.dart';

class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({super.key});

  @override
  State<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends State<ComponentsScreen> {
  final FocusNode myFocusNode = FocusNode();
  int? _selectedId;
  int? _documentTypeId;
  bool notificaciones = false;

  void _handleSelectChange(int? id) {
    log("Selected ID: $id");
    setState(() {
      _selectedId = id ?? -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Components Screen')),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Botones Personalizados'),
              Column(
                children: [
                  const SizedBox(height: 16),
                  buildBoton(
                    text: 'Custom Button',
                    hasIcon: true,
                    icon: Icons.check,
                    fullWidth: true,
                    onPressed: () {
                      // Acción al presionar el botón
                    },
                  ),
                  const SizedBox(height: 16),
                  buildBoton(
                    text: 'Custom Button',
                    fullWidth: true,
                    isDisabled: true,
                    onPressed: () {
                      // Acción al presionar el botón
                    },
                  ),
                  const SizedBox(height: 16),
                  buildBoton(
                    text: 'Custom Button',
                    fullWidth: true,
                    isLoading: true,
                    onPressed: () {
                      // Acción al presionar el botón
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botón outline con color personalizado
                  buildBoton(
                    text: "Outline Azul",
                    fullWidth: true,
                    isOutlined: true,
                    outlineColor: Colors.black,
                    textColor: Colors.black,
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Text("Inputs Personalizados"),
              // Aquí puedes agregar tus widgets de inputs personalizados
              Column(
                children: [
                  // Campo de texto básico
                  CustomField(
                    labelText: 'Nombre completo',
                    onChanged: (value) => print(value),
                    bottom: 20,
                  ),

                  // Campo con validación de email
                  CustomField(
                    labelText: 'Email',
                    fieldType: FieldType.email,
                    isRequired: true,
                    prefixIcon: Icons.email,
                  ),

                  // Campo para documento de identificación con dropdown
                  CustomField(
                    labelText: 'Número de documento',
                    fieldType: FieldType.dni,
                    showDocumentSelector: true,
                    dropdownItems: [
                      SelectItem(id: 1, value: 'DNI'),
                      SelectItem(id: 2, value: 'CE'),
                      SelectItem(id: 3, value: 'Pasaporte'),
                      SelectItem(id: 4, value: 'RUC'),
                    ],
                    dropdownValue: _documentTypeId, // int
                    onDropdownChanged: (selectedItem) {
                      print(
                        'Tipo seleccionado: ${selectedItem?.value} (ID: ${selectedItem?.id})',
                      );
                      setState(() {
                        _documentTypeId = selectedItem?.id;
                      });
                    },
                  ),

                  // Campo de teléfono
                  CustomField(
                    labelText: 'Teléfono',
                    fieldType: FieldType.phone,
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  // Campo de contraseña
                  CustomField(
                    labelText: 'Contraseña',
                    fieldType: FieldType.password,
                    isObscure: true,
                    prefixIcon: Icons.lock,
                  ),

                  // Campo con validación personalizada
                  CustomField(
                    labelText: 'Código postal',
                    validator: (value) {
                      if (value == null || value.length != 5) {
                        return 'El código postal debe tener 5 dígitos';
                      }
                      return null;
                    },
                    maxLength: 5,
                  ),

                  // Con focusNode personalizado
                  CustomField(
                    labelText: 'Campo con focusNode personalizado',
                    focusNode: myFocusNode,
                    autoUnfocus: true,
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Text("Selects Personalizados"),
              Column(
                children: [
                  CustomSelect(
                    labelText: 'Estado',
                    items: [
                      SelectItem(id: 1, value: 'Activo'),
                      SelectItem(id: 2, value: 'Inactivo'),
                      SelectItem(id: 3, value: 'Pendiente'),
                    ],
                    selectedId: _selectedId,
                    onChanged: (id) {
                      _handleSelectChange(id?.id);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),

                  // Select normal con hint personalizado
                ],
              ),

              Column(
                children: [
                  const SizedBox(height: 32),
                  Text("Otros Componentes Personalizados"),
                  // Aquí puedes agregar otros componentes personalizados
                  CustomSwitch(
                    label: "Recibir notificaciones",
                    initialValue: notificaciones,
                    onChanged: (value) {
                      notificaciones = value;
                      print("Nuevo valor: $value");
                    },
                  ),

                  CustomRadioGroup(
                    label: "Nivel de prioridad",
                    initialValue: null,
                    options: const [
                      RadioOption(id: 1, label: "Bajo"),
                      RadioOption(id: 2, label: "Medio"),
                      RadioOption(id: 3, label: "Alto"),
                    ],
                    onChanged: (value) {
                      print("Nuevo valor seleccionado: $value");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
