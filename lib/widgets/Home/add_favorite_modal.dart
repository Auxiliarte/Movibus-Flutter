import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/favorite_location.dart';
import '../../services/favorite_service.dart';

class AddFavoriteModal extends StatefulWidget {
  const AddFavoriteModal({super.key});

  @override
  State<AddFavoriteModal> createState() => _AddFavoriteModalState();
}

class _AddFavoriteModalState extends State<AddFavoriteModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _useCurrentLocation() async {
    // TODO: Implementar obtener ubicación actual
    setState(() {
      _addressController.text = "Ubicación actual obtenida...";
      _latitudeController.text = "22.1497"; // SLP coordinates
      _longitudeController.text = "-100.9764";
    });
  }

  void _searchLocation() async {
    // TODO: Implementar búsqueda de ubicaciones con Places API
    if (_addressController.text.isEmpty) {
      setState(() {
        _errorMessage = "Por favor ingresa una dirección";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simular búsqueda (reemplazar con API real)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      // Simular resultado de búsqueda
      _latitudeController.text = "22.1500";
      _longitudeController.text = "-100.9770";
      _successMessage = "Ubicación encontrada";
    });
  }

  void _saveFavorite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final favorite = await FavoriteService().createFavorite(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
      );

      setState(() {
        _isLoading = false;
        _successMessage = "Ubicación favorita guardada exitosamente";
      });

      // Cerrar modal después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(favorite);
        }
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.add_location_alt,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Agregar Ubicación Favorita',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre *',
                            hintText: 'Ej: Casa, Trabajo, Universidad...',
                            prefixIcon: const Icon(Icons.label),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre es obligatorio';
                            }
                            if (value.trim().length < 2) {
                              return 'El nombre debe tener al menos 2 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dirección con botones
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _addressController,
                                    decoration: InputDecoration(
                                      labelText: 'Dirección *',
                                      hintText: 'Ingresa la dirección completa',
                                      prefixIcon: const Icon(Icons.location_on),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'La dirección es obligatoria';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _useCurrentLocation,
                                  icon: const Icon(Icons.my_location),
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _searchLocation,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.search),
                                label: Text(_isLoading ? 'Buscando...' : 'Buscar Ubicación'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Coordenadas
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latitudeController,
                                decoration: InputDecoration(
                                  labelText: 'Latitud',
                                  hintText: 'Ej: 22.1500',
                                  prefixIcon: const Icon(Icons.explore),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Obligatorio';
                                  }
                                  final lat = double.tryParse(value);
                                  if (lat == null || lat < -90 || lat > 90) {
                                    return 'Inválida';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _longitudeController,
                                decoration: InputDecoration(
                                  labelText: 'Longitud',
                                  hintText: 'Ej: -100.9770',
                                  prefixIcon: const Icon(Icons.explore_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Obligatorio';
                                  }
                                  final lng = double.tryParse(value);
                                  if (lng == null || lng < -180 || lng > 180) {
                                    return 'Inválida';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        // Mensajes de error/éxito
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: theme.colorScheme.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: theme.colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (_successMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveFavorite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
