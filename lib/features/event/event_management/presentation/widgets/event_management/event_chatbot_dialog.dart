import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:event_management/features/event/shared/data/models/chat_request.dart';
import 'package:event_management/features/event/shared/data/models/chat_sender.dart';
import 'package:event_management/features/event/shared/data/models/message_dto.dart';
import 'package:event_management/features/event/shared/domain/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class EventChatbotDialog extends StatefulWidget {
  const EventChatbotDialog({required this.eventId, super.key});

  final int eventId;

  @override
  State<EventChatbotDialog> createState() => _EventChatbotDialogState();
}

class _EventChatbotDialogState extends State<EventChatbotDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final EventRepository _repository = di.sl<EventRepository>();

  List<MessageDto> _messages = [];
  bool _isLoading = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await _repository.getChatHistory(widget.eventId);
      if (mounted) {
        setState(() {
          _messages = history;
          _isLoadingHistory = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải lịch sử chat: $e'),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // Add user message to UI immediately
    final userMessage = MessageDto(
      id: DateTime.now().millisecondsSinceEpoch,
      sender: ChatSender.user,
      content: message,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final request = ChatRequest(eventId: widget.eventId, message: message);

      final response = await _repository.sendChatMessage(request);

      // Add bot response to UI
      final botMessage = MessageDto(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        sender: ChatSender.bot,
        content: response.response,
        timestamp: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _messages.add(botMessage);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Remove user message if failed
          _messages.removeLast();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi tin nhắn: $e'),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final availableHeight = mediaQuery.size.height - keyboardHeight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: availableHeight * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              decoration: const BoxDecoration(
                color: AppColors.vkuBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trợ lý AI',
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hỏi đáp về sự kiện - Lịch trình, địa điểm, diễn giả...',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: _isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: AppColors.coolGray500,
                          ),
                          const SizedBox(height: AppSpacing.spaceMD),
                          Text(
                            'Chưa có tin nhắn nào',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.coolGray500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceXS),
                          Text(
                            'Hãy bắt đầu cuộc trò chuyện!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.coolGray500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.spaceMD),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          // Loading indicator for bot response
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 60,
                              top: AppSpacing.spaceMD,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.vkuBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.smart_toy_rounded,
                                    color: AppColors.vkuBlue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.spaceXS),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final message = _messages[index];
                        final isUser = message.sender == ChatSender.user;

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.spaceMD,
                          ),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.vkuBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.smart_toy_rounded,
                                    color: AppColors.vkuBlue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.spaceXS),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.spaceMD,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? AppColors.vkuBlue
                                        : AppColors.coolGray50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: isUser
                                      ? Text(
                                          message.content,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(color: AppColors.white),
                                        )
                                      : MarkdownBody(
                                          data: message.content,
                                          styleSheet: MarkdownStyleSheet(
                                            p: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.coolGray900,
                                                ),
                                            h1: AppTextStyles.heading3.copyWith(
                                              color: AppColors.coolGray900,
                                            ),
                                            h2: AppTextStyles.heading4.copyWith(
                                              color: AppColors.coolGray900,
                                            ),
                                            h3: AppTextStyles.heading5.copyWith(
                                              color: AppColors.coolGray900,
                                            ),
                                            strong: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.coolGray900,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            em: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.coolGray900,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                            code: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.vkuBlue,
                                                  backgroundColor:
                                                      AppColors.coolGray50,
                                                  fontFamily: 'monospace',
                                                ),
                                            codeblockDecoration: BoxDecoration(
                                              color: AppColors.coolGray50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            listBullet: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.coolGray900,
                                                ),
                                            blockquote: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: AppColors.coolGray700,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                            blockquoteDecoration:
                                                const BoxDecoration(
                                                  color: AppColors.coolGray50,
                                                  border: Border(
                                                    left: BorderSide(
                                                      color: AppColors.vkuBlue,
                                                      width: 4,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: AppSpacing.spaceXS),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.coolGray50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.coolGray700,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Input area
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.coolGray50,
                border: Border(
                  top: BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.vkuBlue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spaceMD,
                          vertical: AppSpacing.spaceMD,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceXS),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.vkuBlue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: AppColors.white,
                            ),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
