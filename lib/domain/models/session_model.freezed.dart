// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionModel {

 String? get id; String get title; bool get isRepeating; DateTime? get startDate; DateTime? get endDate; List<int> get selectedDays; List<String> get learningStrategies; bool get isPomodoro; int? get totalTimeMin; int? get focusTimeMin; int? get breakTimeMin; int? get longBreakTimeMin; int? get cyclesBeforeLongBreak; bool get hasFocusPrompt; bool get hasMoodPrompt; bool get hasFreetextPrompt; DateTime? get createdAt;
/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionModelCopyWith<SessionModel> get copyWith => _$SessionModelCopyWithImpl<SessionModel>(this as SessionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isRepeating, isRepeating) || other.isRepeating == isRepeating)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.selectedDays, selectedDays)&&const DeepCollectionEquality().equals(other.learningStrategies, learningStrategies)&&(identical(other.isPomodoro, isPomodoro) || other.isPomodoro == isPomodoro)&&(identical(other.totalTimeMin, totalTimeMin) || other.totalTimeMin == totalTimeMin)&&(identical(other.focusTimeMin, focusTimeMin) || other.focusTimeMin == focusTimeMin)&&(identical(other.breakTimeMin, breakTimeMin) || other.breakTimeMin == breakTimeMin)&&(identical(other.longBreakTimeMin, longBreakTimeMin) || other.longBreakTimeMin == longBreakTimeMin)&&(identical(other.cyclesBeforeLongBreak, cyclesBeforeLongBreak) || other.cyclesBeforeLongBreak == cyclesBeforeLongBreak)&&(identical(other.hasFocusPrompt, hasFocusPrompt) || other.hasFocusPrompt == hasFocusPrompt)&&(identical(other.hasMoodPrompt, hasMoodPrompt) || other.hasMoodPrompt == hasMoodPrompt)&&(identical(other.hasFreetextPrompt, hasFreetextPrompt) || other.hasFreetextPrompt == hasFreetextPrompt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,isRepeating,startDate,endDate,const DeepCollectionEquality().hash(selectedDays),const DeepCollectionEquality().hash(learningStrategies),isPomodoro,totalTimeMin,focusTimeMin,breakTimeMin,longBreakTimeMin,cyclesBeforeLongBreak,hasFocusPrompt,hasMoodPrompt,hasFreetextPrompt,createdAt);

@override
String toString() {
  return 'SessionModel(id: $id, title: $title, isRepeating: $isRepeating, startDate: $startDate, endDate: $endDate, selectedDays: $selectedDays, learningStrategies: $learningStrategies, isPomodoro: $isPomodoro, totalTimeMin: $totalTimeMin, focusTimeMin: $focusTimeMin, breakTimeMin: $breakTimeMin, longBreakTimeMin: $longBreakTimeMin, cyclesBeforeLongBreak: $cyclesBeforeLongBreak, hasFocusPrompt: $hasFocusPrompt, hasMoodPrompt: $hasMoodPrompt, hasFreetextPrompt: $hasFreetextPrompt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SessionModelCopyWith<$Res>  {
  factory $SessionModelCopyWith(SessionModel value, $Res Function(SessionModel) _then) = _$SessionModelCopyWithImpl;
@useResult
$Res call({
 String? id, String title, bool isRepeating, DateTime? startDate, DateTime? endDate, List<int> selectedDays, List<String> learningStrategies, bool isPomodoro, int? totalTimeMin, int? focusTimeMin, int? breakTimeMin, int? longBreakTimeMin, int? cyclesBeforeLongBreak, bool hasFocusPrompt, bool hasMoodPrompt, bool hasFreetextPrompt, DateTime? createdAt
});




}
/// @nodoc
class _$SessionModelCopyWithImpl<$Res>
    implements $SessionModelCopyWith<$Res> {
  _$SessionModelCopyWithImpl(this._self, this._then);

  final SessionModel _self;
  final $Res Function(SessionModel) _then;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? isRepeating = null,Object? startDate = freezed,Object? endDate = freezed,Object? selectedDays = null,Object? learningStrategies = null,Object? isPomodoro = null,Object? totalTimeMin = freezed,Object? focusTimeMin = freezed,Object? breakTimeMin = freezed,Object? longBreakTimeMin = freezed,Object? cyclesBeforeLongBreak = freezed,Object? hasFocusPrompt = null,Object? hasMoodPrompt = null,Object? hasFreetextPrompt = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isRepeating: null == isRepeating ? _self.isRepeating : isRepeating // ignore: cast_nullable_to_non_nullable
as bool,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,selectedDays: null == selectedDays ? _self.selectedDays : selectedDays // ignore: cast_nullable_to_non_nullable
as List<int>,learningStrategies: null == learningStrategies ? _self.learningStrategies : learningStrategies // ignore: cast_nullable_to_non_nullable
as List<String>,isPomodoro: null == isPomodoro ? _self.isPomodoro : isPomodoro // ignore: cast_nullable_to_non_nullable
as bool,totalTimeMin: freezed == totalTimeMin ? _self.totalTimeMin : totalTimeMin // ignore: cast_nullable_to_non_nullable
as int?,focusTimeMin: freezed == focusTimeMin ? _self.focusTimeMin : focusTimeMin // ignore: cast_nullable_to_non_nullable
as int?,breakTimeMin: freezed == breakTimeMin ? _self.breakTimeMin : breakTimeMin // ignore: cast_nullable_to_non_nullable
as int?,longBreakTimeMin: freezed == longBreakTimeMin ? _self.longBreakTimeMin : longBreakTimeMin // ignore: cast_nullable_to_non_nullable
as int?,cyclesBeforeLongBreak: freezed == cyclesBeforeLongBreak ? _self.cyclesBeforeLongBreak : cyclesBeforeLongBreak // ignore: cast_nullable_to_non_nullable
as int?,hasFocusPrompt: null == hasFocusPrompt ? _self.hasFocusPrompt : hasFocusPrompt // ignore: cast_nullable_to_non_nullable
as bool,hasMoodPrompt: null == hasMoodPrompt ? _self.hasMoodPrompt : hasMoodPrompt // ignore: cast_nullable_to_non_nullable
as bool,hasFreetextPrompt: null == hasFreetextPrompt ? _self.hasFreetextPrompt : hasFreetextPrompt // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionModel].
extension SessionModelPatterns on SessionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  bool isRepeating,  DateTime? startDate,  DateTime? endDate,  List<int> selectedDays,  List<String> learningStrategies,  bool isPomodoro,  int? totalTimeMin,  int? focusTimeMin,  int? breakTimeMin,  int? longBreakTimeMin,  int? cyclesBeforeLongBreak,  bool hasFocusPrompt,  bool hasMoodPrompt,  bool hasFreetextPrompt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that.id,_that.title,_that.isRepeating,_that.startDate,_that.endDate,_that.selectedDays,_that.learningStrategies,_that.isPomodoro,_that.totalTimeMin,_that.focusTimeMin,_that.breakTimeMin,_that.longBreakTimeMin,_that.cyclesBeforeLongBreak,_that.hasFocusPrompt,_that.hasMoodPrompt,_that.hasFreetextPrompt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  bool isRepeating,  DateTime? startDate,  DateTime? endDate,  List<int> selectedDays,  List<String> learningStrategies,  bool isPomodoro,  int? totalTimeMin,  int? focusTimeMin,  int? breakTimeMin,  int? longBreakTimeMin,  int? cyclesBeforeLongBreak,  bool hasFocusPrompt,  bool hasMoodPrompt,  bool hasFreetextPrompt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SessionModel():
return $default(_that.id,_that.title,_that.isRepeating,_that.startDate,_that.endDate,_that.selectedDays,_that.learningStrategies,_that.isPomodoro,_that.totalTimeMin,_that.focusTimeMin,_that.breakTimeMin,_that.longBreakTimeMin,_that.cyclesBeforeLongBreak,_that.hasFocusPrompt,_that.hasMoodPrompt,_that.hasFreetextPrompt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  bool isRepeating,  DateTime? startDate,  DateTime? endDate,  List<int> selectedDays,  List<String> learningStrategies,  bool isPomodoro,  int? totalTimeMin,  int? focusTimeMin,  int? breakTimeMin,  int? longBreakTimeMin,  int? cyclesBeforeLongBreak,  bool hasFocusPrompt,  bool hasMoodPrompt,  bool hasFreetextPrompt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that.id,_that.title,_that.isRepeating,_that.startDate,_that.endDate,_that.selectedDays,_that.learningStrategies,_that.isPomodoro,_that.totalTimeMin,_that.focusTimeMin,_that.breakTimeMin,_that.longBreakTimeMin,_that.cyclesBeforeLongBreak,_that.hasFocusPrompt,_that.hasMoodPrompt,_that.hasFreetextPrompt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _SessionModel extends SessionModel {
  const _SessionModel({this.id, required this.title, this.isRepeating = false, this.startDate, this.endDate, final  List<int> selectedDays = const <int>[], final  List<String> learningStrategies = const <String>[], this.isPomodoro = true, this.totalTimeMin, this.focusTimeMin, this.breakTimeMin, this.longBreakTimeMin, this.cyclesBeforeLongBreak, this.hasFocusPrompt = true, this.hasMoodPrompt = true, this.hasFreetextPrompt = true, this.createdAt}): _selectedDays = selectedDays,_learningStrategies = learningStrategies,super._();
  

@override final  String? id;
@override final  String title;
@override@JsonKey() final  bool isRepeating;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<int> _selectedDays;
@override@JsonKey() List<int> get selectedDays {
  if (_selectedDays is EqualUnmodifiableListView) return _selectedDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedDays);
}

 final  List<String> _learningStrategies;
@override@JsonKey() List<String> get learningStrategies {
  if (_learningStrategies is EqualUnmodifiableListView) return _learningStrategies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_learningStrategies);
}

@override@JsonKey() final  bool isPomodoro;
@override final  int? totalTimeMin;
@override final  int? focusTimeMin;
@override final  int? breakTimeMin;
@override final  int? longBreakTimeMin;
@override final  int? cyclesBeforeLongBreak;
@override@JsonKey() final  bool hasFocusPrompt;
@override@JsonKey() final  bool hasMoodPrompt;
@override@JsonKey() final  bool hasFreetextPrompt;
@override final  DateTime? createdAt;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionModelCopyWith<_SessionModel> get copyWith => __$SessionModelCopyWithImpl<_SessionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isRepeating, isRepeating) || other.isRepeating == isRepeating)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._selectedDays, _selectedDays)&&const DeepCollectionEquality().equals(other._learningStrategies, _learningStrategies)&&(identical(other.isPomodoro, isPomodoro) || other.isPomodoro == isPomodoro)&&(identical(other.totalTimeMin, totalTimeMin) || other.totalTimeMin == totalTimeMin)&&(identical(other.focusTimeMin, focusTimeMin) || other.focusTimeMin == focusTimeMin)&&(identical(other.breakTimeMin, breakTimeMin) || other.breakTimeMin == breakTimeMin)&&(identical(other.longBreakTimeMin, longBreakTimeMin) || other.longBreakTimeMin == longBreakTimeMin)&&(identical(other.cyclesBeforeLongBreak, cyclesBeforeLongBreak) || other.cyclesBeforeLongBreak == cyclesBeforeLongBreak)&&(identical(other.hasFocusPrompt, hasFocusPrompt) || other.hasFocusPrompt == hasFocusPrompt)&&(identical(other.hasMoodPrompt, hasMoodPrompt) || other.hasMoodPrompt == hasMoodPrompt)&&(identical(other.hasFreetextPrompt, hasFreetextPrompt) || other.hasFreetextPrompt == hasFreetextPrompt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,isRepeating,startDate,endDate,const DeepCollectionEquality().hash(_selectedDays),const DeepCollectionEquality().hash(_learningStrategies),isPomodoro,totalTimeMin,focusTimeMin,breakTimeMin,longBreakTimeMin,cyclesBeforeLongBreak,hasFocusPrompt,hasMoodPrompt,hasFreetextPrompt,createdAt);

@override
String toString() {
  return 'SessionModel(id: $id, title: $title, isRepeating: $isRepeating, startDate: $startDate, endDate: $endDate, selectedDays: $selectedDays, learningStrategies: $learningStrategies, isPomodoro: $isPomodoro, totalTimeMin: $totalTimeMin, focusTimeMin: $focusTimeMin, breakTimeMin: $breakTimeMin, longBreakTimeMin: $longBreakTimeMin, cyclesBeforeLongBreak: $cyclesBeforeLongBreak, hasFocusPrompt: $hasFocusPrompt, hasMoodPrompt: $hasMoodPrompt, hasFreetextPrompt: $hasFreetextPrompt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SessionModelCopyWith<$Res> implements $SessionModelCopyWith<$Res> {
  factory _$SessionModelCopyWith(_SessionModel value, $Res Function(_SessionModel) _then) = __$SessionModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, bool isRepeating, DateTime? startDate, DateTime? endDate, List<int> selectedDays, List<String> learningStrategies, bool isPomodoro, int? totalTimeMin, int? focusTimeMin, int? breakTimeMin, int? longBreakTimeMin, int? cyclesBeforeLongBreak, bool hasFocusPrompt, bool hasMoodPrompt, bool hasFreetextPrompt, DateTime? createdAt
});




}
/// @nodoc
class __$SessionModelCopyWithImpl<$Res>
    implements _$SessionModelCopyWith<$Res> {
  __$SessionModelCopyWithImpl(this._self, this._then);

  final _SessionModel _self;
  final $Res Function(_SessionModel) _then;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? isRepeating = null,Object? startDate = freezed,Object? endDate = freezed,Object? selectedDays = null,Object? learningStrategies = null,Object? isPomodoro = null,Object? totalTimeMin = freezed,Object? focusTimeMin = freezed,Object? breakTimeMin = freezed,Object? longBreakTimeMin = freezed,Object? cyclesBeforeLongBreak = freezed,Object? hasFocusPrompt = null,Object? hasMoodPrompt = null,Object? hasFreetextPrompt = null,Object? createdAt = freezed,}) {
  return _then(_SessionModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isRepeating: null == isRepeating ? _self.isRepeating : isRepeating // ignore: cast_nullable_to_non_nullable
as bool,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,selectedDays: null == selectedDays ? _self._selectedDays : selectedDays // ignore: cast_nullable_to_non_nullable
as List<int>,learningStrategies: null == learningStrategies ? _self._learningStrategies : learningStrategies // ignore: cast_nullable_to_non_nullable
as List<String>,isPomodoro: null == isPomodoro ? _self.isPomodoro : isPomodoro // ignore: cast_nullable_to_non_nullable
as bool,totalTimeMin: freezed == totalTimeMin ? _self.totalTimeMin : totalTimeMin // ignore: cast_nullable_to_non_nullable
as int?,focusTimeMin: freezed == focusTimeMin ? _self.focusTimeMin : focusTimeMin // ignore: cast_nullable_to_non_nullable
as int?,breakTimeMin: freezed == breakTimeMin ? _self.breakTimeMin : breakTimeMin // ignore: cast_nullable_to_non_nullable
as int?,longBreakTimeMin: freezed == longBreakTimeMin ? _self.longBreakTimeMin : longBreakTimeMin // ignore: cast_nullable_to_non_nullable
as int?,cyclesBeforeLongBreak: freezed == cyclesBeforeLongBreak ? _self.cyclesBeforeLongBreak : cyclesBeforeLongBreak // ignore: cast_nullable_to_non_nullable
as int?,hasFocusPrompt: null == hasFocusPrompt ? _self.hasFocusPrompt : hasFocusPrompt // ignore: cast_nullable_to_non_nullable
as bool,hasMoodPrompt: null == hasMoodPrompt ? _self.hasMoodPrompt : hasMoodPrompt // ignore: cast_nullable_to_non_nullable
as bool,hasFreetextPrompt: null == hasFreetextPrompt ? _self.hasFreetextPrompt : hasFreetextPrompt // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
