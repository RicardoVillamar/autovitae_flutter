import 'package:flutter/material.dart';
import 'package:autovitae/data/models/vehiculo.dart';

class VehicleCard extends StatelessWidget {
  final Vehiculo vehiculo;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.vehiculo,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasImage = vehiculo.imageUrl != null && vehiculo.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen o placeholder del vehículo
                Stack(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                      ),
                      child: hasImage
                          ? Image.network(
                              vehiculo.imageUrl!,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(colorScheme),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: colorScheme.primary,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                            )
                          : _buildPlaceholder(colorScheme),
                    ),
                    // Menú de opciones
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PopupMenuButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined,
                                      color: colorScheme.primary, size: 20),
                                  const SizedBox(width: 12),
                                  const Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: colorScheme.error, size: 20),
                                  const SizedBox(width: 12),
                                  const Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit' && onEdit != null) {
                              onEdit!();
                            } else if (value == 'delete' && onDelete != null) {
                              onDelete!();
                            }
                          },
                        ),
                      ),
                    ),
                    // Badge de kilometraje
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.speed,
                              color: colorScheme.onPrimary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatKilometraje(vehiculo.kilometraje)} km',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Información del vehículo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: Row(
                    children: [
                      // Icono del vehículo
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Detalles
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehiculo.marca ?? ''} ${vehiculo.modelo ?? ''}'
                                  .trim(),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.confirmation_number_outlined,
                                  vehiculo.placa ?? '',
                                  colorScheme,
                                  textTheme,
                                ),
                                const SizedBox(width: 12),
                                _buildInfoChip(
                                  Icons.calendar_today_outlined,
                                  '${vehiculo.anio ?? ''}',
                                  colorScheme,
                                  textTheme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.directions_car_outlined,
        size: 64,
        color: colorScheme.primary.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatKilometraje(int km) {
    if (km >= 1000) {
      return '${(km / 1000).toStringAsFixed(km % 1000 == 0 ? 0 : 1)}k';
    }
    return km.toString();
  }
}
