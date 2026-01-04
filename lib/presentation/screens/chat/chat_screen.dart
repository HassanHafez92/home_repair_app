import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:home_repair_app/models/message_model.dart';
import 'package:home_repair_app/services/chat_service.dart';
import '../../helpers/auth_helper.dart';
import '../../widgets/full_screen_image_view.dart';
import '../../theme/design_tokens.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  bool _isSending = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final userId = context.userId;
    if (userId != null) {
      _chatService.markMessagesAsRead(widget.chatId, userId);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = context.userId;
    if (userId == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final message = MessageModel(
        id: const Uuid().v4(),
        senderId: userId,
        text: text,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );

      await _chatService.sendMessage(widget.chatId, message);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('failedToSendMessage'.tr())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      if (!mounted) return;

      setState(() => _isUploading = true);

      final userId = context.userId;
      if (userId == null) return;

      final imageUrl = await _chatService.uploadChatImage(
        File(pickedFile.path),
        widget.chatId,
      );

      final message = MessageModel(
        id: const Uuid().v4(),
        senderId: userId,
        text: imageUrl,
        timestamp: DateTime.now(),
        type: MessageType.image,
      );

      await _chatService.sendMessage(widget.chatId, message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('failedToUploadImage'.tr())));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXL),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DesignTokens.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: DesignTokens.spaceLG),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: DesignTokens.primaryBlue,
                  ),
                ),
                title: Text(
                  'camera'.tr(),
                  style: const TextStyle(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: DesignTokens.primaryBlue,
                  ),
                ),
                title: Text(
                  'gallery'.tr(),
                  style: const TextStyle(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.userId;

    if (userId == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: DesignTokens.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DesignTokens.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignTokens.primaryBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  widget.otherUserName.isNotEmpty
                      ? widget.otherUserName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: DesignTokens.fontWeightBold,
                    fontSize: DesignTokens.fontSizeMD,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: TextStyle(
                    color: DesignTokens.neutral900,
                    fontWeight: DesignTokens.fontWeightBold,
                    fontSize: DesignTokens.fontSizeMD,
                  ),
                ),
                Text(
                  'online'.tr(),
                  style: TextStyle(
                    color: DesignTokens.accentGreen,
                    fontSize: DesignTokens.fontSizeXS,
                    fontWeight: DesignTokens.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.streamMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: DesignTokens.neutral300,
                        ),
                        const SizedBox(height: DesignTokens.spaceMD),
                        Text(
                          'startConversation'.tr(),
                          style: TextStyle(color: DesignTokens.neutral500),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(DesignTokens.spaceMD),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == userId;
                    final showDate =
                        index == messages.length - 1 ||
                        !_isSameDay(
                          message.timestamp,
                          messages[index + 1].timestamp,
                        );

                    return Column(
                      children: [
                        if (showDate) _DateSeparator(date: message.timestamp),
                        _MessageBubble(message: message, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceMD),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  Container(
                    decoration: BoxDecoration(
                      color: DesignTokens.neutral100,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSM,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _isUploading ? null : _showAttachmentOptions,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.attach_file,
                              color: DesignTokens.neutral600,
                            ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSM),
                  // Text field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: DesignTokens.neutral100,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusLG,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'typeMessage'.tr(),
                          hintStyle: TextStyle(color: DesignTokens.neutral400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spaceMD,
                            vertical: DesignTokens.spaceSM,
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSM),
                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryBlue,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSM,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Date separator widget
class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final text = isToday ? 'today'.tr() : DateFormat.yMMMd().format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceMD),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMD,
          vertical: DesignTokens.spaceXS,
        ),
        decoration: BoxDecoration(
          color: DesignTokens.neutral200,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: DesignTokens.neutral600,
            fontSize: DesignTokens.fontSizeXS,
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// House Maintenance style message bubble
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.spaceSM),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMD,
          vertical: DesignTokens.spaceSM,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? DesignTokens.primaryBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(DesignTokens.radiusLG),
            topRight: const Radius.circular(DesignTokens.radiusLG),
            bottomLeft: isMe
                ? const Radius.circular(DesignTokens.radiusLG)
                : Radius.zero,
            bottomRight: isMe
                ? Radius.zero
                : const Radius.circular(DesignTokens.radiusLG),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.type == MessageType.image)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FullScreenImageView(imageUrl: message.text),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  child: CachedNetworkImage(
                    imageUrl: message.text,
                    placeholder: (context, url) => const SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : DesignTokens.neutral900,
                  fontSize: DesignTokens.fontSizeBase,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat.jm().format(message.timestamp),
              style: TextStyle(
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : DesignTokens.neutral400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
