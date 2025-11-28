import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/unit/data/model/unit_request_dto.dart';
import 'package:event_management/features/unit/domain/entities/unit_type.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:event_management/features/unit/domain/repository/unit_repository.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_form/unit_form_bloc.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_form/unit_form_event.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_form/unit_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnitFormScreen extends StatefulWidget {
  const UnitFormScreen({this.unitId, super.key});

  final int? unitId;

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitNameController = TextEditingController();
  UnitType _selectedUnitType = UnitType.department;
  int? _selectedParentId;
  List<UnitEntity> _allUnits = [];

  @override
  void initState() {
    super.initState();
    // Reset form state first
    _resetForm();
    // Reset BLoC state to ensure clean state
    context.read<UnitFormBloc>().add(const UnitFormReset());
    // Load all units first, then initialize form if editing
    _loadAllUnits().then((_) {
      if (widget.unitId != null && mounted) {
        // Load unit data after all units are loaded
        context.read<UnitFormBloc>().add(UnitFormInitialized(widget.unitId));
      }
    });
  }

  @override
  void didUpdateWidget(UnitFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset form if unitId changed
    if (oldWidget.unitId != widget.unitId) {
      _resetForm();
      if (widget.unitId != null) {
        context.read<UnitFormBloc>().add(const UnitFormReset());
        context.read<UnitFormBloc>().add(UnitFormInitialized(widget.unitId));
      } else {
        context.read<UnitFormBloc>().add(const UnitFormReset());
      }
    }
  }

  void _resetForm() {
    _unitNameController.clear();
    _selectedUnitType = UnitType.department;
    _selectedParentId = null;
  }

  @override
  void dispose() {
    _unitNameController.dispose();
    super.dispose();
  }

  Future<void> _loadAllUnits() async {
    try {
      final unitRepository = di.sl<UnitRepository>();
      final units = await unitRepository.getAllUnits();
      if (mounted) {
        setState(() {
          _allUnits = units;
        });
      }
    } catch (e) {
      // Silently fail, parent units are optional
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final dto = UnitRequestDto(
        unitName: _unitNameController.text.trim(),
        unitType: _selectedUnitType,
        parentId: _selectedParentId,
      );
      context.read<UnitFormBloc>().add(
        UnitFormSubmitted(dto: dto, unitId: widget.unitId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coolGray50,
      appBar: AppBar(
        title: Text(widget.unitId == null ? 'Thêm đơn vị' : 'Sửa đơn vị'),
        backgroundColor: AppColors.vkuBlue,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<UnitFormBloc, UnitFormState>(
        listener: (context, state) {
          if (state is UnitFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lưu thành công!'),
                backgroundColor: AppColors.green500,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is UnitFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red500,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is UnitFormLoadSuccess) {
            // Always reset and set values when unit is loaded
            // This ensures we show the correct unit data
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && state.unit.id == widget.unitId) {
                setState(() {
                  _unitNameController.text = state.unit.unitName;
                  _selectedUnitType = state.unit.unitType;
                  // Set parentId - it will be validated in the dropdown builder
                  _selectedParentId = state.unit.parentId;
                });
              }
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is UnitFormLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.spaceLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Thông tin đơn vị',
                            style: AppTextStyles.heading4,
                          ),
                          const SizedBox(height: AppSpacing.spaceLG),
                          TextFormField(
                            controller: _unitNameController,
                            decoration: InputDecoration(
                              labelText: 'Tên đơn vị *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.business_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên đơn vị';
                              }
                              return null;
                            },
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: AppSpacing.spaceMD),
                          DropdownButtonFormField<UnitType>(
                            initialValue: _selectedUnitType,
                            decoration: InputDecoration(
                              labelText: 'Loại đơn vị *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.category_rounded),
                            ),
                            items: UnitType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              );
                            }).toList(),
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedUnitType = value;
                                      });
                                    }
                                  },
                          ),
                          const SizedBox(height: AppSpacing.spaceMD),
                          Builder(
                            builder: (context) {
                              // Filter out current unit and get unique units
                              final availableUnits = _allUnits
                                  .where((u) => u.id != widget.unitId)
                                  .toSet()
                                  .toList();

                              // Ensure selectedParentId exists in items
                              final validParentId =
                                  _selectedParentId != null &&
                                      availableUnits.any(
                                        (u) => u.id == _selectedParentId,
                                      )
                                  ? _selectedParentId
                                  : null;

                              // Update if needed
                              if (validParentId != _selectedParentId) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(() {
                                      _selectedParentId = validParentId;
                                    });
                                  }
                                });
                              }

                              return DropdownButtonFormField<int?>(
                                initialValue: validParentId,
                                decoration: InputDecoration(
                                  labelText: 'Đơn vị cha (tùy chọn)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.account_tree_rounded,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<int?>(
                                    child: Text(
                                      'Không có',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ...availableUnits.map((unit) {
                                    return DropdownMenuItem<int?>(
                                      value: unit.id,
                                      child: Text(
                                        unit.unitName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedParentId = value;
                                        });
                                      },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceLG),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vkuBlue,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              widget.unitId == null ? 'Tạo mới' : 'Cập nhật',
                              style: AppTextStyles.heading5.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
