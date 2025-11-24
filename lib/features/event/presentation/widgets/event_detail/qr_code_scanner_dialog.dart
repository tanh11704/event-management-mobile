import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_bloc.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_state.dart';
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
    // Reset processing state khi dispose
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

    // Timeout protection
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
        qrCode = await _decodeQrFromBytesWeb(bytes);
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

      // Gọi _handleQrCode - nó sẽ tự set _isProcessing = true
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

  Future<String?> _decodeQrFromBytesWeb(Uint8List bytes) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final img = html.ImageElement();
      final completer = Completer<String?>();

      img.onLoad.listen((_) {
        try {
          final canvas = html.CanvasElement(
            width: img.width,
            height: img.height,
          );
          final ctx = canvas.context2D;
          ctx.drawImage(img, 0, 0);

          // Lấy ImageData từ canvas
          final imageData = ctx.getImageData(
            0,
            0,
            canvas.width!,
            canvas.height!,
          );

          final qrCode = _callJsQRWithImageData(imageData);

          html.Url.revokeObjectUrl(url);
          completer.complete(qrCode);
        } catch (e) {
          html.Url.revokeObjectUrl(url);
          completer.complete(null);
        }
      });

      img.onError.listen((_) {
        html.Url.revokeObjectUrl(url);
        completer.complete(null);
      });

      img.src = url;

      return completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          html.Url.revokeObjectUrl(url);
          return null;
        },
      );
    } catch (e) {
      return null;
    }
  }

  /// Gọi jsQR với ImageData object trực tiếp (cách đơn giản nhất)
  String? _callJsQRWithImageData(html.ImageData imageData) {
    try {
      // Truy cập jsQR trực tiếp từ global context
      final jsQRFunction = js.context['jsQR'];

      if (jsQRFunction == null) {
        return null;
      }

      // jsQR API: jsQR(data, width, height, options?)
      // ImageData đã có sẵn data, width, height
      // Truyền ImageData object trực tiếp (nó là JavaScript object)
      try {
        // Cách 1: Truyền ImageData object trực tiếp
        final result = jsQRFunction.apply([imageData]);
        if (result != null && result != js.context['undefined']) {
          final dataProperty = result['data'];
          if (dataProperty != null && dataProperty != js.context['undefined']) {
            final qrText = dataProperty.toString();
            return qrText;
          }
        }
      } catch (e1) {
        // Cách 2: Truyền data, width, height riêng biệt
        try {
          final result = jsQRFunction.apply([
            imageData.data,
            imageData.width,
            imageData.height,
          ]);
          if (result != null && result != js.context['undefined']) {
            final dataProperty = result['data'];
            if (dataProperty != null &&
                dataProperty != js.context['undefined']) {
              var qrText = dataProperty.toString();

              // Clean up: Loại bỏ phần thừa nếu có
              // Kết quả có thể có format: "/api/v1/attendants/check-in/token extra text"
              qrText = qrText.trim();

              // Nếu có khoảng trắng, chỉ lấy phần đầu tiên (URL/path)
              if (qrText.contains(' ')) {
                final parts = qrText.split(' ');
                qrText = parts.first.trim();
              }

              // Đảm bảo không có ký tự xuống dòng
              qrText = qrText
                  .replaceAll('\n', '')
                  .replaceAll('\r', '')
                  .replaceAll('\t', '')
                  .trim();

              return qrText;
            }
          }
        } catch (e2) {
          // Method 2 failed, continue
        }
      }

      return null;
    } catch (e) {
      return null;
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
          // Đang xử lý check-in, đảm bảo loading state được set
          if (mounted) {
            setState(() {
              _isProcessing = true;
              _errorMessage = null;
            });
          }
        } else if (state is EventDetailCheckInSuccess) {
          // Check-in thành công, đóng dialog scanner
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
            Navigator.of(context).pop();
            // Dialog thành công sẽ được hiển thị ở event_detail_screen
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
