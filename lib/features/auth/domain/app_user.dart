import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Global user profile (`users/{uid}`). Tenant-specific role/residency live on
/// the per-community membership, not here.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    @Default('') String name,
    @Default('') String email,
    @Default('') String phone,
    String? photoUrl,
    @Default(<String>[]) List<String> fcmTokens,
    @Default('resident') String globalRole, // resident | superAdmin
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
