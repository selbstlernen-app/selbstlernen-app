// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddSessionState {

 String get title; bool get isRepeating; bool get setBigGoals; DateTime? get startDate; DateTime? get endDate; List<int> get selectedDays;// Goals and tasks
 List<GoalModel> get goals; List<TaskModel> get tasks;// Strategies
 List<String> get learningStrategies; List<String> get availableStrategies;// Time
 bool get isPomodoro; int get totalTimeMin; int? get focusTimeMin; int? get breakTimeMin; int? get longBreakTimeMin; int? get cyclesBeforeLongBreak;// Prompts
 bool get hasFocusPrompt; bool get hasMoodPrompt; bool get hasFreetextPrompt;
/// Create a copy of AddSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddSessionStateCopyWith<AddSessionState> get copyWith => _$AddSessionStateCopyWithImpl<AddSessionState>(this as AddSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddSessionState&&(identical(other.title, title) || other.title == title)&&(identical(other.isRepeating, isRepeating) || other.isRepeating == isRepeating)&&(identical(other.setBigGoals, setBigGoals) || other.setBigGoals == setBigGoals)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.selectedDays, selectedDays)&&const DeepCollectionEquality().equals(other.goals, goals)&&const DeepCollectionEquality().equals(other.tasks, tasks)&&const DeepCollectionEquality().equals(other.learningStrategies, learningStrategies)&&const DeepCollectionEquality().equals(other.availableStrategies, availableStrategies)&&(identical(other.isPomodoro, isPomodoro) || other.isPomodoro == isPomodoro)&&(identical(other.totalTimeMin, totalTimeMin) || other.totalTimeMin == totalTimeMin)&&(identical(other.focusTimeMin, focusTimeMin) || other.focusTimeMin == focusTimeMin)&&(identical(other.breakTimeMin, breakTimeMin) || other.breakTimeMin == breakTimeMin)&&(identical(other.longBreakTimeMin, longBreakTimeMin) || other.longBreakTimeMin == longBreakTimeMin)&&(identical(other.cyclesBeforeLongBreak, cyclesBeforeLongBreak) || other.cyclesBeforeLongBreak == cyclesBeforeLongBreak)&&(identical(other.hasFocusPrompt, hasFocusPrompt) || other.hasFocusPrompt == hasFocusPrompt)&&(identical(other.hasMoodPrompt, hasMoodPrompt) || other.hasMoodPrompt == hasMoodPrompt)&&(identical(other.hasFreetextPrompt, hasFreetextPrompt) || other.hasFreetextPrompt == hasFreetextPrompt));
}


@override
int get hashCode => Object.hashAll([runtimeType,title,isRepeating,setBigGoals,startDate,endDate,const DeepCollectionEquality().hash(selectedDays),const DeepCollectionEquality().hash(goals),const DeepCollectionEquality().hash(tasks),const DeepCollectionEquality().hash(learningStrategies),const DeepCollectionEquality().hash(availableStrategies),isPomodoro,totalTimeMin,focusTimeMin,breakTimeMin,longBreakTimeMin,cyclesBeforeLongBreak,hasFocusPrompt,hasMoodPrompt,hasFreetextPrompt]);

@override
String toString() {
  return 'AddSessionState(title: $title, isRepeating: $isRepeating, setBigGoals: $setBigGoals, startDate: $startDate, endDate: $endDate, selectedDays: $selectedDays, goals: $goals, tasks: $tasks, learningStrategies: $learningStrategies, availableStrategies: $availableStrategies, isPomodoro: $isPomodoro, totalTimeMin: $totalTimeMin, focusTimeMin: $focusTimeMin, breakTimeMin: $breakTimeMin, longBreakTimeMin: $longBreakTimeMin, cyclesBeforeLongBreak: $cyclesBeforeLongBreak, hasFocusPrompt: $hasFocusPrompt, hasMoodPrompt: $hasMoodPrompt, hasFreetextPrompt: $hasFreetextPrompt)';
}


}

/// @nodoc
abstract mixin class $AddSessionStateCopyWith<$Res>  {
  factory $AddSessionStateCopyWith(AddSessionState value, $Res Function(AddSessionState) _then) = _$AddSessionStateCopyWithImpl;
@useResult
$Res call({
 String title, bool isRepeating, bool setBigGoals, DateTime? startDate, DateTime? endDate, List<int> selectedDays, List<GoalModel> goals, List<TaskModel> tasks, List<String> learningStrategies, List<String> availableStrategies, bool isPomodoro, int totalTimeMin, int? focusTimeMin, int? breakTimeMin, int? longBreakTimeMin, int? cyclesBeforeLongBreak, bool hasFocusPrompt, bool hasMoodPrompt, bool hasFreetextPrompt
});




}
/// @nodoc
class _$AddSessionStateCopyWithImpl<$Res>
    implements $AddSessionStateCopyWith<$Res> {
  _$AddSessionStateCopyWithImpl(this._self, this._then);

  final AddSessionState _self;
  final $Res Function(AddSessionState) _then;

/// Create a copy of AddSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? isRepeating = null,Object? setBigGoals = null,Object? startDate = freezed,Object? endDate = freezed,Object? selectedDays = null,Object? goals = null,Object? tasks = null,Object? learningStrategies = null,Object? availableStrategies = null,Object? isPomodoro = null,Object? totalTimeMin = null,Object? focusTimeMin = freezed,Object? breakTimeMin = freezed,Object? longBreakTimeMin = freezed,Object? cyclesBeforeLongBreak = freezed,Object? hasFocusPrompt = null,Object? hasMoodPrompt = null,Object? hasFreetextPrompt = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isRepeating: null == isRepeating ? _self.isRepeating : isRepeating // ignore: cast_nullable_to_non_nullable
as bool,setBigGoals: null == setBigGoals ? _self.setBigGoals : setBigGoals // ignore: cast_nullable_to_non_nullable
as bool,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,selectedDays: null == selectedDays ? _self.selectedDays : selectedDays // ignore: cast_nullable_to_non_nullable
as List<int>,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<GoalModel>,tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskModel>,learningStrategies: null == learningStrategies ? _self.learningStrategies : learningStrategies // ignore: cast_nullable_to_non_nullable
as List<String>,availableStrategies: null == availableStrategies ? _self.availableStrategies : availableStrategies // ignore: cast_nullable_to_non_nullable
as List<String>,isPomodoro: null == isPomodoro ? _self.isPomodoro : isPomodoro // ignore: cast_nullable_to_non_nullable
as bool,totalTimeMin: null == totalTimeMin ? _self.totalTimeMin : totalTimeMin // ignore: cast_nullable_to_non_nullable
as int,focusTimeMin: freezed == focusTimeMin ? _self.focusTimeMin : focusTimeMin // ignore: cast_nullable_to_non_nullable
as int?,breakTimeMin: freezed == breakTimeMin ? _self.breakTimeMin : breakTimeMin // ignore: cast_nullable_to_non_nullable
as int?,longBreakTimeMin: freezed == longBreakTimeMin ? _self.longBreakTimeMin : longBreakTimeMin // ignore: cast_nullable_to_non_nullable
as int?,cyclesBeforeLongBreak: freezed == cyclesBeforeLongBreak ? _self.cyclesBeforeLongBreak : cyclesBeforeLongBreak // ignore: cast_nullable_to_non_nullable
as int?,hasFocusPrompt: null == hasFocusPrompt ? _self.hasFocusPrompt : hasFocusPrompt // ignore: cast_nullable_to_non_nullable
as bool,hasMoodPrompt: null == hasMoodPrompt ? _self.hasMoodPrompt : hasMoodPrompt // ignore: cast_nullable_to_non_nullable
as bool,hasFreetextPrompt: null == hasFreetextPrompt ? _self.hasFreetextPrompt : hasFreetextPrompt // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AddSessionState].
extension AddSessionStatePatterns on AddSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddSessionState value)  $default,){
final _that = this;
switch (_that) {
case _AddSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _AddSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  bool isRepeating,  bool setBigGoals,  DateTime? startDate,  DateTime? endDate,  List<int> selectedDays,  List<GoalModel> goals,  List<TaskModel> tasks,  List<String> learningStrategies,  List<String> availableStrategies,  bool isPomodoro,  int totalTimeMin,  int? focusTimeMin,  int? breakTimeMin,  int? longBreakTimeMin,  int? cyclesBeforeLongBreak,  bool hasFocusPrompt,  bool hasMoodPrompt,  bool hasFreetextPrompt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddSessionState() when $default != null:
return $default(_that.title,_that.isRepeating,_that.setBigGoals,_that.startDate,_that.endDate,_that.selectedDays,_that.goals,_that.tasks,_that.learningStrategies,_that.availableStrategies,_that.isPomodoro,_that.totalTimeMin,_that.focusTimeMin,_that.breakTimeMin,_that.longBreakTimeMin,_that.cyclesBeforeLongBreak,_that.hasFocusPrompt,_that.hasMoodPrompt,_that.hasFreetextPrompt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  bool isRepeating,  bool setBigGoals,  DateTime? startDate,  DateTime? endDate,  List<int> selectedDays,  List<GoalModel> goals,  List<TaskModel> tasks,  List<String> learningStrategies,  List<String> availableStrategies,  bool isPomodoro,  int totalTimeMin,  int? focusTimeMin,  int? breakTimeMin,  int? longBreakTimeMin,  int? cyclesBeforeLongBreak,  bool hasFocusPrompt,  bool hasMoodPrompt,  bool hasFreetextPrompt)  $default,) {final _that = this;
switch (_that) {
case _AddSessionState():
return $default(_that.title,_that.isRepeating,_that.setBigGoals,_that.startDate,_that.endDate,_that.selectedDays,_that.goals,_that.tasks,_that.learningStrategies,_that.availableStrategies,_that.isPomodoro,_that.totalTimeMin,_that.focusTimeMin,_that.breakTimeMin,_that.longBreakTimeMin,_that.cyclesBeforeLongBreak,_that.hasFocusPrompt,_that.hasMoodPrompt,_that.hasFreetextPrompt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  bool isRepeating,  bool setBigGoals,  DateTime? startDate,  DateTime? endDate,  List<int> selectedDays,  List<GoalModel> goals,  List<TaskModel> tasks,  List<String> learningStrategies,  List<String> availableStrategies,  bool isPomodoro,  int totalTimeMin,  int? focusTimeMin,  int? breakTimeMin,  int? longBreakTimeMin,  int? cyclesBeforeLongBreak,  bool hasFocusPrompt,  bool hasMoodPrompt,  bool hasFreetextPrompt)?  $default,) {final _that = this;
switch (_that) {
case _AddSessionState() when $default != null:
return $default(_that.title,_that.isRepeating,_that.setBigGoals,_that.startDate,_that.endDate,_that.selectedDays,_that.goals,_that.tasks,_that.learningStrategies,_that.availableStrategies,_that.isPomodoro,_that.totalTimeMin,_that.focusTimeMin,_that.breakTimeMin,_that.longBreakTimeMin,_that.cyclesBeforeLongBreak,_that.hasFocusPrompt,_that.hasMoodPrompt,_that.hasFreetextPrompt);case _:
  return null;

}
}

}

/// @nodoc


class _AddSessionState extends AddSessionState {
  const _AddSessionState({this.title = '', this.isRepeating = false, this.setBigGoals = true, this.startDate, this.endDate, final  List<int> selectedDays = const <int>[], final  List<GoalModel> goals = const <GoalModel>[], final  List<TaskModel> tasks = const <TaskModel>[], final  List<String> learningStrategies = const <String>[], final  List<String> availableStrategies = const <String>['Mind-map erstellen', 'Mit Freunden besprechen', 'Notizen machen', 'Neu-lesen', 'Wiederholen', 'Karteikarten erstellen'], this.isPomodoro = true, this.totalTimeMin = 60, this.focusTimeMin, this.breakTimeMin, this.longBreakTimeMin, this.cyclesBeforeLongBreak, this.hasFocusPrompt = false, this.hasMoodPrompt = false, this.hasFreetextPrompt = false}): _selectedDays = selectedDays,_goals = goals,_tasks = tasks,_learningStrategies = learningStrategies,_availableStrategies = availableStrategies,super._();
  

@override@JsonKey() final  String title;
@override@JsonKey() final  bool isRepeating;
@override@JsonKey() final  bool setBigGoals;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<int> _selectedDays;
@override@JsonKey() List<int> get selectedDays {
  if (_selectedDays is EqualUnmodifiableListView) return _selectedDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedDays);
}

// Goals and tasks
 final  List<GoalModel> _goals;
// Goals and tasks
@override@JsonKey() List<GoalModel> get goals {
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goals);
}

 final  List<TaskModel> _tasks;
@override@JsonKey() List<TaskModel> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

// Strategies
 final  List<String> _learningStrategies;
// Strategies
@override@JsonKey() List<String> get learningStrategies {
  if (_learningStrategies is EqualUnmodifiableListView) return _learningStrategies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_learningStrategies);
}

 final  List<String> _availableStrategies;
@override@JsonKey() List<String> get availableStrategies {
  if (_availableStrategies is EqualUnmodifiableListView) return _availableStrategies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableStrategies);
}

// Time
@override@JsonKey() final  bool isPomodoro;
@override@JsonKey() final  int totalTimeMin;
@override final  int? focusTimeMin;
@override final  int? breakTimeMin;
@override final  int? longBreakTimeMin;
@override final  int? cyclesBeforeLongBreak;
// Prompts
@override@JsonKey() final  bool hasFocusPrompt;
@override@JsonKey() final  bool hasMoodPrompt;
@override@JsonKey() final  bool hasFreetextPrompt;

/// Create a copy of AddSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddSessionStateCopyWith<_AddSessionState> get copyWith => __$AddSessionStateCopyWithImpl<_AddSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddSessionState&&(identical(other.title, title) || other.title == title)&&(identical(other.isRepeating, isRepeating) || other.isRepeating == isRepeating)&&(identical(other.setBigGoals, setBigGoals) || other.setBigGoals == setBigGoals)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._selectedDays, _selectedDays)&&const DeepCollectionEquality().equals(other._goals, _goals)&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&const DeepCollectionEquality().equals(other._learningStrategies, _learningStrategies)&&const DeepCollectionEquality().equals(other._availableStrategies, _availableStrategies)&&(identical(other.isPomodoro, isPomodoro) || other.isPomodoro == isPomodoro)&&(identical(other.totalTimeMin, totalTimeMin) || other.totalTimeMin == totalTimeMin)&&(identical(other.focusTimeMin, focusTimeMin) || other.focusTimeMin == focusTimeMin)&&(identical(other.breakTimeMin, breakTimeMin) || other.breakTimeMin == breakTimeMin)&&(identical(other.longBreakTimeMin, longBreakTimeMin) || other.longBreakTimeMin == longBreakTimeMin)&&(identical(other.cyclesBeforeLongBreak, cyclesBeforeLongBreak) || other.cyclesBeforeLongBreak == cyclesBeforeLongBreak)&&(identical(other.hasFocusPrompt, hasFocusPrompt) || other.hasFocusPrompt == hasFocusPrompt)&&(identical(other.hasMoodPrompt, hasMoodPrompt) || other.hasMoodPrompt == hasMoodPrompt)&&(identical(other.hasFreetextPrompt, hasFreetextPrompt) || other.hasFreetextPrompt == hasFreetextPrompt));
}


@override
int get hashCode => Object.hashAll([runtimeType,title,isRepeating,setBigGoals,startDate,endDate,const DeepCollectionEquality().hash(_selectedDays),const DeepCollectionEquality().hash(_goals),const DeepCollectionEquality().hash(_tasks),const DeepCollectionEquality().hash(_learningStrategies),const DeepCollectionEquality().hash(_availableStrategies),isPomodoro,totalTimeMin,focusTimeMin,breakTimeMin,longBreakTimeMin,cyclesBeforeLongBreak,hasFocusPrompt,hasMoodPrompt,hasFreetextPrompt]);

@override
String toString() {
  return 'AddSessionState(title: $title, isRepeating: $isRepeating, setBigGoals: $setBigGoals, startDate: $startDate, endDate: $endDate, selectedDays: $selectedDays, goals: $goals, tasks: $tasks, learningStrategies: $learningStrategies, availableStrategies: $availableStrategies, isPomodoro: $isPomodoro, totalTimeMin: $totalTimeMin, focusTimeMin: $focusTimeMin, breakTimeMin: $breakTimeMin, longBreakTimeMin: $longBreakTimeMin, cyclesBeforeLongBreak: $cyclesBeforeLongBreak, hasFocusPrompt: $hasFocusPrompt, hasMoodPrompt: $hasMoodPrompt, hasFreetextPrompt: $hasFreetextPrompt)';
}


}

/// @nodoc
abstract mixin class _$AddSessionStateCopyWith<$Res> implements $AddSessionStateCopyWith<$Res> {
  factory _$AddSessionStateCopyWith(_AddSessionState value, $Res Function(_AddSessionState) _then) = __$AddSessionStateCopyWithImpl;
@override @useResult
$Res call({
 String title, bool isRepeating, bool setBigGoals, DateTime? startDate, DateTime? endDate, List<int> selectedDays, List<GoalModel> goals, List<TaskModel> tasks, List<String> learningStrategies, List<String> availableStrategies, bool isPomodoro, int totalTimeMin, int? focusTimeMin, int? breakTimeMin, int? longBreakTimeMin, int? cyclesBeforeLongBreak, bool hasFocusPrompt, bool hasMoodPrompt, bool hasFreetextPrompt
});




}
/// @nodoc
class __$AddSessionStateCopyWithImpl<$Res>
    implements _$AddSessionStateCopyWith<$Res> {
  __$AddSessionStateCopyWithImpl(this._self, this._then);

  final _AddSessionState _self;
  final $Res Function(_AddSessionState) _then;

/// Create a copy of AddSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? isRepeating = null,Object? setBigGoals = null,Object? startDate = freezed,Object? endDate = freezed,Object? selectedDays = null,Object? goals = null,Object? tasks = null,Object? learningStrategies = null,Object? availableStrategies = null,Object? isPomodoro = null,Object? totalTimeMin = null,Object? focusTimeMin = freezed,Object? breakTimeMin = freezed,Object? longBreakTimeMin = freezed,Object? cyclesBeforeLongBreak = freezed,Object? hasFocusPrompt = null,Object? hasMoodPrompt = null,Object? hasFreetextPrompt = null,}) {
  return _then(_AddSessionState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isRepeating: null == isRepeating ? _self.isRepeating : isRepeating // ignore: cast_nullable_to_non_nullable
as bool,setBigGoals: null == setBigGoals ? _self.setBigGoals : setBigGoals // ignore: cast_nullable_to_non_nullable
as bool,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,selectedDays: null == selectedDays ? _self._selectedDays : selectedDays // ignore: cast_nullable_to_non_nullable
as List<int>,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<GoalModel>,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskModel>,learningStrategies: null == learningStrategies ? _self._learningStrategies : learningStrategies // ignore: cast_nullable_to_non_nullable
as List<String>,availableStrategies: null == availableStrategies ? _self._availableStrategies : availableStrategies // ignore: cast_nullable_to_non_nullable
as List<String>,isPomodoro: null == isPomodoro ? _self.isPomodoro : isPomodoro // ignore: cast_nullable_to_non_nullable
as bool,totalTimeMin: null == totalTimeMin ? _self.totalTimeMin : totalTimeMin // ignore: cast_nullable_to_non_nullable
as int,focusTimeMin: freezed == focusTimeMin ? _self.focusTimeMin : focusTimeMin // ignore: cast_nullable_to_non_nullable
as int?,breakTimeMin: freezed == breakTimeMin ? _self.breakTimeMin : breakTimeMin // ignore: cast_nullable_to_non_nullable
as int?,longBreakTimeMin: freezed == longBreakTimeMin ? _self.longBreakTimeMin : longBreakTimeMin // ignore: cast_nullable_to_non_nullable
as int?,cyclesBeforeLongBreak: freezed == cyclesBeforeLongBreak ? _self.cyclesBeforeLongBreak : cyclesBeforeLongBreak // ignore: cast_nullable_to_non_nullable
as int?,hasFocusPrompt: null == hasFocusPrompt ? _self.hasFocusPrompt : hasFocusPrompt // ignore: cast_nullable_to_non_nullable
as bool,hasMoodPrompt: null == hasMoodPrompt ? _self.hasMoodPrompt : hasMoodPrompt // ignore: cast_nullable_to_non_nullable
as bool,hasFreetextPrompt: null == hasFreetextPrompt ? _self.hasFreetextPrompt : hasFreetextPrompt // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
