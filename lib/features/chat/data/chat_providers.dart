import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/chat_channel.dart';
import '../domain/chat_message.dart';
import '../domain/dm_thread.dart';
import 'chat_repository.dart';

/// Channels for the active community.
final channelsProvider = StreamProvider<List<ChatChannel>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).watchChannels(cid);
});

/// The signed-in user's DM threads in the active community.
final dmThreadsProvider = StreamProvider<List<DmThread>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  final uid = ref.watch(currentUidProvider);
  if (cid == null || uid == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).watchDmThreads(cid, uid);
});

/// When the resident last opened community chat (in-memory). Defaults to the
/// epoch so any existing message reads as unread until they open it once.
class ChatLastOpened extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.fromMillisecondsSinceEpoch(0);

  /// Mark everything up to now as read (clears the unread dot).
  void markRead() => state = DateTime.now();
}

final chatLastOpenedProvider =
    NotifierProvider<ChatLastOpened, DateTime>(ChatLastOpened.new);

/// True when any channel/DM has activity newer than the last time chat was
/// opened — drives the green dot on the chat button.
final chatHasUnreadProvider = Provider<bool>((ref) {
  final lastOpened = ref.watch(chatLastOpenedProvider);
  final channels = ref.watch(channelsProvider).value ?? const <ChatChannel>[];
  final dms = ref.watch(dmThreadsProvider).value ?? const <DmThread>[];
  DateTime? latest;
  for (final at in [
    ...channels.map((c) => c.lastAt),
    ...dms.map((d) => d.lastAt),
  ]) {
    if (at != null && (latest == null || at.isAfter(latest))) latest = at;
  }
  return latest != null && latest.isAfter(lastOpened);
});

/// Messages for a given conversation target (channel or DM).
final messagesProvider =
    StreamProvider.family<List<ChatMessage>, ChatTarget>((ref, target) {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).watchMessages(cid, target);
});

/// A community member, enriched with a display name from `users/{uid}`.
class ChatMember {
  const ChatMember({required this.uid, required this.name, required this.unit});
  final String uid;
  final String name;
  final String unit;
}

/// Enrolled members of the active community (membership ⨝ user profile), for
/// the DM member picker. Only members of the active community are listed.
final chatMembersProvider = FutureProvider<List<ChatMember>>((ref) async {
  final cid = ref.watch(currentCommunityIdProvider);
  if (cid == null) return const [];
  final db = ref.watch(firestoreProvider);

  final memberships = await db
      .collection('communities')
      .doc(cid)
      .collection('memberships')
      .get();

  final out = <ChatMember>[];
  for (final m in memberships.docs) {
    final uid = (m.data()['userId'] as String?) ?? m.id;
    final unit = (m.data()['unit'] as String?) ?? '';
    final userSnap = await db.collection('users').doc(uid).get();
    final name = (userSnap.data()?['name'] as String?)?.trim();
    out.add(ChatMember(
      uid: uid,
      name: (name != null && name.isNotEmpty) ? name : 'Member',
      unit: unit,
    ));
  }
  out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return out;
});
