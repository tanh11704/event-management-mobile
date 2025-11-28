import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/unit/domain/entities/unit_type.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:flutter/material.dart';

class UnitCard extends StatelessWidget {
  const UnitCard({
    required this.unit,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final UnitEntity unit;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceMD),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor(unit.unitType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: _getTypeColor(unit.unitType),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.unitName,
                      style: AppTextStyles.heading5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(
                              unit.unitType,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            unit.unitType.label,
                            style: AppTextStyles.caption.copyWith(
                              color: _getTypeColor(unit.unitType),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unit.parentName != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '• ${unit.parentName}',
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.red500,
                  onPressed: onDelete,
                  tooltip: 'Xóa',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(UnitType unitType) {
    switch (unitType) {
      case UnitType.department:
        return AppColors.vkuBlue;
      case UnitType.student:
        return AppColors.green500;
      case UnitType.external:
        return AppColors.amber600;
    }
  }
}
