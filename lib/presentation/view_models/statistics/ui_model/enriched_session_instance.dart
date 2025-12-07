import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

part 'enriched_session_instance.freezed.dart';

@freezed
abstract class EnrichedSessionInstance with _$EnrichedSessionInstance {
  const factory EnrichedSessionInstance({
    required SessionInstanceModel instance,
    required String sessionName,
  }) = _EnrichtedSessionInstance;
}
