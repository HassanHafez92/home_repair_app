/// Use case for getting or creating an order chat.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/chat_entity.dart';
import '../../repositories/i_chat_repository.dart';

class GetOrCreateOrderChat
    implements UseCase<ChatEntity, GetOrCreateOrderChatParams> {
  final IChatRepository repository;

  GetOrCreateOrderChat(this.repository);

  @override
  Future<Either<Failure, ChatEntity>> call(
    GetOrCreateOrderChatParams params,
  ) async {
    return repository.getOrCreateOrderChat(params.orderId, params.participants);
  }
}

class GetOrCreateOrderChatParams {
  final String orderId;
  final List<String> participants;

  const GetOrCreateOrderChatParams({
    required this.orderId,
    required this.participants,
  });
}
