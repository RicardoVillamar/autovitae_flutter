import 'package:flutter/material.dart';
import 'package:autovitae/data/models/vehiculo.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';

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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.directions_car,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        title: Text(
          '${vehiculo.marca ?? ''} ${vehiculo.modelo ?? ''}',
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Placa: ${vehiculo.placa ?? ''}',
              style: AppTextStyles.caption,
            ),
            Text(
              'Año: ${vehiculo.anio ?? ''}',
              style: AppTextStyles.caption,
            ),
            Text(
              'Kilometraje: ${vehiculo.kilometraje} km',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: AppColors.grey),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primaryColor),
                  SizedBox(width: 12),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Eliminar'),
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