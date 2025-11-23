import 'dart:convert';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/presentation/bloc/event_management/event_management_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_management/event_management_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_management/event_management_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QrCodeSection extends StatefulWidget {
  const QrCodeSection({required this.eventId, super.key});

  final int eventId;

  @override
  State<QrCodeSection> createState() => _QrCodeSectionState();
}

class _QrCodeSectionState extends State<QrCodeSection> {
  @override
  void initState() {
    super.initState();
    // Load QR code when widget initializes
    context.read<EventManagementBloc>().add(
      EventManagementGetQrCheck(eventId: widget.eventId),
    );
  }

  void _refreshQrCode() {
    context.read<EventManagementBloc>().add(
      EventManagementRefreshQrCheck(eventId: widget.eventId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<EventManagementBloc>(),
      child: BlocBuilder<EventManagementBloc, EventManagementState>(
        builder: (context, state) {
          if (state is EventManagementQrCheckLoading && !state.isRefreshing) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coolGray900.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.vkuBlue),
              ),
            );
          }

          if (state is EventManagementQrCheckError) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coolGray900.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.red500,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Text(
                      'Không thể tải mã QR check-in',
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.spaceXM),
                    Text(
                      state.error,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.coolGray500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    ElevatedButton(
                      onPressed: _refreshQrCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vkuBlue,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! EventManagementQrCheckSuccess) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coolGray900.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2_outlined,
                      size: 64,
                      color: AppColors.coolGray500,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Text(
                      'Chưa có mã QR check-in',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          final qrCodeBytes = state.qrCodeBytes;
          final isLoading =
              state is EventManagementQrCheckLoading &&
              (state as EventManagementQrCheckLoading).isRefreshing;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coolGray900.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mã QR Check-in', style: AppTextStyles.heading3),
                        IconButton(
                          icon: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.vkuBlue,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                          onPressed: isLoading ? null : _refreshQrCode,
                          tooltip: 'Làm mới mã',
                          color: AppColors.vkuBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.spaceMD),
                      decoration: BoxDecoration(
                        color: AppColors.coolGray50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildQrCodeImage(qrCodeBytes),
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.spaceMD),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.vkuBlue,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.spaceXM),
                          Expanded(
                            child: Text(
                              'Dùng mã này để quét tại quầy check-in',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.vkuBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrCodeImage(Uint8List bytes) {
    if (bytes.isEmpty) {
      return Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.error_outline, size: 64, color: AppColors.red500),
        ),
      );
    }

    // Trên web, convert bytes thành base64 data URL để tránh lỗi
    if (kIsWeb) {
      final base64String = base64Encode(bytes);
      final dataUrl = 'data:image/png;base64,$base64String';

      return Image.network(
        dataUrl,
        width: 250,
        height: 250,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.red500,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.vkuBlue),
            ),
          );
        },
      );
    }

    // Trên mobile, sử dụng Image.memory trực tiếp
    return Image.memory(
      bytes,
      width: 250,
      height: 250,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.error_outline, size: 64, color: AppColors.red500),
          ),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
    );
  }
}
