import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_summary.freezed.dart';
part 'community_summary.g.dart';

/// Public, minimal community info used by the join flow (`communityDirectory/`).
/// Readable before joining — deliberately excludes settings/branding internals
/// so multi-tenant isolation isn't leaked during discovery.
@freezed
abstract class CommunitySummary with _$CommunitySummary {
  const factory CommunitySummary({
    required String id,
    required String name,
    @Default('') String street,
    @Default('') String city,
    @Default('') String state,
    @Default('') String zip,
    String? logoUrl,
    @Default('') String joinCode,
    @Default('#5B8DEF') String primaryColor,
  }) = _CommunitySummary;

  factory CommunitySummary.fromJson(Map<String, dynamic> json) =>
      _$CommunitySummaryFromJson(json);
}
