import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'dm_thread.freezed.dart';
part 'dm_thread.g.dart';

/// A direct-message thread (`communities/{cid}/dms/{dmId}`). May be 1:1 or a
/// group; `participantIds` drives access and `participantNames` is denormalized
/// for display. `lastText`/`lastAt` preview the most recent message.
@freezed
abstract class DmThread with _$DmThread {
  const factory DmThread({
    required String id,
    @Default(<String>[]) List<String> participantIds,
    @Default(<String>[]) List<String> participantNames,
    @Default(false) bool isGroup,
    @Default('') String lastText,
    @TimestampConverter() DateTime? lastAt,
    @TimestampConverter() DateTime? createdAt,
  }) = _DmThread;

  factory DmThread.fromJson(Map<String, dynamic> json) =>
      _$DmThreadFromJson(json);
}

extension DmThreadX on DmThread {
  /// Names of the other participants (excludes [me]), for the row title.
  List<String> otherNames(String me) {
    final out = <String>[];
    for (var i = 0; i < participantIds.length; i++) {
      if (participantIds[i] == me) continue;
      out.add(i < participantNames.length ? participantNames[i] : 'Member');
    }
    return out.isEmpty ? participantNames : out;
  }

  /// Comma-joined display title from the perspective of [me].
  String title(String me) => otherNames(me).join(', ');
}
