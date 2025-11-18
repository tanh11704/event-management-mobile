import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventListErrorState extends StatelessWidget {
  const EventListErrorState({
    required this.error,
    required this.tabIndex,
    super.key,
  });

  final String error;
  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceLG),
                decoration: const BoxDecoration(
                  color: AppColors.red100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.red500,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLG),
              Text('Đã xảy ra lỗi', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.spaceXS),
              Text(
                error,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spaceLG),
              ElevatedButton.icon(
                onPressed: () {
                  final isManaged = tabIndex == 1;
                  context.read<EventListBloc>().add(
                    EventListRefresh(isManaged: isManaged),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vkuBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceLG,
                    vertical: AppSpacing.spaceMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
