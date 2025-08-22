import 'package:flutter/material.dart';
import '../models/favorite_location.dart';
import '../services/favorite_service.dart';
import '../widgets/Home/place_autocomplete_field.dart';

class AddFavoriteScreen extends StatefulWidget {
  const AddFavoriteScreen({super.key});

  @override
  State<AddFavoriteScreen> createState() => _AddFavoriteScreenState();
}

class _AddFavoriteScreenState extends State<AddFavoriteScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0; // 0: seleccionar dirección, 1: ingresar nombre

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onPlaceSelected(String name, double lat, double lng) {
    setState(() {
      _selectedAddress = name;
      _selectedLatitude = lat;
      _selectedLongitude = lng;
      _addressController.text = name;
      _currentStep = 1; // Avanzar al siguiente paso
    });
  }

  void _saveFavorite() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa un nombre para la ubicación';
      });
      return;
    }

    if (_selectedAddress == null || _selectedLatitude == null || _selectedLongitude == null) {
      setState(() {
        _errorMessage = 'Por favor selecciona una dirección primero';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final favorite = await FavoriteService().createFavorite(
        name: _nameController.text.trim(),
        address: _selectedAddress!,
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
      );

      if (mounted) {
        Navigator.of(context).pop(favorite);
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _goBackToAddressSelection() {
    setState(() {
      _currentStep = 0;
      _selectedAddress = null;
      _selectedLatitude = null;
      _selectedLongitude = null;
      _addressController.clear();
      _nameController.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == 0 ? 'Seleccionar Ubicación' : 'Nombre del Favorito',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_currentStep == 1) {
              _goBackToAddressSelection();
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(
            _currentStep == 1 ? Icons.arrow_back : Icons.close,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador de progreso
                Row(
                  children: [
                    _buildStepIndicator(0, _currentStep >= 0),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: _currentStep >= 1
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    _buildStepIndicator(1, _currentStep >= 1),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ubicación',
                      style: TextStyle(
                        fontSize: 12,
                        color: _currentStep >= 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      'Nombre',
                      style: TextStyle(
                        fontSize: 12,
                        color: _currentStep >= 1
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Contenido del paso actual
                Expanded(
                  child: SingleChildScrollView(
                    child: _currentStep == 0
                        ? _buildAddressSelectionStep()
                        : _buildNameInputStep(),
                  ),
                ),

                // Mensajes de error
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

                const SizedBox(height: 20),

                // Botón de acción
                if (_currentStep == 1) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveFavorite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Guardar Favorito',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive) {
    final theme = Theme.of(context);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSelectionStep() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Busca la ubicación',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escribe la dirección y selecciona una opción de la lista',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),

        // Campo de autocompletado
        PlaceAutocompleteField(
          hint: 'Ej: Av. Universidad 123, San Luis Potosí',
          onPlaceSelected: _onPlaceSelected,
          controller: _addressController,
          isOrigin: true,
        ),

        const SizedBox(height: 24),

        // Información adicional
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Una vez selecciones una dirección, podrás asignarle un nombre personalizado.',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameInputStep() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asigna un nombre',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elige un nombre fácil de recordar para esta ubicación',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),

        // Dirección seleccionada (solo lectura)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubicación seleccionada',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedAddress!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _goBackToAddressSelection,
                icon: Icon(
                  Icons.edit,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Cambiar ubicación',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Campo para el nombre
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nombre del favorito *',
            hintText: 'Ej: Casa, Trabajo, Universidad...',
            prefixIcon: const Icon(Icons.label),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          maxLength: 50,
        ),

        const SizedBox(height: 16),

        // Sugerencias de nombres
        Text(
          'Sugerencias populares:',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Casa',
            'Trabajo',
            'Universidad',
            'Centro',
            'Supermercado',
            'Gimnasio',
          ].map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              onPressed: () {
                _nameController.text = suggestion;
              },
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: theme.colorScheme.primary),
            );
          }).toList(),
        ),
      ],
    );
  }
}
