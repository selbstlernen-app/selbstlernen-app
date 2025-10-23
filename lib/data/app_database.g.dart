// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRepeatingMeta = const VerificationMeta(
    'isRepeating',
  );
  @override
  late final GeneratedColumn<bool> isRepeating = GeneratedColumn<bool>(
    'is_repeating',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_repeating" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedDaysMeta = const VerificationMeta(
    'selectedDays',
  );
  @override
  late final GeneratedColumn<String> selectedDays = GeneratedColumn<String>(
    'selected_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _learningStrategiesMeta =
      const VerificationMeta('learningStrategies');
  @override
  late final GeneratedColumn<String> learningStrategies =
      GeneratedColumn<String>(
        'learning_strategies',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isPomodoroMeta = const VerificationMeta(
    'isPomodoro',
  );
  @override
  late final GeneratedColumn<bool> isPomodoro = GeneratedColumn<bool>(
    'is_pomodoro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pomodoro" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(true),
  );
  static const VerificationMeta _totalTimeMinMeta = const VerificationMeta(
    'totalTimeMin',
  );
  @override
  late final GeneratedColumn<int> totalTimeMin = GeneratedColumn<int>(
    'total_time_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusTimeMinMeta = const VerificationMeta(
    'focusTimeMin',
  );
  @override
  late final GeneratedColumn<int> focusTimeMin = GeneratedColumn<int>(
    'focus_time_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakTimeMinMeta = const VerificationMeta(
    'breakTimeMin',
  );
  @override
  late final GeneratedColumn<int> breakTimeMin = GeneratedColumn<int>(
    'break_time_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longBreakTimeMinMeta = const VerificationMeta(
    'longBreakTimeMin',
  );
  @override
  late final GeneratedColumn<int> longBreakTimeMin = GeneratedColumn<int>(
    'long_break_time_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cyclesBeforeLongBreakMeta =
      const VerificationMeta('cyclesBeforeLongBreak');
  @override
  late final GeneratedColumn<int> cyclesBeforeLongBreak = GeneratedColumn<int>(
    'cycles_before_long_break',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasFocusPromptMeta = const VerificationMeta(
    'hasFocusPrompt',
  );
  @override
  late final GeneratedColumn<bool> hasFocusPrompt = GeneratedColumn<bool>(
    'has_focus_prompt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_focus_prompt" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(true),
  );
  static const VerificationMeta _hasMoodPromptMeta = const VerificationMeta(
    'hasMoodPrompt',
  );
  @override
  late final GeneratedColumn<bool> hasMoodPrompt = GeneratedColumn<bool>(
    'has_mood_prompt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_mood_prompt" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(true),
  );
  static const VerificationMeta _hasFreetextPromptMeta = const VerificationMeta(
    'hasFreetextPrompt',
  );
  @override
  late final GeneratedColumn<bool> hasFreetextPrompt = GeneratedColumn<bool>(
    'has_freetext_prompt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_freetext_prompt" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    isRepeating,
    startDate,
    endDate,
    selectedDays,
    learningStrategies,
    isPomodoro,
    totalTimeMin,
    focusTimeMin,
    breakTimeMin,
    longBreakTimeMin,
    cyclesBeforeLongBreak,
    hasFocusPrompt,
    hasMoodPrompt,
    hasFreetextPrompt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_repeating')) {
      context.handle(
        _isRepeatingMeta,
        isRepeating.isAcceptableOrUnknown(
          data['is_repeating']!,
          _isRepeatingMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('selected_days')) {
      context.handle(
        _selectedDaysMeta,
        selectedDays.isAcceptableOrUnknown(
          data['selected_days']!,
          _selectedDaysMeta,
        ),
      );
    }
    if (data.containsKey('learning_strategies')) {
      context.handle(
        _learningStrategiesMeta,
        learningStrategies.isAcceptableOrUnknown(
          data['learning_strategies']!,
          _learningStrategiesMeta,
        ),
      );
    }
    if (data.containsKey('is_pomodoro')) {
      context.handle(
        _isPomodoroMeta,
        isPomodoro.isAcceptableOrUnknown(data['is_pomodoro']!, _isPomodoroMeta),
      );
    }
    if (data.containsKey('total_time_min')) {
      context.handle(
        _totalTimeMinMeta,
        totalTimeMin.isAcceptableOrUnknown(
          data['total_time_min']!,
          _totalTimeMinMeta,
        ),
      );
    }
    if (data.containsKey('focus_time_min')) {
      context.handle(
        _focusTimeMinMeta,
        focusTimeMin.isAcceptableOrUnknown(
          data['focus_time_min']!,
          _focusTimeMinMeta,
        ),
      );
    }
    if (data.containsKey('break_time_min')) {
      context.handle(
        _breakTimeMinMeta,
        breakTimeMin.isAcceptableOrUnknown(
          data['break_time_min']!,
          _breakTimeMinMeta,
        ),
      );
    }
    if (data.containsKey('long_break_time_min')) {
      context.handle(
        _longBreakTimeMinMeta,
        longBreakTimeMin.isAcceptableOrUnknown(
          data['long_break_time_min']!,
          _longBreakTimeMinMeta,
        ),
      );
    }
    if (data.containsKey('cycles_before_long_break')) {
      context.handle(
        _cyclesBeforeLongBreakMeta,
        cyclesBeforeLongBreak.isAcceptableOrUnknown(
          data['cycles_before_long_break']!,
          _cyclesBeforeLongBreakMeta,
        ),
      );
    }
    if (data.containsKey('has_focus_prompt')) {
      context.handle(
        _hasFocusPromptMeta,
        hasFocusPrompt.isAcceptableOrUnknown(
          data['has_focus_prompt']!,
          _hasFocusPromptMeta,
        ),
      );
    }
    if (data.containsKey('has_mood_prompt')) {
      context.handle(
        _hasMoodPromptMeta,
        hasMoodPrompt.isAcceptableOrUnknown(
          data['has_mood_prompt']!,
          _hasMoodPromptMeta,
        ),
      );
    }
    if (data.containsKey('has_freetext_prompt')) {
      context.handle(
        _hasFreetextPromptMeta,
        hasFreetextPrompt.isAcceptableOrUnknown(
          data['has_freetext_prompt']!,
          _hasFreetextPromptMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isRepeating: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_repeating'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      selectedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_days'],
      ),
      learningStrategies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_strategies'],
      ),
      isPomodoro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pomodoro'],
      )!,
      totalTimeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_time_min'],
      ),
      focusTimeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_time_min'],
      ),
      breakTimeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_time_min'],
      ),
      longBreakTimeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}long_break_time_min'],
      ),
      cyclesBeforeLongBreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycles_before_long_break'],
      ),
      hasFocusPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_focus_prompt'],
      )!,
      hasMoodPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_mood_prompt'],
      )!,
      hasFreetextPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_freetext_prompt'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String title;
  final bool isRepeating;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedDays;
  final String? learningStrategies;
  final bool isPomodoro;
  final int? totalTimeMin;
  final int? focusTimeMin;
  final int? breakTimeMin;
  final int? longBreakTimeMin;
  final int? cyclesBeforeLongBreak;
  final bool hasFocusPrompt;
  final bool hasMoodPrompt;
  final bool hasFreetextPrompt;
  final DateTime createdAt;
  const Session({
    required this.id,
    required this.title,
    required this.isRepeating,
    this.startDate,
    this.endDate,
    this.selectedDays,
    this.learningStrategies,
    required this.isPomodoro,
    this.totalTimeMin,
    this.focusTimeMin,
    this.breakTimeMin,
    this.longBreakTimeMin,
    this.cyclesBeforeLongBreak,
    required this.hasFocusPrompt,
    required this.hasMoodPrompt,
    required this.hasFreetextPrompt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['is_repeating'] = Variable<bool>(isRepeating);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || selectedDays != null) {
      map['selected_days'] = Variable<String>(selectedDays);
    }
    if (!nullToAbsent || learningStrategies != null) {
      map['learning_strategies'] = Variable<String>(learningStrategies);
    }
    map['is_pomodoro'] = Variable<bool>(isPomodoro);
    if (!nullToAbsent || totalTimeMin != null) {
      map['total_time_min'] = Variable<int>(totalTimeMin);
    }
    if (!nullToAbsent || focusTimeMin != null) {
      map['focus_time_min'] = Variable<int>(focusTimeMin);
    }
    if (!nullToAbsent || breakTimeMin != null) {
      map['break_time_min'] = Variable<int>(breakTimeMin);
    }
    if (!nullToAbsent || longBreakTimeMin != null) {
      map['long_break_time_min'] = Variable<int>(longBreakTimeMin);
    }
    if (!nullToAbsent || cyclesBeforeLongBreak != null) {
      map['cycles_before_long_break'] = Variable<int>(cyclesBeforeLongBreak);
    }
    map['has_focus_prompt'] = Variable<bool>(hasFocusPrompt);
    map['has_mood_prompt'] = Variable<bool>(hasMoodPrompt);
    map['has_freetext_prompt'] = Variable<bool>(hasFreetextPrompt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      title: Value(title),
      isRepeating: Value(isRepeating),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      selectedDays: selectedDays == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedDays),
      learningStrategies: learningStrategies == null && nullToAbsent
          ? const Value.absent()
          : Value(learningStrategies),
      isPomodoro: Value(isPomodoro),
      totalTimeMin: totalTimeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTimeMin),
      focusTimeMin: focusTimeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(focusTimeMin),
      breakTimeMin: breakTimeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(breakTimeMin),
      longBreakTimeMin: longBreakTimeMin == null && nullToAbsent
          ? const Value.absent()
          : Value(longBreakTimeMin),
      cyclesBeforeLongBreak: cyclesBeforeLongBreak == null && nullToAbsent
          ? const Value.absent()
          : Value(cyclesBeforeLongBreak),
      hasFocusPrompt: Value(hasFocusPrompt),
      hasMoodPrompt: Value(hasMoodPrompt),
      hasFreetextPrompt: Value(hasFreetextPrompt),
      createdAt: Value(createdAt),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      isRepeating: serializer.fromJson<bool>(json['isRepeating']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      selectedDays: serializer.fromJson<String?>(json['selectedDays']),
      learningStrategies: serializer.fromJson<String?>(
        json['learningStrategies'],
      ),
      isPomodoro: serializer.fromJson<bool>(json['isPomodoro']),
      totalTimeMin: serializer.fromJson<int?>(json['totalTimeMin']),
      focusTimeMin: serializer.fromJson<int?>(json['focusTimeMin']),
      breakTimeMin: serializer.fromJson<int?>(json['breakTimeMin']),
      longBreakTimeMin: serializer.fromJson<int?>(json['longBreakTimeMin']),
      cyclesBeforeLongBreak: serializer.fromJson<int?>(
        json['cyclesBeforeLongBreak'],
      ),
      hasFocusPrompt: serializer.fromJson<bool>(json['hasFocusPrompt']),
      hasMoodPrompt: serializer.fromJson<bool>(json['hasMoodPrompt']),
      hasFreetextPrompt: serializer.fromJson<bool>(json['hasFreetextPrompt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'isRepeating': serializer.toJson<bool>(isRepeating),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'selectedDays': serializer.toJson<String?>(selectedDays),
      'learningStrategies': serializer.toJson<String?>(learningStrategies),
      'isPomodoro': serializer.toJson<bool>(isPomodoro),
      'totalTimeMin': serializer.toJson<int?>(totalTimeMin),
      'focusTimeMin': serializer.toJson<int?>(focusTimeMin),
      'breakTimeMin': serializer.toJson<int?>(breakTimeMin),
      'longBreakTimeMin': serializer.toJson<int?>(longBreakTimeMin),
      'cyclesBeforeLongBreak': serializer.toJson<int?>(cyclesBeforeLongBreak),
      'hasFocusPrompt': serializer.toJson<bool>(hasFocusPrompt),
      'hasMoodPrompt': serializer.toJson<bool>(hasMoodPrompt),
      'hasFreetextPrompt': serializer.toJson<bool>(hasFreetextPrompt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Session copyWith({
    int? id,
    String? title,
    bool? isRepeating,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> selectedDays = const Value.absent(),
    Value<String?> learningStrategies = const Value.absent(),
    bool? isPomodoro,
    Value<int?> totalTimeMin = const Value.absent(),
    Value<int?> focusTimeMin = const Value.absent(),
    Value<int?> breakTimeMin = const Value.absent(),
    Value<int?> longBreakTimeMin = const Value.absent(),
    Value<int?> cyclesBeforeLongBreak = const Value.absent(),
    bool? hasFocusPrompt,
    bool? hasMoodPrompt,
    bool? hasFreetextPrompt,
    DateTime? createdAt,
  }) => Session(
    id: id ?? this.id,
    title: title ?? this.title,
    isRepeating: isRepeating ?? this.isRepeating,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    selectedDays: selectedDays.present ? selectedDays.value : this.selectedDays,
    learningStrategies: learningStrategies.present
        ? learningStrategies.value
        : this.learningStrategies,
    isPomodoro: isPomodoro ?? this.isPomodoro,
    totalTimeMin: totalTimeMin.present ? totalTimeMin.value : this.totalTimeMin,
    focusTimeMin: focusTimeMin.present ? focusTimeMin.value : this.focusTimeMin,
    breakTimeMin: breakTimeMin.present ? breakTimeMin.value : this.breakTimeMin,
    longBreakTimeMin: longBreakTimeMin.present
        ? longBreakTimeMin.value
        : this.longBreakTimeMin,
    cyclesBeforeLongBreak: cyclesBeforeLongBreak.present
        ? cyclesBeforeLongBreak.value
        : this.cyclesBeforeLongBreak,
    hasFocusPrompt: hasFocusPrompt ?? this.hasFocusPrompt,
    hasMoodPrompt: hasMoodPrompt ?? this.hasMoodPrompt,
    hasFreetextPrompt: hasFreetextPrompt ?? this.hasFreetextPrompt,
    createdAt: createdAt ?? this.createdAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      isRepeating: data.isRepeating.present
          ? data.isRepeating.value
          : this.isRepeating,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      selectedDays: data.selectedDays.present
          ? data.selectedDays.value
          : this.selectedDays,
      learningStrategies: data.learningStrategies.present
          ? data.learningStrategies.value
          : this.learningStrategies,
      isPomodoro: data.isPomodoro.present
          ? data.isPomodoro.value
          : this.isPomodoro,
      totalTimeMin: data.totalTimeMin.present
          ? data.totalTimeMin.value
          : this.totalTimeMin,
      focusTimeMin: data.focusTimeMin.present
          ? data.focusTimeMin.value
          : this.focusTimeMin,
      breakTimeMin: data.breakTimeMin.present
          ? data.breakTimeMin.value
          : this.breakTimeMin,
      longBreakTimeMin: data.longBreakTimeMin.present
          ? data.longBreakTimeMin.value
          : this.longBreakTimeMin,
      cyclesBeforeLongBreak: data.cyclesBeforeLongBreak.present
          ? data.cyclesBeforeLongBreak.value
          : this.cyclesBeforeLongBreak,
      hasFocusPrompt: data.hasFocusPrompt.present
          ? data.hasFocusPrompt.value
          : this.hasFocusPrompt,
      hasMoodPrompt: data.hasMoodPrompt.present
          ? data.hasMoodPrompt.value
          : this.hasMoodPrompt,
      hasFreetextPrompt: data.hasFreetextPrompt.present
          ? data.hasFreetextPrompt.value
          : this.hasFreetextPrompt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isRepeating: $isRepeating, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('selectedDays: $selectedDays, ')
          ..write('learningStrategies: $learningStrategies, ')
          ..write('isPomodoro: $isPomodoro, ')
          ..write('totalTimeMin: $totalTimeMin, ')
          ..write('focusTimeMin: $focusTimeMin, ')
          ..write('breakTimeMin: $breakTimeMin, ')
          ..write('longBreakTimeMin: $longBreakTimeMin, ')
          ..write('cyclesBeforeLongBreak: $cyclesBeforeLongBreak, ')
          ..write('hasFocusPrompt: $hasFocusPrompt, ')
          ..write('hasMoodPrompt: $hasMoodPrompt, ')
          ..write('hasFreetextPrompt: $hasFreetextPrompt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    isRepeating,
    startDate,
    endDate,
    selectedDays,
    learningStrategies,
    isPomodoro,
    totalTimeMin,
    focusTimeMin,
    breakTimeMin,
    longBreakTimeMin,
    cyclesBeforeLongBreak,
    hasFocusPrompt,
    hasMoodPrompt,
    hasFreetextPrompt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.title == this.title &&
          other.isRepeating == this.isRepeating &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.selectedDays == this.selectedDays &&
          other.learningStrategies == this.learningStrategies &&
          other.isPomodoro == this.isPomodoro &&
          other.totalTimeMin == this.totalTimeMin &&
          other.focusTimeMin == this.focusTimeMin &&
          other.breakTimeMin == this.breakTimeMin &&
          other.longBreakTimeMin == this.longBreakTimeMin &&
          other.cyclesBeforeLongBreak == this.cyclesBeforeLongBreak &&
          other.hasFocusPrompt == this.hasFocusPrompt &&
          other.hasMoodPrompt == this.hasMoodPrompt &&
          other.hasFreetextPrompt == this.hasFreetextPrompt &&
          other.createdAt == this.createdAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> title;
  final Value<bool> isRepeating;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> selectedDays;
  final Value<String?> learningStrategies;
  final Value<bool> isPomodoro;
  final Value<int?> totalTimeMin;
  final Value<int?> focusTimeMin;
  final Value<int?> breakTimeMin;
  final Value<int?> longBreakTimeMin;
  final Value<int?> cyclesBeforeLongBreak;
  final Value<bool> hasFocusPrompt;
  final Value<bool> hasMoodPrompt;
  final Value<bool> hasFreetextPrompt;
  final Value<DateTime> createdAt;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.isRepeating = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.selectedDays = const Value.absent(),
    this.learningStrategies = const Value.absent(),
    this.isPomodoro = const Value.absent(),
    this.totalTimeMin = const Value.absent(),
    this.focusTimeMin = const Value.absent(),
    this.breakTimeMin = const Value.absent(),
    this.longBreakTimeMin = const Value.absent(),
    this.cyclesBeforeLongBreak = const Value.absent(),
    this.hasFocusPrompt = const Value.absent(),
    this.hasMoodPrompt = const Value.absent(),
    this.hasFreetextPrompt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.isRepeating = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.selectedDays = const Value.absent(),
    this.learningStrategies = const Value.absent(),
    this.isPomodoro = const Value.absent(),
    this.totalTimeMin = const Value.absent(),
    this.focusTimeMin = const Value.absent(),
    this.breakTimeMin = const Value.absent(),
    this.longBreakTimeMin = const Value.absent(),
    this.cyclesBeforeLongBreak = const Value.absent(),
    this.hasFocusPrompt = const Value.absent(),
    this.hasMoodPrompt = const Value.absent(),
    this.hasFreetextPrompt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<bool>? isRepeating,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? selectedDays,
    Expression<String>? learningStrategies,
    Expression<bool>? isPomodoro,
    Expression<int>? totalTimeMin,
    Expression<int>? focusTimeMin,
    Expression<int>? breakTimeMin,
    Expression<int>? longBreakTimeMin,
    Expression<int>? cyclesBeforeLongBreak,
    Expression<bool>? hasFocusPrompt,
    Expression<bool>? hasMoodPrompt,
    Expression<bool>? hasFreetextPrompt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (isRepeating != null) 'is_repeating': isRepeating,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (selectedDays != null) 'selected_days': selectedDays,
      if (learningStrategies != null) 'learning_strategies': learningStrategies,
      if (isPomodoro != null) 'is_pomodoro': isPomodoro,
      if (totalTimeMin != null) 'total_time_min': totalTimeMin,
      if (focusTimeMin != null) 'focus_time_min': focusTimeMin,
      if (breakTimeMin != null) 'break_time_min': breakTimeMin,
      if (longBreakTimeMin != null) 'long_break_time_min': longBreakTimeMin,
      if (cyclesBeforeLongBreak != null)
        'cycles_before_long_break': cyclesBeforeLongBreak,
      if (hasFocusPrompt != null) 'has_focus_prompt': hasFocusPrompt,
      if (hasMoodPrompt != null) 'has_mood_prompt': hasMoodPrompt,
      if (hasFreetextPrompt != null) 'has_freetext_prompt': hasFreetextPrompt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<bool>? isRepeating,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? selectedDays,
    Value<String?>? learningStrategies,
    Value<bool>? isPomodoro,
    Value<int?>? totalTimeMin,
    Value<int?>? focusTimeMin,
    Value<int?>? breakTimeMin,
    Value<int?>? longBreakTimeMin,
    Value<int?>? cyclesBeforeLongBreak,
    Value<bool>? hasFocusPrompt,
    Value<bool>? hasMoodPrompt,
    Value<bool>? hasFreetextPrompt,
    Value<DateTime>? createdAt,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      isRepeating: isRepeating ?? this.isRepeating,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedDays: selectedDays ?? this.selectedDays,
      learningStrategies: learningStrategies ?? this.learningStrategies,
      isPomodoro: isPomodoro ?? this.isPomodoro,
      totalTimeMin: totalTimeMin ?? this.totalTimeMin,
      focusTimeMin: focusTimeMin ?? this.focusTimeMin,
      breakTimeMin: breakTimeMin ?? this.breakTimeMin,
      longBreakTimeMin: longBreakTimeMin ?? this.longBreakTimeMin,
      cyclesBeforeLongBreak:
          cyclesBeforeLongBreak ?? this.cyclesBeforeLongBreak,
      hasFocusPrompt: hasFocusPrompt ?? this.hasFocusPrompt,
      hasMoodPrompt: hasMoodPrompt ?? this.hasMoodPrompt,
      hasFreetextPrompt: hasFreetextPrompt ?? this.hasFreetextPrompt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isRepeating.present) {
      map['is_repeating'] = Variable<bool>(isRepeating.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (selectedDays.present) {
      map['selected_days'] = Variable<String>(selectedDays.value);
    }
    if (learningStrategies.present) {
      map['learning_strategies'] = Variable<String>(learningStrategies.value);
    }
    if (isPomodoro.present) {
      map['is_pomodoro'] = Variable<bool>(isPomodoro.value);
    }
    if (totalTimeMin.present) {
      map['total_time_min'] = Variable<int>(totalTimeMin.value);
    }
    if (focusTimeMin.present) {
      map['focus_time_min'] = Variable<int>(focusTimeMin.value);
    }
    if (breakTimeMin.present) {
      map['break_time_min'] = Variable<int>(breakTimeMin.value);
    }
    if (longBreakTimeMin.present) {
      map['long_break_time_min'] = Variable<int>(longBreakTimeMin.value);
    }
    if (cyclesBeforeLongBreak.present) {
      map['cycles_before_long_break'] = Variable<int>(
        cyclesBeforeLongBreak.value,
      );
    }
    if (hasFocusPrompt.present) {
      map['has_focus_prompt'] = Variable<bool>(hasFocusPrompt.value);
    }
    if (hasMoodPrompt.present) {
      map['has_mood_prompt'] = Variable<bool>(hasMoodPrompt.value);
    }
    if (hasFreetextPrompt.present) {
      map['has_freetext_prompt'] = Variable<bool>(hasFreetextPrompt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isRepeating: $isRepeating, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('selectedDays: $selectedDays, ')
          ..write('learningStrategies: $learningStrategies, ')
          ..write('isPomodoro: $isPomodoro, ')
          ..write('totalTimeMin: $totalTimeMin, ')
          ..write('focusTimeMin: $focusTimeMin, ')
          ..write('breakTimeMin: $breakTimeMin, ')
          ..write('longBreakTimeMin: $longBreakTimeMin, ')
          ..write('cyclesBeforeLongBreak: $cyclesBeforeLongBreak, ')
          ..write('hasFocusPrompt: $hasFocusPrompt, ')
          ..write('hasMoodPrompt: $hasMoodPrompt, ')
          ..write('hasFreetextPrompt: $hasFreetextPrompt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    title,
    isCompleted,
    completedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final int sessionId;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  const Goal({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      title: Value(title),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Goal copyWith({
    int? id,
    int? sessionId,
    String? title,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Goal(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, title, isCompleted, completedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String title,
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       title = Value(title);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? title,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    goalId,
    title,
    isCompleted,
    completedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final int sessionId;
  final int? goalId;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.sessionId,
    this.goalId,
    required this.title,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<int>(goalId);
    }
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      goalId: goalId == null && nullToAbsent
          ? const Value.absent()
          : Value(goalId),
      title: Value(title),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      goalId: serializer.fromJson<int?>(json['goalId']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'goalId': serializer.toJson<int?>(goalId),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    int? sessionId,
    Value<int?> goalId = const Value.absent(),
    String? title,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    goalId: goalId.present ? goalId.value : this.goalId,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('goalId: $goalId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    goalId,
    title,
    isCompleted,
    completedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.goalId == this.goalId &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int?> goalId;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.goalId = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.goalId = const Value.absent(),
    required String title,
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       title = Value(title);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? goalId,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (goalId != null) 'goal_id': goalId,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int?>? goalId,
    Value<String>? title,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('goalId: $goalId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  late final GoalDao goalDao = GoalDao(this as AppDatabase);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions, goals, tasks];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required String title,
      Value<bool> isRepeating,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> selectedDays,
      Value<String?> learningStrategies,
      Value<bool> isPomodoro,
      Value<int?> totalTimeMin,
      Value<int?> focusTimeMin,
      Value<int?> breakTimeMin,
      Value<int?> longBreakTimeMin,
      Value<int?> cyclesBeforeLongBreak,
      Value<bool> hasFocusPrompt,
      Value<bool> hasMoodPrompt,
      Value<bool> hasFreetextPrompt,
      Value<DateTime> createdAt,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<bool> isRepeating,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> selectedDays,
      Value<String?> learningStrategies,
      Value<bool> isPomodoro,
      Value<int?> totalTimeMin,
      Value<int?> focusTimeMin,
      Value<int?> breakTimeMin,
      Value<int?> longBreakTimeMin,
      Value<int?> cyclesBeforeLongBreak,
      Value<bool> hasFocusPrompt,
      Value<bool> hasMoodPrompt,
      Value<bool> hasFreetextPrompt,
      Value<DateTime> createdAt,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GoalsTable, List<Goal>> _goalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.goals,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.goals.sessionId),
  );

  $$GoalsTableProcessedTableManager get goalsRefs {
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.tasks.sessionId),
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRepeating => $composableBuilder(
    column: $table.isRepeating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedDays => $composableBuilder(
    column: $table.selectedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningStrategies => $composableBuilder(
    column: $table.learningStrategies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPomodoro => $composableBuilder(
    column: $table.isPomodoro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTimeMin => $composableBuilder(
    column: $table.totalTimeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusTimeMin => $composableBuilder(
    column: $table.focusTimeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakTimeMin => $composableBuilder(
    column: $table.breakTimeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longBreakTimeMin => $composableBuilder(
    column: $table.longBreakTimeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cyclesBeforeLongBreak => $composableBuilder(
    column: $table.cyclesBeforeLongBreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasFocusPrompt => $composableBuilder(
    column: $table.hasFocusPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasMoodPrompt => $composableBuilder(
    column: $table.hasMoodPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasFreetextPrompt => $composableBuilder(
    column: $table.hasFreetextPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> goalsRefs(
    Expression<bool> Function($$GoalsTableFilterComposer f) f,
  ) {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRepeating => $composableBuilder(
    column: $table.isRepeating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedDays => $composableBuilder(
    column: $table.selectedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningStrategies => $composableBuilder(
    column: $table.learningStrategies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPomodoro => $composableBuilder(
    column: $table.isPomodoro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTimeMin => $composableBuilder(
    column: $table.totalTimeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusTimeMin => $composableBuilder(
    column: $table.focusTimeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakTimeMin => $composableBuilder(
    column: $table.breakTimeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longBreakTimeMin => $composableBuilder(
    column: $table.longBreakTimeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cyclesBeforeLongBreak => $composableBuilder(
    column: $table.cyclesBeforeLongBreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasFocusPrompt => $composableBuilder(
    column: $table.hasFocusPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasMoodPrompt => $composableBuilder(
    column: $table.hasMoodPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasFreetextPrompt => $composableBuilder(
    column: $table.hasFreetextPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isRepeating => $composableBuilder(
    column: $table.isRepeating,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get selectedDays => $composableBuilder(
    column: $table.selectedDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningStrategies => $composableBuilder(
    column: $table.learningStrategies,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPomodoro => $composableBuilder(
    column: $table.isPomodoro,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTimeMin => $composableBuilder(
    column: $table.totalTimeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focusTimeMin => $composableBuilder(
    column: $table.focusTimeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breakTimeMin => $composableBuilder(
    column: $table.breakTimeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longBreakTimeMin => $composableBuilder(
    column: $table.longBreakTimeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cyclesBeforeLongBreak => $composableBuilder(
    column: $table.cyclesBeforeLongBreak,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasFocusPrompt => $composableBuilder(
    column: $table.hasFocusPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasMoodPrompt => $composableBuilder(
    column: $table.hasMoodPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasFreetextPrompt => $composableBuilder(
    column: $table.hasFreetextPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> goalsRefs<T extends Object>(
    Expression<T> Function($$GoalsTableAnnotationComposer a) f,
  ) {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool goalsRefs, bool tasksRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isRepeating = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> selectedDays = const Value.absent(),
                Value<String?> learningStrategies = const Value.absent(),
                Value<bool> isPomodoro = const Value.absent(),
                Value<int?> totalTimeMin = const Value.absent(),
                Value<int?> focusTimeMin = const Value.absent(),
                Value<int?> breakTimeMin = const Value.absent(),
                Value<int?> longBreakTimeMin = const Value.absent(),
                Value<int?> cyclesBeforeLongBreak = const Value.absent(),
                Value<bool> hasFocusPrompt = const Value.absent(),
                Value<bool> hasMoodPrompt = const Value.absent(),
                Value<bool> hasFreetextPrompt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                title: title,
                isRepeating: isRepeating,
                startDate: startDate,
                endDate: endDate,
                selectedDays: selectedDays,
                learningStrategies: learningStrategies,
                isPomodoro: isPomodoro,
                totalTimeMin: totalTimeMin,
                focusTimeMin: focusTimeMin,
                breakTimeMin: breakTimeMin,
                longBreakTimeMin: longBreakTimeMin,
                cyclesBeforeLongBreak: cyclesBeforeLongBreak,
                hasFocusPrompt: hasFocusPrompt,
                hasMoodPrompt: hasMoodPrompt,
                hasFreetextPrompt: hasFreetextPrompt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<bool> isRepeating = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> selectedDays = const Value.absent(),
                Value<String?> learningStrategies = const Value.absent(),
                Value<bool> isPomodoro = const Value.absent(),
                Value<int?> totalTimeMin = const Value.absent(),
                Value<int?> focusTimeMin = const Value.absent(),
                Value<int?> breakTimeMin = const Value.absent(),
                Value<int?> longBreakTimeMin = const Value.absent(),
                Value<int?> cyclesBeforeLongBreak = const Value.absent(),
                Value<bool> hasFocusPrompt = const Value.absent(),
                Value<bool> hasMoodPrompt = const Value.absent(),
                Value<bool> hasFreetextPrompt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                title: title,
                isRepeating: isRepeating,
                startDate: startDate,
                endDate: endDate,
                selectedDays: selectedDays,
                learningStrategies: learningStrategies,
                isPomodoro: isPomodoro,
                totalTimeMin: totalTimeMin,
                focusTimeMin: focusTimeMin,
                breakTimeMin: breakTimeMin,
                longBreakTimeMin: longBreakTimeMin,
                cyclesBeforeLongBreak: cyclesBeforeLongBreak,
                hasFocusPrompt: hasFocusPrompt,
                hasMoodPrompt: hasMoodPrompt,
                hasFreetextPrompt: hasFreetextPrompt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalsRefs = false, tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (goalsRefs) db.goals,
                if (tasksRefs) db.tasks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (goalsRefs)
                    await $_getPrefetchedData<Session, $SessionsTable, Goal>(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._goalsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionsTableReferences(db, table, p0).goalsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                  if (tasksRefs)
                    await $_getPrefetchedData<Session, $SessionsTable, Task>(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionsTableReferences(db, table, p0).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool goalsRefs, bool tasksRefs})
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String title,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> title,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
    });

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.goals.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: $_aliasNameGenerator(db.goals.id, db.tasks.goalId),
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({bool sessionId, bool tasksRefs})
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                sessionId: sessionId,
                title: title,
                isCompleted: isCompleted,
                completedAt: completedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String title,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                sessionId: sessionId,
                title: title,
                isCompleted: isCompleted,
                completedAt: completedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GoalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$GoalsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$GoalsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<Goal, $GoalsTable, Task>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences._tasksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$GoalsTableReferences(db, table, p0).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({bool sessionId, bool tasksRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required int sessionId,
      Value<int?> goalId,
      required String title,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int?> goalId,
      Value<String> title,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.tasks.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GoalsTable _goalIdTable(_$AppDatabase db) =>
      db.goals.createAlias($_aliasNameGenerator(db.tasks.goalId, db.goals.id));

  $$GoalsTableProcessedTableManager? get goalId {
    final $_column = $_itemColumn<int>('goal_id');
    if ($_column == null) return null;
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool sessionId, bool goalId})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int?> goalId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                sessionId: sessionId,
                goalId: goalId,
                title: title,
                isCompleted: isCompleted,
                completedAt: completedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<int?> goalId = const Value.absent(),
                required String title,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                sessionId: sessionId,
                goalId: goalId,
                title: title,
                isCompleted: isCompleted,
                completedAt: completedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$TasksTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (goalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalId,
                                referencedTable: $$TasksTableReferences
                                    ._goalIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._goalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool sessionId, bool goalId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
