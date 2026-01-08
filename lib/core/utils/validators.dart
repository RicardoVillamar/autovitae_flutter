import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter/material.dart';

class Validators {
  // Validador de email
  static final emailValidator = MultiValidator([
    RequiredValidator(errorText: 'El correo es requerido'),
    EmailValidator(errorText: 'Ingrese un correo válido'),
  ]);

  // Validador de contraseña
  static final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'La contraseña es requerida'),
    MinLengthValidator(
      6,
      errorText: 'La contraseña debe tener al menos 6 caracteres',
    ),
  ]);

  // Validador de nombre
  static final nameValidator = MultiValidator([
    RequiredValidator(errorText: 'El nombre es requerido'),
    MinLengthValidator(
      2,
      errorText: 'El nombre debe tener al menos 2 caracteres',
    ),
  ]);

  // Validador de teléfono
  static final phoneValidator = MultiValidator([
    RequiredValidator(errorText: 'El teléfono es requerido'),
    PatternValidator(
      r'^[0-9]{10}$',
      errorText: 'Ingrese un teléfono válido (10 dígitos)',
    ),
  ]);

  // Validador de cédula
  static final cedulaValidator = MultiValidator([
    RequiredValidator(errorText: 'La cédula es requerida'),
    PatternValidator(
      r'^[0-9]{10}$',
      errorText: 'Ingrese una cédula válida (10 dígitos)',
    ),
  ]);

  // Validador de placa
  static final placaValidator = MultiValidator([
    RequiredValidator(errorText: 'La placa es requerida'),
    MinLengthValidator(
      6,
      errorText: 'La placa debe tener al menos 6 caracteres',
    ),
  ]);

  // Validador de precio
  static final priceValidator = MultiValidator([
    RequiredValidator(errorText: 'El precio es requerido'),
  ]);

  // Validador genérico requerido
  static final requiredValidator = RequiredValidator(
    errorText: 'Este campo es requerido',
  );

  // Validador de direcciones
  static final addressValidator = MultiValidator([
    RequiredValidator(errorText: 'La dirección es requerida'),
    MinLengthValidator(
      5,
      errorText: 'La dirección debe tener al menos 5 caracteres',
    ),
  ]);

  // Validación de número entero positivo
  static String? validatePositiveInt(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    final intValue = int.tryParse(value);
    if (intValue == null || intValue <= 0) {
      return 'Debe ser un número positivo';
    }
    return null;
  }

  // Validación de número decimal positivo
  static String? validatePositiveDouble(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    final doubleValue = double.tryParse(value);
    if (doubleValue == null || doubleValue <= 0) {
      return 'Debe ser un número positivo';
    }
    return null;
  }

  // Validación de año de vehículo
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'El año es requerido';
    }
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    if (year == null || year < 1900 || year > currentYear + 1) {
      return 'Ingrese un año válido';
    }
    return null;
  }

  // Validación de confirmación de contraseña
  static String? Function(String?) passwordMatchValidator(
    TextEditingController passwordController,
  ) {
    return (value) {
      if (value != passwordController.text) {
        return 'Las contraseñas no coinciden';
      }
      return null;
    };
  }
}
