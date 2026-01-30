import 'package:flutter/material.dart';
import 'package:autovitae/data/models/vehiculo.dart';

class VehicleCard extends StatelessWidget {
  final Vehiculo vehiculo;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VehicleCard({
    super.key,
    required this.vehiculo,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.directions_car,
            color: colorScheme.primary,
            size: 28,
          ),
        ),
        title: Text(
          '${vehiculo.marca ?? ''} ${vehiculo.modelo ?? ''}',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Placa: ${vehiculo.placa ?? ''}',
              style: textTheme.bodySmall,
            ),
            Text(
              'Año: ${vehiculo.anio ?? ''}',
              style: textTheme.bodySmall,
            ),
            Text(
              'Kilometraje: ${vehiculo.kilometraje} km',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  const Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: colorScheme.error),
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
        isThreeLine: true,
      ),
    );
  }
}
