import 'package:flutter/material.dart';
import 'package:autovitae/viewmodels/cliente_viewmodel.dart';

/// Diálogo reutilizable para confirmar contraseña antes de acciones sensibles
class PasswordConfirmDialog extends StatefulWidget {
  final ClienteViewModel viewModel;
  final String title;
  final String message;

  const PasswordConfirmDialog({
    super.key,
    required this.viewModel,
    this.title = 'Confirmar Cambios',
    this.message = 'Para aplicar los cambios, ingresa tu contraseña actual:',
  });

  /// Muestra el diálogo y retorna true si la autenticación fue exitosa
  static Future<bool> show({
    required BuildContext context,
    required ClienteViewModel viewModel,
    String title = 'Confirmar Cambios',
    String message = 'Para aplicar los cambios, ingresa tu contraseña actual:',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PasswordConfirmDialog(
        viewModel: viewModel,
        title: title,
        message: message,
      ),
    );
    return result ?? false;
  }

  @override
  State<PasswordConfirmDialog> createState() => _PasswordConfirmDialogState();
}

class _PasswordConfirmDialogState extends State<PasswordConfirmDialog> {
  final _passwordController = TextEditingController();
  bool _isVerifying = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _closeDialog(bool result) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  Future<void> _verify() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu contraseña');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final success = await widget.viewModel.reauthenticate(
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _closeDialog(true);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = widget.viewModel.error ?? 'Contraseña incorrecta';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock_outline, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.title, style: textTheme.titleLarge),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              errorText: _errorMessage,
            ),
            onSubmitted: (_) => _verify(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => _closeDialog(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isVerifying ? null : _verify,
          child: _isVerifying
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Text('Confirmar'),
        ),
      ],
    );
  }
}
