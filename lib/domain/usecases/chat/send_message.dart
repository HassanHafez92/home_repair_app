/// Use case for sending a message in a chat.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/chat_entity.dart';
import '../../repositories/i_chat_repository.dart';

class SendMessage implements UseCase<MessageEntity, SendMessageParams> {
  final IChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) async {
    return repository.sendMessage(
      chatId: params.chatId,
      senderId: params.senderId,
      content: params.content,
      type: params.type,
    );
  }
}

class SendMessageParams {
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;

  const SendMessageParams({
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
  });
}
