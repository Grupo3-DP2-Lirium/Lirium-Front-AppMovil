import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/entities/memory.dart';
import 'package:flutter_frontend/presentation/components/components.dart';
import 'package:flutter_frontend/presentation/components/selection/list_selector.dart';
import 'package:flutter_frontend/presentation/screens/memories/memory_details/memory_controllers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemoryFormulario extends StatefulWidget {
  final Memory memory;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateController photoDateController;
  final LocationController locationController;

  const MemoryFormulario({
    super.key,
    required this.memory,
    required this.isEditing,
    required this.titleController,
    required this.descriptionController,
    required this.photoDateController,
    required this.locationController,
  });

  @override
  State<MemoryFormulario> createState() => _MemoryFormularioState();
}

class _MemoryFormularioState extends State<MemoryFormulario> {
  late TextEditingController _monthController;
  late TextEditingController _yearController;

  final List<String> _monthNames = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  ];

  @override
  void initState() {
    super.initState();

    final currentDate = widget.photoDateController.date;
    _monthController = TextEditingController(
      text: currentDate != null ? _monthNames[currentDate.month - 1] : '',
    );

    _yearController = TextEditingController(
      text: currentDate != null ? currentDate.year.toString() : '',
    );

    _monthController.addListener(_updatePhotoDateFromDropdowns);
    _yearController.addListener(_updatePhotoDateFromDropdowns);
  }

  void _updatePhotoDateFromDropdowns() {
    final monthText = _monthController.text.trim();
    final yearText = _yearController.text.trim();

    // Si no hay nada seleccionado aún, no hacemos nada
    if (monthText.isEmpty || yearText.isEmpty) return;

    final monthIndex = _monthNames.indexOf(monthText) + 1;
    final year = int.tryParse(yearText);
    if (monthIndex <= 0 || year == null) return;

    final currentDay = widget.photoDateController.date?.day ?? 1;
    widget.photoDateController.setDate(DateTime(year, monthIndex, currentDay));
  }

  // ------------------- Metadata -------------------
  Widget _buildMetaData() {
    return ExpansionTile(
      title: const Text(
        "Datos del Momento",
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconColor: AppColors.primary,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const Border(
        bottom: BorderSide(color: AppColors.inactive, width: 1),
      ),
      collapsedShape: const Border(
        bottom: BorderSide(color: AppColors.inactive, width: 1),
      ),
      children: [
        // Fila Mes + Año
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: AppDropdownField(
                  header: 'Mes',
                  controller: _monthController,
                  options: _monthNames,
                  enable: widget.isEditing,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppDropdownField(
                  header: 'Año',
                  controller: _yearController,
                  options: List.generate(50, (i) => (DateTime.now().year - i).toString()),
                  enable: widget.isEditing,
                ),
              ),
            ],
          ),
        ),

        // Ubicación
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () async {
              LatLng initialLatLng = LatLng(-12.0464, -77.0428); // default Lima

              if (widget.locationController.isValid) {
                initialLatLng = LatLng(
                  widget.locationController.latitude!,
                  widget.locationController.longitude!,
                );
              }

              final selected = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _MapSelectScreen(initialLocation: initialLatLng),
                ),
              );

              if (selected != null && selected is Map<String, dynamic>) {
                setState(() {
                  widget.locationController.setLocation(
                    address: selected['address'],
                    lat: selected['latitude'],
                    lon: selected['longitude'],
                  );
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: widget.locationController,
                style: TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: "Ubicación",
                  suffixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------- Formulario -------------------
  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.memory.associatedQuestion != null &&
              widget.memory.associatedQuestion!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppTextField(
                controller: TextEditingController(text: widget.memory.associatedQuestion),
                enabled: false,
                hintText: 'Pregunta Default',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppTextField(
                hintText: "Escribe un título",
                controller: widget.titleController,
                enabled: widget.isEditing,
                validator: (v) =>
                (v == null || v.isEmpty) ? "El título es obligatorio" : null,
              ),
            ),
          AppTextField(
            hintText: "Escribe una descripción",
            maxLines: 10,
            controller: widget.descriptionController,
            enabled: widget.isEditing,
            validator: (v) =>
            (v == null || v.isEmpty) ? "La descripción es obligatoria" : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMetaData(),
        _buildForm(),
      ],
    );
  }
}

// ------------------- Pantalla para seleccionar ubicación -------------------
class _MapSelectScreen extends StatefulWidget {
  final LatLng initialLocation;

  const _MapSelectScreen({required this.initialLocation});

  @override
  State<_MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<_MapSelectScreen> {
  late LatLng _picked;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _picked = widget.initialLocation;

    // Si locationController tiene ciudad, buscar sus coordenadas
    if (widget.initialLocation != null) {
      _getLatLngFromCity(widget.initialLocation);
    }
  }

  Future<void> _getLatLngFromCity(LatLng initialLatLng) async {
    final cityName = widget.initialLocation; // o el nombre de ciudad que tengas
    if (cityName != '') {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$cityName&format=json&limit=1');
      final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat']);
          final lon = double.parse(results[0]['lon']);
          setState(() {
            _picked = LatLng(lat, lon);
            _mapController.move(_picked, 13);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> searchLocation(String query) async {
      setState(() => _loading = true);
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');
      final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(json.decode(response.body));
          _loading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _loading = false;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona ubicación")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _picked,
              initialZoom: 13,
              onTap: (tapPos, latlng) {
                setState(() => _picked = latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pukinDev.lirium',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _picked,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Busca ciudad o pueblo",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        searchLocation(value);
                      } else {
                        setState(() => _searchResults = []);
                      }
                    },
                  ),
                  if (_loading)
                    const LinearProgressIndicator(),
                  if (_searchResults.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (_, index) {
                          final place = _searchResults[index];
                          final displayName = place['display_name'];
                          return ListTile(
                            title: Text(displayName),
                            onTap: () {
                              final lat = double.parse(place['lat']);
                              final lon = double.parse(place['lon']);
                              final displayName = place['display_name'];
                              setState(() {
                                _picked = LatLng(lat, lon);
                                _mapController.move(_picked, 13);
                                _searchController.text = displayName;
                                _searchResults = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () async {
          String cityName = _searchController.text.isNotEmpty
              ? _searchController.text // usa el texto seleccionado (ej. PUCP)
              : '';

          // Si no hay texto, usar reverse geocoding
          if (cityName.isEmpty) {
            final url = Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?lat=${_picked.latitude}&lon=${_picked.longitude}&format=json&addressdetails=1',
            );
            final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              final address = data['address'] ?? {};
              final keys = [
                'city', 'town', 'village', 'hamlet', 'municipality', 'county', 'state'
              ];
              for (var key in keys) {
                if (address.containsKey(key)) {
                  cityName = address[key];
                  break;
                }
              }
              if (cityName.isEmpty) {
                cityName =
                '${_picked.latitude.toStringAsFixed(4)}, ${_picked.longitude.toStringAsFixed(4)}';
              }
            }
          }

          Navigator.pop(context, {
            'address': cityName,
            'latitude': _picked.latitude,
            'longitude': _picked.longitude,
          });
        },
      ),
    );
  }
}