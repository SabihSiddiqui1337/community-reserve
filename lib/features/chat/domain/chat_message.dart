import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// A single message in a channel or DM thread
/// (`.../messages/{msgId}`). Same shape for channels and DMs.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    @Default('') String senderId,
    @Default('') String senderName,
    @Default('') String text,
    @TimestampConverter() DateTime? createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
