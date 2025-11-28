import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:event_management/features/unit/presentation/widgets/unit_card.dart';
import 'package:flutter/material.dart';

class UnitTreeItem extends StatefulWidget {
  const UnitTreeItem({
    required this.unit,
    required this.subUnits,
    required this.onTap,
    this.onDelete,
    this.level = 0,
    this.allUnits,
    super.key,
  });

  final UnitEntity unit;
  final List<UnitEntity> subUnits;
  final void Function(UnitEntity unit) onTap;
  final void Function(UnitEntity unit)? onDelete;
  final int level;
  final List<UnitEntity>? allUnits;

  @override
  State<UnitTreeItem> createState() => _UnitTreeItemState();
}

class _UnitTreeItemState extends State<UnitTreeItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.value = 1.0; // Start expanded
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.subUnits.isNotEmpty;
    final indent = widget.level * 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent Unit Card
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: Row(
            children: [
              // Expand/Collapse Button
              if (hasChildren)
                InkWell(
                  onTap: _toggle,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.coolGray500,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 24),
              // Unit Card
              Expanded(
                child: UnitCard(
                  unit: widget.unit,
                  onTap: () => widget.onTap(widget.unit),
                  onDelete: widget.onDelete != null
                      ? () => widget.onDelete!(widget.unit)
                      : null,
                ),
              ),
            ],
          ),
        ),

        // Sub Units (with animation)
        if (hasChildren)
          SizeTransition(
            sizeFactor: _animation,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.spaceMD),
                ...widget.subUnits.map((subUnit) {
                  // Find sub-sub units if allUnits is provided
                  // Only include units where parentId equals subUnit.id and is different from unit's own id
                  final subSubUnits = widget.allUnits != null
                      ? widget.allUnits!
                            .where(
                              (u) =>
                                  u.parentId == subUnit.id &&
                                  u.parentId != u.id,
                            )
                            .toList()
                      : <UnitEntity>[];
                  return UnitTreeItem(
                    unit: subUnit,
                    subUnits: subSubUnits,
                    onTap: widget.onTap,
                    onDelete: widget.onDelete,
                    level: widget.level + 1,
                    allUnits: widget.allUnits,
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}
