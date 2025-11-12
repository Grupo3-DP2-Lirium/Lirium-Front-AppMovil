import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class FilterCarouselSelector extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final List<Map<String, dynamic>> filters;

  const FilterCarouselSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.filters,
  });

  @override
  State<FilterCarouselSelector> createState() => _FilterCarouselSelectorState();
}

class _FilterCarouselSelectorState extends State<FilterCarouselSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtro Visual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Desliza →',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Estilo Instagram Stories',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 16),

        // Carousel horizontal
        SizedBox(
          height: 140,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: widget.filters.length,
            itemBuilder: (context, index) {
              final filter = widget.filters[index];
              final isSelected = widget.selectedFilter == filter['id'];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildFilterCard(
                  filterId: filter['id'],
                  filterName: filter['name'],
                  filterDescription: filter['description'],
                  previewUrl: filter['preview'],
                  isSelected: isSelected,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterCard({
    required String filterId,
    required String filterName,
    required String filterDescription,
    required String? previewUrl,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => widget.onFilterSelected(filterId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview de imagen
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen con filtro aplicado desde Unsplash
                    Image.network(
                      _getFilterDemoImageUrl(filterId),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage(filterId);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        );
                      },
                    ),

                    // Badge del nombre del filtro
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          filterName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Overlay de selección
                    if (isSelected)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 32,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Nombre del filtro
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Text(
                filterName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Genera URL de imagen de demostración con el filtro aplicado
  String _getFilterDemoImageUrl(String filterId) {
    // Usar una imagen base de Unsplash (foto de muestra)
    const baseImageId = 'premium_photo-1759139845043-68e6cf57f66f'; // Foto de Unsplash
    const width = 300;
    const height = 400;

    // URL base de Unsplash
    //String url = 'https://images.unsplash.com/photo-$baseImageId?w=$width&h=$height&fit=crop';
    String url = 'https://plus.unsplash.com/premium_photo-1759139845043-68e6cf57f66f?ixlib=rb-4.1.0&auto=format&fit=crop&q=80&w=1374';

    // Aplicar filtros según el tipo (usando parámetros de Unsplash)
    switch (filterId.toUpperCase()) {
      case 'VIVID':
      // Colores vibrantes y saturados
        return '$url&sat=50&con=20';

      case 'DRAMATIC':
      // Alto contraste, sombras profundas
        return '$url&con=50&bri=-10&sat=-30';

      case 'YELLOW':
      // Tonos cálidos amarillos/dorados
        return '$url&sat=20&hue=40';

      case 'MONO':
      // Blanco y negro
        return '$url&sat=-100';

      case 'SILVERTONE':
      // Tonos plateados/azulados
        return '$url&sat=-50&hue=200';

      case 'NATURAL':
      default:
      // Sin filtro (colores naturales)
        return url;
    }
  }

  /// Genera una imagen placeholder con gradiente según el filtro
  Widget _buildPlaceholderImage(String filterId) {
    LinearGradient gradient;

    switch (filterId.toUpperCase()) {
      case 'VIVID':
        gradient = LinearGradient(
          colors: [Colors.pink[300]!, Colors.purple[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'DRAMATIC':
        gradient = LinearGradient(
          colors: [Colors.black, Colors.grey[800]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        break;
      case 'YELLOW':
        gradient = LinearGradient(
          colors: [Colors.yellow[300]!, Colors.orange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'MONO':
        gradient = LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'SILVERTONE':
        gradient = LinearGradient(
          colors: [Colors.blue[200]!, Colors.blueGrey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'NATURAL':
      default:
        gradient = LinearGradient(
          colors: [Colors.green[200]!, Colors.teal[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Center(
        child: Icon(
          Icons.filter_vintage,
          size: 32,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
}