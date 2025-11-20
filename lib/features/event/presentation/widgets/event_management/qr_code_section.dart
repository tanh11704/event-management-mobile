import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeSection extends StatefulWidget {
  const QrCodeSection({
    required this.qrToken,
    required this.eventId,
    super.key,
  });

  final String? qrToken;
  final int eventId;

  @override
  State<QrCodeSection> createState() => _QrCodeSectionState();
}

class _QrCodeSectionState extends State<QrCodeSection> {
  String? _currentQrToken;

  @override
  void initState() {
    super.initState();
    _currentQrToken = widget.qrToken;
  }

  void _refreshQrCode() {
    // TODO: Implement refresh QR code API call
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng làm mới mã QR đang được phát triển'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQrToken == null || _currentQrToken!.isEmpty) {
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
              Text('Chưa có mã QR check-in', style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      );
    }

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mã QR Check-in', style: AppTextStyles.heading3),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _refreshQrCode,
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
            child: QrImageView(
              data: _currentQrToken!,
              size: 250,
              backgroundColor: AppColors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
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
    );
  }
}
