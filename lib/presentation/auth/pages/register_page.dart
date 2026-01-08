import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autovitae/viewmodels/register_viewmodel.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:autovitae/presentation/shared/screens/location_picker_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterViewModel _viewModel = RegisterViewModel();

  // Controllers
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  // UI Specific fields
  String? _selectedCiudad;
  String _selectedGenero = 'Masculino';
  DateTime? _fechaNacimiento;
  bool _acceptedTerms = false;

  final List<String> _ciudades = [
    'Quito',
    'Guayaquil',
    'Cuenca',
    'Santo Domingo',
    'Machala',
    'Durán',
    'Manta',
    'Portoviejo',
    'Loja',
    'Ambato',
    'Esmeraldas',
    'Quevedo',
    'Riobamba',
    'Milagro',
    'Ibarra',
    'La Libertad',
    'Babahoyo',
    'Sangolquí',
    'Daule',
    'Latacunga',
    'Tulcán',
    'Chone',
    'Pasaje',
    'Santa Rosa',
    'Nueva Loja',
    'Huaquillas',
    'El Carmen',
    'Montecristi',
    'Samborondón',
    'Puerto Francisco de Orellana',
    'Jipijapa',
    'Santa Elena',
    'Otavalo',
    'Cayambe',
    'Buena Fe',
    'Ventanas',
    'Velasco Ibarra',
    'La Troncal',
    'El Empalme',
    'Azogues',
    'Salinas',
    'Playas',
    'Otra',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cedulaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // ~18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.black,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (result != null && result['address'] != null) {
      setState(() {
        _direccionController.text = result['address'];
      });
    }
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: AppColors.error)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _register() async {
    // Validaciones de campos vacíos
    if (_nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _cedulaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _direccionController.text.isEmpty) {
      _showErrorAlert('Por favor completa todos los campos de texto');
      return;
    }

    if (_selectedCiudad == null) {
      _showErrorAlert('Por favor selecciona una ciudad');
      return;
    }

    if (_fechaNacimiento == null) {
      _showErrorAlert('Por favor selecciona tu fecha de nacimiento');
      return;
    }

    // Validacion fecha nacimiento
    if (_fechaNacimiento!.isAfter(DateTime.now())) {
      _showErrorAlert('La fecha de nacimiento no puede ser futura');
      return;
    }

    // Validacion contraseñas iguales
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorAlert('Las contraseñas no coinciden');
      return;
    }

    // Validacion terminos y condiciones
    if (!_acceptedTerms) {
      _showErrorAlert(
        'Debes aceptar los términos y condiciones para registrarte',
      );
      return;
    }

    // Call ViewModel
    setState(() {});

    final success = await _viewModel.registerCliente(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      cedula: _cedulaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      ciudad: _selectedCiudad!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso'),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigate to home
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home_client', (route) => false);
    } else if (mounted) {
      _showErrorAlert(_viewModel.error ?? 'Error en el registro');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro de Cliente'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
      ),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datos Personales', style: AppTextStyles.headline1),
                  const SizedBox(height: 20),

                  // Nombre y Apellido
                  TxtffCustom(
                    label: 'Nombre',
                    screenWidth: screenWidth,
                    controller: _nombreController,
                    showCounter: false,
                  ),
                  const SizedBox(height: 16),
                  TxtffCustom(
                    label: 'Apellido',
                    screenWidth: screenWidth,
                    controller: _apellidoController,
                    showCounter: false,
                  ),
                  const SizedBox(height: 16),

                  // Cedula y Telefono
                  TxtffCustom(
                    label: 'Cédula',
                    screenWidth: screenWidth,
                    controller: _cedulaController,
                    showCounter: false,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  TxtffCustom(
                    label: 'Teléfono',
                    screenWidth: screenWidth,
                    controller: _telefonoController,
                    showCounter: false,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),

                  // Fecha Nacimiento (Calendar)
                  Text(
                    'Fecha de Nacimiento *',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey),
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _fechaNacimiento == null
                                ? 'Seleccionar fecha'
                                : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}',
                            style: AppTextStyles.bodyText,
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Genero (RadioButton)
                  Text(
                    'Género *',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Masculino',
                        groupValue: _selectedGenero,
                        activeColor: AppColors.primaryColor,
                        onChanged: (value) =>
                            setState(() => _selectedGenero = value!),
                      ),
                      const Text('Masculino'),
                      Radio<String>(
                        value: 'Femenino',
                        groupValue: _selectedGenero,
                        activeColor: AppColors.primaryColor,
                        onChanged: (value) =>
                            setState(() => _selectedGenero = value!),
                      ),
                      const Text('Femenino'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Datos de Contacto / Ubicación
                  Text('Ubicación y Cuenta', style: AppTextStyles.headline1),
                  const SizedBox(height: 20),

                  // Direccion (Location Picker)
                  Text(
                    'Dirección *',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey),
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _direccionController.text.isEmpty
                                  ? 'Seleccionar ubicación en el mapa'
                                  : _direccionController.text,
                              style: AppTextStyles.bodyText.copyWith(
                                color: _direccionController.text.isEmpty
                                    ? AppColors.grey
                                    : AppColors.textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ciudad (ComboBox)
                  Text(
                    'Ciudad *',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCiudad,
                        hint: const Text('Selecciona tu ciudad'),
                        items: _ciudades.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCiudad = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email y Password
                  TxtffCustom(
                    label: 'Email',
                    screenWidth: screenWidth,
                    controller: _emailController,
                    showCounter: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TxtffCustom(
                    label: 'Contraseña',
                    screenWidth: screenWidth,
                    controller: _passwordController,
                    showCounter: false,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TxtffCustom(
                    label: 'Confirmar Contraseña',
                    screenWidth: screenWidth,
                    controller: _confirmPasswordController,
                    showCounter: false,
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),
                  // Terminos y condiciones
                  CheckboxListTile(
                    title: const Text(
                      'Desea aceptar nuestros términos y condiciones',
                    ),
                    value: _acceptedTerms,
                    activeColor: AppColors.primaryColor,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Boton Registrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Registrarse',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Boton Limpiar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.error),
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Limpiar formulario'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  void _clearForm() {
    _nombreController.clear();
    _apellidoController.clear();
    _cedulaController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    setState(() {
      _selectedCiudad = null;
      _selectedGenero = 'Masculino';
      _fechaNacimiento = null;
      _acceptedTerms = false;
    });
  }
}
