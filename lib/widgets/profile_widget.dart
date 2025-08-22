// widgets/profile_widget.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/profile_api_service.dart';
import '../services/auth_service.dart';
import '../widgets/deactivate_account_dialog.dart';

class ProfileWidget extends StatefulWidget {
  final String token;

  const ProfileWidget({Key? key, required this.token}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final ProfileApiService _apiService = ProfileApiService();
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profile = await _apiService.getProfile(widget.token);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final result = await _apiService.updateProfilePhoto(
          token: widget.token,
          imageFile: File(image.path),
        );

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada'),
              backgroundColor: Colors.green,
            ),
          );
          _loadProfile(); // Recargar perfil
        } else {
          _showError(result['message'] ?? 'Error desconocido');
        }
      }
    } catch (e) {
      _showError('Error al actualizar foto: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/Welcome',
                    (route) => false
                  );
                }
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeactivateAccountDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeactivateAccountDialog(
          token: widget.token,
          onAccountDeactivated: () async {
            // Cerrar sesión después de desactivar la cuenta
            await _authService.logout();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/Welcome',
                (route) => false
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error al cargar perfil'),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(child: Text('No se pudo cargar el perfil'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de perfil y nombre
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profile!.profilePhotoUrl != null
                          ? NetworkImage(_profile!.profilePhotoUrl!)
                          : null,
                      child: _profile!.profilePhotoUrl == null
                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: theme.primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _updateProfilePhoto,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _profile!.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _profile!.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Información del perfil
          _buildProfileSection('Información Personal', [
            _buildProfileItem('Nombre', _profile!.name),
            if (_profile!.lastName != null && _profile!.lastName!.isNotEmpty)
              _buildProfileItem('Apellido', _profile!.lastName!),
            _buildProfileItem('Email', _profile!.email),
            if (_profile!.phone != null && _profile!.phone!.isNotEmpty)
              _buildProfileItem('Teléfono', _profile!.phone!),
            if (_profile!.birthDate != null && _profile!.birthDate!.isNotEmpty)
              _buildProfileItem('Fecha de Nacimiento', _profile!.birthDate!),
            if (_profile!.rfc != null && _profile!.rfc!.isNotEmpty)
              _buildProfileItem('RFC', _profile!.rfc!),
          ]),

          const SizedBox(height: 16),

          // Información de cuenta
          _buildProfileSection('Información de Cuenta', [
            _buildProfileItem('Tipo de Usuario',
                _profile!.isDriver ? 'Conductor' : 'Cliente'),
            _buildProfileItem('Estado',
                _profile!.isActive ? 'Activo' : 'Inactivo'),
            _buildProfileItem('Fecha de Registro', _profile!.createdAt),
            if (_profile!.emailVerifiedAt != null && _profile!.emailVerifiedAt!.isNotEmpty)
              _buildProfileItem('Email Verificado', _profile!.emailVerifiedAt!),
          ]),

          // Información del concesionario (solo para conductores)
          if (_profile!.isDriver && _profile!.concesionario != null) ...[
            const SizedBox(height: 16),
            _buildProfileSection('Información del Concesionario', [
              _buildProfileItem('ID', _profile!.concesionario!.id.toString()),
              _buildProfileItem('Nombre', _profile!.concesionario!.name),
            ]),
          ],

          const SizedBox(height: 32),

          // Botones de acción
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProfilePhoto,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cambiar Foto'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_profile!.profilePhotoUrl != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          try {
                            final result = await _apiService.deleteProfilePhoto(widget.token);
                            if (result['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Foto de perfil eliminada'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadProfile(); // Recargar perfil
                            } else {
                              _showError(result['message'] ?? 'Error desconocido');
                            }
                          } catch (e) {
                            _showError('Error al eliminar foto: $e');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Eliminar Foto'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Sección de Cuenta
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuenta',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.delete_forever, color: Colors.red.shade600),
                      title: Text(
                        "Eliminar cuenta",
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                      onTap: _showDeactivateAccountDialog,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        "Cerrar sesión",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: _showLogoutDialog,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
