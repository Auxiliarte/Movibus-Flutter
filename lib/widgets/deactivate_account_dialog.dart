// widgets/deactivate_account_dialog.dart
import 'package:flutter/material.dart';
import '../services/account_api_service.dart';

class DeactivateAccountDialog extends StatefulWidget {
  final String token;
  final VoidCallback? onAccountDeactivated;

  const DeactivateAccountDialog({
    Key? key,
    required this.token,
    this.onAccountDeactivated,
  }) : super(key: key);

  @override
  _DeactivateAccountDialogState createState() => _DeactivateAccountDialogState();
}

class _DeactivateAccountDialogState extends State<DeactivateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();
  final _accountApiService = AccountApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Eliminar Cuenta',
        style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.red.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer fácilmente.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message, color: Colors.grey),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu cuenta será desactivada y no podrás acceder hasta que la reactives.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deactivateAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Eliminar Cuenta'),
        ),
      ],
    );
  }

  Future<void> _deactivateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _accountApiService.deactivateAccount(
        password: _passwordController.text,
        reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
        token: widget.token,
      );

      if (result['status'] == 'success') {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Cuenta eliminada exitosamente'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 5),
          ),
        );
        widget.onAccountDeactivated?.call();
      } else {
        _showError(result['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      _showError('Error al eliminar cuenta: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
