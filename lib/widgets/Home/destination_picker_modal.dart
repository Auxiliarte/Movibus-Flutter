import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';

class DestinationPickerModal extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final String? originAddress;
  final String? destinationAddress;

  const DestinationPickerModal({
    super.key,
    required this.origin,
    required this.destination,
    this.originAddress,
    this.destinationAddress,
  });

  @override
  State<DestinationPickerModal> createState() => _DestinationPickerModalState();
}

class _DestinationPickerModalState extends State<DestinationPickerModal> {
  GoogleMapController? _mapController;
  late LatLng _destination;
  String? _destinationAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _destinationAddress = widget.destinationAddress;
    _getAddressFromLocation(_destination);
  }

  Future<void> _getAddressFromLocation(LatLng location) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final address = await LocationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      setState(() {
        _destinationAddress = address ??
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        _destinationAddress = 'Ubicación seleccionada';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _destination = location;
    });
    _getAddressFromLocation(location);
  }

  void _confirmSelection() {
    Navigator.of(context).pop({
      'latitude': _destination.latitude,
      'longitude': _destination.longitude,
      'address': _destinationAddress ?? 'Ubicación seleccionada',
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Confirma o ajusta tu destino',
              style: theme.textTheme.titleMedium,
            ),
          ),
          SizedBox(
            height: 350,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _destination,
                    zoom: 15,
                  ),
                  onTap: _onMapTap,
                  markers: {
                    Marker(
                      markerId: const MarkerId('origin'),
                      position: widget.origin,
                      infoWindow: InfoWindow(
                        title: 'Origen',
                        snippet: widget.originAddress ?? 'Origen',
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: _destination,
                      draggable: true,
                      onDragEnd: (pos) {
                        setState(() {
                          _destination = pos;
                        });
                        _getAddressFromLocation(pos);
                      },
                      infoWindow: InfoWindow(
                        title: 'Destino',
                        snippet: _destinationAddress ?? 'Destino',
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _destinationAddress ?? 'Cargando dirección...',
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmSelection,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar destino'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 