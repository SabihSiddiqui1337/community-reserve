import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../domain/chat_channel.dart';
import '../domain/chat_message.dart';
import '../domain/dm_thread.dart';

/// Reads/writes community chat: channels, DM threads, and their messages
/// (`communities/{cid}/channels/...` and `communities/{cid}/dms/...`).
class ChatRepository {
  ChatRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _community(String cid) =>
      _db.collection('communities').doc(cid);

  CollectionReference<Map<String, dynamic>> _channels(String cid) =>
      _community(cid).collection('channels');

  CollectionReference<Map<String, dynamic>> _dms(String cid) =>
      _community(cid).collection('dms');

  // ---- Channels ----

  Stream<List<ChatChannel>> watchChannels(String cid) => _channels(cid)
      .orderBy('createdAt')
      .snapshots()
      .map((q) => q.docs
          .map((d) => ChatChannel.fromJson({...d.data(), 'id': d.id}))
          .toList());

  Future<ChatChannel> createChannel(String cid, String name) async {
    final ref = await _channels(cid).add({
      'name': name,
      'isGeneral': false,
      'createdAt': Timestamp.now(),
    });
    final snap = await ref.get();
    return ChatChannel.fromJson({...snap.data()!, 'id': ref.id});
  }

  /// Deletes a channel and its `messages` subcollection. Firestore doesn't
  /// cascade, so we batch-delete the message docs we can read first, then the
  /// channel doc itself.
  Future<void> deleteChannel(String cid, String channelId) async {
    final channelDoc = _channels(cid).doc(channelId);
    final messages = await channelDoc.collection('messages').get();
    for (var i = 0; i < messages.docs.length; i += 400) {
      final batch = _db.batch();
      for (final d in messages.docs.skip(i).take(400)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    await channelDoc.delete();
  }

  // ---- DM threads ----

  Stream<List<DmThread>> watchDmThreads(String cid, String uid) => _dms(cid)
      .where('participantIds', arrayContains: uid)
      .snapshots()
      .map((q) {
        final list = q.docs
            .map((d) => DmThread.fromJson({...d.data(), 'id': d.id}))
            .toList()
          ..sort((a, b) {
            final ax = a.lastAt ?? a.createdAt;
            final bx = b.lastAt ?? b.createdAt;
            if (ax == null && bx == null) return 0;
            if (ax == null) return 1;
            if (bx == null) return -1;
            return bx.compareTo(ax);
          });
        return list;
      });

  /// Find an existing thread matching exactly [participantIds], or create one.
  Future<DmThread> findOrCreateThread(
    String cid, {
    required List<String> participantIds,
    required List<String> participantNames,
  }) async {
    final me = participantIds.first;
    final existing = await _dms(cid)
        .where('participantIds', arrayContains: me)
        .get();
    final wanted = {...participantIds};
    for (final d in existing.docs) {
      final ids = (d.data()['participantIds'] as List?)?.cast<String>() ?? [];
      if (ids.length == wanted.length && wanted.containsAll(ids)) {
        return DmThread.fromJson({...d.data(), 'id': d.id});
      }
    }
    final ref = await _dms(cid).add({
      'participantIds': participantIds,
      'participantNames': participantNames,
      'isGroup': participantIds.length > 2,
      'lastText': '',
      'lastAt': null,
      'createdAt': Timestamp.now(),
    });
    final snap = await ref.get();
    return DmThread.fromJson({...snap.data()!, 'id': ref.id});
  }

  // ---- Messages (shared shape across channels + dms) ----

  CollectionReference<Map<String, dynamic>> _messages(
    String cid,
    ChatTarget target,
  ) =>
      (target.isChannel ? _channels(cid) : _dms(cid))
          .doc(target.id)
          .collection('messages');

  Stream<List<ChatMessage>> watchMessages(String cid, ChatTarget target) =>
      _messages(cid, target)
          .orderBy('createdAt')
          .snapshots()
          .map((q) => q.docs
              .map((d) => ChatMessage.fromJson({...d.data(), 'id': d.id}))
              .toList());

  Future<void> sendMessage(
    String cid,
    ChatTarget target, {
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final now = Timestamp.now();
    await _messages(cid, target).add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': now,
    });
    // Keep DM preview fresh.
    if (!target.isChannel) {
      await _dms(cid).doc(target.id).set(
        {'lastText': text, 'lastAt': now},
        SetOptions(merge: true),
      );
    }
  }
}

/// Identifies a conversation to stream/send within a community: either a
/// channel or a DM thread.
class ChatTarget {
  const ChatTarget.channel(this.id) : isChannel = true;
  const ChatTarget.dm(this.id) : isChannel = false;
  final String id;
  final bool isChannel;
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(firestoreProvider)),
);
