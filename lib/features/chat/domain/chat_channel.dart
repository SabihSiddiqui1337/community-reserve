import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'chat_channel.freezed.dart';
part 'chat_channel.g.dart';

/// A community chat channel (`communities/{cid}/channels/{channelId}`).
/// Channels are admin-created; the `isGeneral` flag marks the default room.
@freezed
abstract class ChatChannel with _$ChatChannel {
  const factory ChatChannel({
    required String id,
    @Default('') String name,
    @Default(false) bool isGeneral,
    @TimestampConverter() DateTime? createdAt,
  }) = _ChatChannel;

  factory ChatChannel.fromJson(Map<String, dynamic> json) =>
      _$ChatChannelFromJson(json);
}
