import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class EditEventHtmlEditor extends StatefulWidget {
  const EditEventHtmlEditor({
    required this.initialValue,
    required this.onChanged,
    this.validator,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  @override
  State<EditEventHtmlEditor> createState() => _EditEventHtmlEditorState();
}

class _EditEventHtmlEditorState extends State<EditEventHtmlEditor> {
  late HtmlEditorController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = HtmlEditorController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> validate() async {
    final text = await _controller.getText();
    if (widget.validator != null) {
      final error = widget.validator!(text);
      setState(() {
        _errorText = error;
      });
      return error;
    }
    return null;
  }

  Future<String> getText() async {
    return _controller.getText();
  }

  void _notifyChanged() {
    _controller.getText().then((text) {
      widget.onChanged(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _errorText != null ? AppColors.red500 : AppColors.border,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: HtmlEditor(
              controller: _controller,
              htmlEditorOptions: HtmlEditorOptions(
                hint: 'Nhập mô tả sự kiện...',
                shouldEnsureVisible: true,
                initialText: widget.initialValue,
              ),
              htmlToolbarOptions: HtmlToolbarOptions(
                defaultToolbarButtons: [
                  const StyleButtons(),
                  const FontSettingButtons(
                    fontName: false,
                    fontSizeUnit: false,
                  ),
                  const ListButtons(listStyles: false),
                  const InsertButtons(
                    video: false,
                    audio: false,
                    table: false,
                    hr: false,
                  ),
                ],
                buttonColor: AppColors.coolGray700,
                buttonSelectedColor: AppColors.vkuBlue,
                buttonFillColor: AppColors.white,
                dropdownBackgroundColor: AppColors.white,
                dropdownIconColor: AppColors.coolGray700,
                textStyle: AppTextStyles.bodyMedium,
              ),
              otherOptions: OtherOptions(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              callbacks: Callbacks(
                onInit: () async {
                  // Đợi editor khởi tạo hoàn toàn trước khi setText
                  await Future<void>.delayed(const Duration(milliseconds: 500));
                  if (mounted) {
                    _controller.setText(widget.initialValue);
                  }
                },
                onFocus: _notifyChanged,
                onBlur: _notifyChanged,
                // Note: Image upload via onImageUpload callback requires
                // FileUpload type which is not available in this version.
                // Users can paste image URLs or use external image hosting.
              ),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              _errorText!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.red500),
            ),
          ),
        ],
      ],
    );
  }
}
