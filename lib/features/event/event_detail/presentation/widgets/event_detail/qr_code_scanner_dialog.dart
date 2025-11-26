import 'dart:async';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_bloc.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_event.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_state.dart';
import 'package:event_management/features/event/event_detail/presentation/widgets/event_detail/qr_code_web_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScannerDialog extends StatefulWidget {
  const QrCodeScannerDialog({super.key});

  @override
  State<QrCodeScannerDialog> createState() => _QrCodeScannerDialogState();
}

class _QrCodeScannerDialogState extends State<QrCodeScannerDialog> {
  final MobileScannerController _cameraController = MobileScannerController();
  final TextEditingController _tokenController = TextEditingController();
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cameraController.dispose();
    _tokenController.dispose();
    _isProcessing = false;
    super.dispose();
  }

  Future<void> _handleQrCode(String qrCode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      context.read<EventDetailBloc>().add(EventDetailCheckIn(qrCode: qrCode));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Lỗi khi xử lý mã QR. Vui lòng thử lại.';
        });
      }
      return;
    }

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isProcessing) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Thời gian xử lý quá lâu. Vui lòng thử lại.';
        });
      }
    });
  }

  Future<void> _pickImageAndDecode() async {
    if (_isProcessing) return;

    setState(() {
      _errorMessage = null;
    });

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        return;
      }

      String? qrCode;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        qrCode = await decodeQrFromBytesWeb(bytes);
      } else {
        final result = await _cameraController.analyzeImage(image.path);
        if (result != null && result.barcodes.isNotEmpty) {
          qrCode = result.barcodes.first.rawValue;
        }
      }

      if (qrCode == null || qrCode.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Không tìm thấy mã QR trong ảnh.';
          });
        }
        return;
      }

      var cleanQrCode = qrCode.trim();
      if (cleanQrCode.contains(' ')) {
        cleanQrCode = cleanQrCode.split(' ').first.trim();
      }
      cleanQrCode = cleanQrCode
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll('\t', '')
          .trim();

      if (cleanQrCode.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Mã QR không hợp lệ.';
          });
        }
        return;
      }

      await _handleQrCode(cleanQrCode);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _handleManualToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập mã token.';
      });
      return;
    }

    await _handleQrCode(token);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventDetailBloc, EventDetailState>(
      listener: (context, state) {
        if (state is EventDetailCheckInChecking) {
          if (mounted) {
            setState(() {
              _isProcessing = true;
              _errorMessage = null;
            });
          }
        } else if (state is EventDetailCheckInSuccess) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
            Navigator.of(context).pop();
          }
        } else if (state is EventDetailCheckInFailure) {
          // Check-in thất bại, hiển thị lỗi và reset loading
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _errorMessage = state.error;
            });
          }
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(AppSpacing.spaceXL),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quét mã QR check-in', style: AppTextStyles.heading3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // Reset state trước khi đóng
                      setState(() {
                        _isProcessing = false;
                        _errorMessage = null;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceLG),
              if (kIsWeb) _buildWebView() else _buildMobileView(),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.spaceMD),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.spaceMD),
                  decoration: BoxDecoration(
                    color: AppColors.red100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.red500),
                      const SizedBox(width: AppSpacing.spaceMD),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.red500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.coolGray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: AppColors.coolGray500,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceLG),
        TextField(
          controller: _tokenController,
          decoration: InputDecoration(
            labelText: 'Nhập mã token check-in',
            hintText: 'Dán token từ QR code',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.qr_code),
          ),
          enabled: !_isProcessing,
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _handleManualToken,
          icon: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle),
          label: const Text('Check-in'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.vkuBlue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceXL,
              vertical: AppSpacing.spaceMD,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        Text(
          'Hoặc tải ảnh QR code lên (tính năng đang phát triển)',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.coolGray500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        OutlinedButton.icon(
          onPressed: _isProcessing ? null : _pickImageAndDecode,
          icon: const Icon(Icons.upload_file),
          label: const Text('Tải ảnh QR code'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceXL,
              vertical: AppSpacing.spaceMD,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: _isProcessing
              ? const Center(child: CircularProgressIndicator())
              : MobileScanner(
                  controller: _cameraController,
                  onDetect: (BarcodeCapture capture) {
                    final barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _handleQrCode(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
        ),
        const SizedBox(height: AppSpacing.spaceLG),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _pickImageAndDecode,
          icon: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library),
          label: const Text('Chọn ảnh từ thư viện'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.vkuBlue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceXL,
              vertical: AppSpacing.spaceMD,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
