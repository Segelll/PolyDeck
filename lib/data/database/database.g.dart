// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FavTable extends Fav with TableInfo<$FavTable, FavData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sentenceMeta =
      const VerificationMeta('sentence');
  @override
  late final GeneratedColumn<String> sentence = GeneratedColumn<String>(
      'sentence', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isSeenMeta = const VerificationMeta('isSeen');
  @override
  late final GeneratedColumn<int> isSeen = GeneratedColumn<int>(
      'is_seen', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _feedbackMeta =
      const VerificationMeta('feedback');
  @override
  late final GeneratedColumn<int> feedback = GeneratedColumn<int>(
      'feedback', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _backwordMeta =
      const VerificationMeta('backword');
  @override
  late final GeneratedColumn<String> backword = GeneratedColumn<String>(
      'backword', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _backsentenceMeta =
      const VerificationMeta('backsentence');
  @override
  late final GeneratedColumn<String> backsentence = GeneratedColumn<String>(
      'backsentence', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cardStateMeta =
      const VerificationMeta('cardState');
  @override
  late final GeneratedColumn<int> cardState = GeneratedColumn<int>(
      'card_state', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stabilityMeta =
      const VerificationMeta('stability');
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
      'stability', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<String> due = GeneratedColumn<String>(
      'due', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _elapsedDaysMeta =
      const VerificationMeta('elapsedDays');
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
      'elapsed_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _scheduledDaysMeta =
      const VerificationMeta('scheduledDays');
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
      'scheduled_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
      'lapses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastReviewMeta =
      const VerificationMeta('lastReview');
  @override
  late final GeneratedColumn<String> lastReview = GeneratedColumn<String>(
      'last_review', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        word,
        sentence,
        level,
        isSeen,
        feedback,
        date,
        backword,
        backsentence,
        cardState,
        stability,
        difficulty,
        due,
        elapsedDays,
        scheduledDays,
        reps,
        lapses,
        lastReview
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fav';
  @override
  VerificationContext validateIntegrity(Insertable<FavData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('sentence')) {
      context.handle(_sentenceMeta,
          sentence.isAcceptableOrUnknown(data['sentence']!, _sentenceMeta));
    } else if (isInserting) {
      context.missing(_sentenceMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('is_seen')) {
      context.handle(_isSeenMeta,
          isSeen.isAcceptableOrUnknown(data['is_seen']!, _isSeenMeta));
    }
    if (data.containsKey('feedback')) {
      context.handle(_feedbackMeta,
          feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('backword')) {
      context.handle(_backwordMeta,
          backword.isAcceptableOrUnknown(data['backword']!, _backwordMeta));
    }
    if (data.containsKey('backsentence')) {
      context.handle(
          _backsentenceMeta,
          backsentence.isAcceptableOrUnknown(
              data['backsentence']!, _backsentenceMeta));
    }
    if (data.containsKey('card_state')) {
      context.handle(_cardStateMeta,
          cardState.isAcceptableOrUnknown(data['card_state']!, _cardStateMeta));
    }
    if (data.containsKey('stability')) {
      context.handle(_stabilityMeta,
          stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('due')) {
      context.handle(
          _dueMeta, due.isAcceptableOrUnknown(data['due']!, _dueMeta));
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
          _elapsedDaysMeta,
          elapsedDays.isAcceptableOrUnknown(
              data['elapsed_days']!, _elapsedDaysMeta));
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
          _scheduledDaysMeta,
          scheduledDays.isAcceptableOrUnknown(
              data['scheduled_days']!, _scheduledDaysMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('lapses')) {
      context.handle(_lapsesMeta,
          lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta));
    }
    if (data.containsKey('last_review')) {
      context.handle(
          _lastReviewMeta,
          lastReview.isAcceptableOrUnknown(
              data['last_review']!, _lastReviewMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      sentence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sentence'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      isSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_seen'])!,
      feedback: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}feedback'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date']),
      backword: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backword']),
      backsentence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backsentence']),
      cardState: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_state'])!,
      stability: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stability'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}difficulty'])!,
      due: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due']),
      elapsedDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}elapsed_days'])!,
      scheduledDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_days'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      lapses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lapses'])!,
      lastReview: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_review']),
    );
  }

  @override
  $FavTable createAlias(String alias) {
    return $FavTable(attachedDatabase, alias);
  }
}

class FavData extends DataClass implements Insertable<FavData> {
  final int id;
  final String word;
  final String sentence;
  final String level;
  final int isSeen;
  final int feedback;
  final String? date;
  final String? backword;
  final String? backsentence;
  final int cardState;
  final double stability;
  final double difficulty;
  final String? due;
  final int elapsedDays;
  final int scheduledDays;
  final int reps;
  final int lapses;
  final String? lastReview;
  const FavData(
      {required this.id,
      required this.word,
      required this.sentence,
      required this.level,
      required this.isSeen,
      required this.feedback,
      this.date,
      this.backword,
      this.backsentence,
      required this.cardState,
      required this.stability,
      required this.difficulty,
      this.due,
      required this.elapsedDays,
      required this.scheduledDays,
      required this.reps,
      required this.lapses,
      this.lastReview});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    map['sentence'] = Variable<String>(sentence);
    map['level'] = Variable<String>(level);
    map['is_seen'] = Variable<int>(isSeen);
    map['feedback'] = Variable<int>(feedback);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    if (!nullToAbsent || backword != null) {
      map['backword'] = Variable<String>(backword);
    }
    if (!nullToAbsent || backsentence != null) {
      map['backsentence'] = Variable<String>(backsentence);
    }
    map['card_state'] = Variable<int>(cardState);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    if (!nullToAbsent || due != null) {
      map['due'] = Variable<String>(due);
    }
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<String>(lastReview);
    }
    return map;
  }

  FavCompanion toCompanion(bool nullToAbsent) {
    return FavCompanion(
      id: Value(id),
      word: Value(word),
      sentence: Value(sentence),
      level: Value(level),
      isSeen: Value(isSeen),
      feedback: Value(feedback),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      backword: backword == null && nullToAbsent
          ? const Value.absent()
          : Value(backword),
      backsentence: backsentence == null && nullToAbsent
          ? const Value.absent()
          : Value(backsentence),
      cardState: Value(cardState),
      stability: Value(stability),
      difficulty: Value(difficulty),
      due: due == null && nullToAbsent ? const Value.absent() : Value(due),
      elapsedDays: Value(elapsedDays),
      scheduledDays: Value(scheduledDays),
      reps: Value(reps),
      lapses: Value(lapses),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
    );
  }

  factory FavData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavData(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      sentence: serializer.fromJson<String>(json['sentence']),
      level: serializer.fromJson<String>(json['level']),
      isSeen: serializer.fromJson<int>(json['isSeen']),
      feedback: serializer.fromJson<int>(json['feedback']),
      date: serializer.fromJson<String?>(json['date']),
      backword: serializer.fromJson<String?>(json['backword']),
      backsentence: serializer.fromJson<String?>(json['backsentence']),
      cardState: serializer.fromJson<int>(json['cardState']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      due: serializer.fromJson<String?>(json['due']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      lastReview: serializer.fromJson<String?>(json['lastReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'sentence': serializer.toJson<String>(sentence),
      'level': serializer.toJson<String>(level),
      'isSeen': serializer.toJson<int>(isSeen),
      'feedback': serializer.toJson<int>(feedback),
      'date': serializer.toJson<String?>(date),
      'backword': serializer.toJson<String?>(backword),
      'backsentence': serializer.toJson<String?>(backsentence),
      'cardState': serializer.toJson<int>(cardState),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'due': serializer.toJson<String?>(due),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'lastReview': serializer.toJson<String?>(lastReview),
    };
  }

  FavData copyWith(
          {int? id,
          String? word,
          String? sentence,
          String? level,
          int? isSeen,
          int? feedback,
          Value<String?> date = const Value.absent(),
          Value<String?> backword = const Value.absent(),
          Value<String?> backsentence = const Value.absent(),
          int? cardState,
          double? stability,
          double? difficulty,
          Value<String?> due = const Value.absent(),
          int? elapsedDays,
          int? scheduledDays,
          int? reps,
          int? lapses,
          Value<String?> lastReview = const Value.absent()}) =>
      FavData(
        id: id ?? this.id,
        word: word ?? this.word,
        sentence: sentence ?? this.sentence,
        level: level ?? this.level,
        isSeen: isSeen ?? this.isSeen,
        feedback: feedback ?? this.feedback,
        date: date.present ? date.value : this.date,
        backword: backword.present ? backword.value : this.backword,
        backsentence:
            backsentence.present ? backsentence.value : this.backsentence,
        cardState: cardState ?? this.cardState,
        stability: stability ?? this.stability,
        difficulty: difficulty ?? this.difficulty,
        due: due.present ? due.value : this.due,
        elapsedDays: elapsedDays ?? this.elapsedDays,
        scheduledDays: scheduledDays ?? this.scheduledDays,
        reps: reps ?? this.reps,
        lapses: lapses ?? this.lapses,
        lastReview: lastReview.present ? lastReview.value : this.lastReview,
      );
  FavData copyWithCompanion(FavCompanion data) {
    return FavData(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      sentence: data.sentence.present ? data.sentence.value : this.sentence,
      level: data.level.present ? data.level.value : this.level,
      isSeen: data.isSeen.present ? data.isSeen.value : this.isSeen,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      date: data.date.present ? data.date.value : this.date,
      backword: data.backword.present ? data.backword.value : this.backword,
      backsentence: data.backsentence.present
          ? data.backsentence.value
          : this.backsentence,
      cardState: data.cardState.present ? data.cardState.value : this.cardState,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      due: data.due.present ? data.due.value : this.due,
      elapsedDays:
          data.elapsedDays.present ? data.elapsedDays.value : this.elapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      lastReview:
          data.lastReview.present ? data.lastReview.value : this.lastReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavData(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('sentence: $sentence, ')
          ..write('level: $level, ')
          ..write('isSeen: $isSeen, ')
          ..write('feedback: $feedback, ')
          ..write('date: $date, ')
          ..write('backword: $backword, ')
          ..write('backsentence: $backsentence, ')
          ..write('cardState: $cardState, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('due: $due, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('lastReview: $lastReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      word,
      sentence,
      level,
      isSeen,
      feedback,
      date,
      backword,
      backsentence,
      cardState,
      stability,
      difficulty,
      due,
      elapsedDays,
      scheduledDays,
      reps,
      lapses,
      lastReview);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavData &&
          other.id == this.id &&
          other.word == this.word &&
          other.sentence == this.sentence &&
          other.level == this.level &&
          other.isSeen == this.isSeen &&
          other.feedback == this.feedback &&
          other.date == this.date &&
          other.backword == this.backword &&
          other.backsentence == this.backsentence &&
          other.cardState == this.cardState &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.due == this.due &&
          other.elapsedDays == this.elapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.lastReview == this.lastReview);
}

class FavCompanion extends UpdateCompanion<FavData> {
  final Value<int> id;
  final Value<String> word;
  final Value<String> sentence;
  final Value<String> level;
  final Value<int> isSeen;
  final Value<int> feedback;
  final Value<String?> date;
  final Value<String?> backword;
  final Value<String?> backsentence;
  final Value<int> cardState;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<String?> due;
  final Value<int> elapsedDays;
  final Value<int> scheduledDays;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<String?> lastReview;
  const FavCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.sentence = const Value.absent(),
    this.level = const Value.absent(),
    this.isSeen = const Value.absent(),
    this.feedback = const Value.absent(),
    this.date = const Value.absent(),
    this.backword = const Value.absent(),
    this.backsentence = const Value.absent(),
    this.cardState = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.due = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.lastReview = const Value.absent(),
  });
  FavCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    required String sentence,
    required String level,
    this.isSeen = const Value.absent(),
    this.feedback = const Value.absent(),
    this.date = const Value.absent(),
    this.backword = const Value.absent(),
    this.backsentence = const Value.absent(),
    this.cardState = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.due = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.lastReview = const Value.absent(),
  })  : word = Value(word),
        sentence = Value(sentence),
        level = Value(level);
  static Insertable<FavData> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? sentence,
    Expression<String>? level,
    Expression<int>? isSeen,
    Expression<int>? feedback,
    Expression<String>? date,
    Expression<String>? backword,
    Expression<String>? backsentence,
    Expression<int>? cardState,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<String>? due,
    Expression<int>? elapsedDays,
    Expression<int>? scheduledDays,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<String>? lastReview,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (sentence != null) 'sentence': sentence,
      if (level != null) 'level': level,
      if (isSeen != null) 'is_seen': isSeen,
      if (feedback != null) 'feedback': feedback,
      if (date != null) 'date': date,
      if (backword != null) 'backword': backword,
      if (backsentence != null) 'backsentence': backsentence,
      if (cardState != null) 'card_state': cardState,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (due != null) 'due': due,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (lastReview != null) 'last_review': lastReview,
    });
  }

  FavCompanion copyWith(
      {Value<int>? id,
      Value<String>? word,
      Value<String>? sentence,
      Value<String>? level,
      Value<int>? isSeen,
      Value<int>? feedback,
      Value<String?>? date,
      Value<String?>? backword,
      Value<String?>? backsentence,
      Value<int>? cardState,
      Value<double>? stability,
      Value<double>? difficulty,
      Value<String?>? due,
      Value<int>? elapsedDays,
      Value<int>? scheduledDays,
      Value<int>? reps,
      Value<int>? lapses,
      Value<String?>? lastReview}) {
    return FavCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      sentence: sentence ?? this.sentence,
      level: level ?? this.level,
      isSeen: isSeen ?? this.isSeen,
      feedback: feedback ?? this.feedback,
      date: date ?? this.date,
      backword: backword ?? this.backword,
      backsentence: backsentence ?? this.backsentence,
      cardState: cardState ?? this.cardState,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (sentence.present) {
      map['sentence'] = Variable<String>(sentence.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (isSeen.present) {
      map['is_seen'] = Variable<int>(isSeen.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<int>(feedback.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (backword.present) {
      map['backword'] = Variable<String>(backword.value);
    }
    if (backsentence.present) {
      map['backsentence'] = Variable<String>(backsentence.value);
    }
    if (cardState.present) {
      map['card_state'] = Variable<int>(cardState.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (due.present) {
      map['due'] = Variable<String>(due.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<String>(lastReview.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('sentence: $sentence, ')
          ..write('level: $level, ')
          ..write('isSeen: $isSeen, ')
          ..write('feedback: $feedback, ')
          ..write('date: $date, ')
          ..write('backword: $backword, ')
          ..write('backsentence: $backsentence, ')
          ..write('cardState: $cardState, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('due: $due, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('lastReview: $lastReview')
          ..write(')'))
        .toString();
  }
}

class $RevlogEntriesTable extends RevlogEntries
    with TableInfo<$RevlogEntriesTable, RevlogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevlogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
      'card_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deckTableMeta =
      const VerificationMeta('deckTable');
  @override
  late final GeneratedColumn<String> deckTable = GeneratedColumn<String>(
      'deck_table', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
      'state', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<String> due = GeneratedColumn<String>(
      'due', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stabilityMeta =
      const VerificationMeta('stability');
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
      'stability', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _elapsedDaysMeta =
      const VerificationMeta('elapsedDays');
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
      'elapsed_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastElapsedDaysMeta =
      const VerificationMeta('lastElapsedDays');
  @override
  late final GeneratedColumn<int> lastElapsedDays = GeneratedColumn<int>(
      'last_elapsed_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _scheduledDaysMeta =
      const VerificationMeta('scheduledDays');
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
      'scheduled_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reviewDateMeta =
      const VerificationMeta('reviewDate');
  @override
  late final GeneratedColumn<String> reviewDate = GeneratedColumn<String>(
      'review_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cardId,
        deckTable,
        rating,
        state,
        due,
        stability,
        difficulty,
        elapsedDays,
        lastElapsedDays,
        scheduledDays,
        reviewDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revlog';
  @override
  VerificationContext validateIntegrity(Insertable<RevlogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('deck_table')) {
      context.handle(_deckTableMeta,
          deckTable.isAcceptableOrUnknown(data['deck_table']!, _deckTableMeta));
    } else if (isInserting) {
      context.missing(_deckTableMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
          _dueMeta, due.isAcceptableOrUnknown(data['due']!, _dueMeta));
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(_stabilityMeta,
          stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta));
    } else if (isInserting) {
      context.missing(_stabilityMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
          _elapsedDaysMeta,
          elapsedDays.isAcceptableOrUnknown(
              data['elapsed_days']!, _elapsedDaysMeta));
    } else if (isInserting) {
      context.missing(_elapsedDaysMeta);
    }
    if (data.containsKey('last_elapsed_days')) {
      context.handle(
          _lastElapsedDaysMeta,
          lastElapsedDays.isAcceptableOrUnknown(
              data['last_elapsed_days']!, _lastElapsedDaysMeta));
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
          _scheduledDaysMeta,
          scheduledDays.isAcceptableOrUnknown(
              data['scheduled_days']!, _scheduledDaysMeta));
    } else if (isInserting) {
      context.missing(_scheduledDaysMeta);
    }
    if (data.containsKey('review_date')) {
      context.handle(
          _reviewDateMeta,
          reviewDate.isAcceptableOrUnknown(
              data['review_date']!, _reviewDateMeta));
    } else if (isInserting) {
      context.missing(_reviewDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RevlogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RevlogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_id'])!,
      deckTable: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_table'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}state'])!,
      due: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due'])!,
      stability: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stability'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}difficulty'])!,
      elapsedDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}elapsed_days'])!,
      lastElapsedDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_elapsed_days'])!,
      scheduledDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_days'])!,
      reviewDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}review_date'])!,
    );
  }

  @override
  $RevlogEntriesTable createAlias(String alias) {
    return $RevlogEntriesTable(attachedDatabase, alias);
  }
}

class RevlogEntry extends DataClass implements Insertable<RevlogEntry> {
  final int id;
  final int cardId;
  final String deckTable;
  final int rating;
  final int state;
  final String due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final String reviewDate;
  const RevlogEntry(
      {required this.id,
      required this.cardId,
      required this.deckTable,
      required this.rating,
      required this.state,
      required this.due,
      required this.stability,
      required this.difficulty,
      required this.elapsedDays,
      required this.lastElapsedDays,
      required this.scheduledDays,
      required this.reviewDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['deck_table'] = Variable<String>(deckTable);
    map['rating'] = Variable<int>(rating);
    map['state'] = Variable<int>(state);
    map['due'] = Variable<String>(due);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['last_elapsed_days'] = Variable<int>(lastElapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['review_date'] = Variable<String>(reviewDate);
    return map;
  }

  RevlogEntriesCompanion toCompanion(bool nullToAbsent) {
    return RevlogEntriesCompanion(
      id: Value(id),
      cardId: Value(cardId),
      deckTable: Value(deckTable),
      rating: Value(rating),
      state: Value(state),
      due: Value(due),
      stability: Value(stability),
      difficulty: Value(difficulty),
      elapsedDays: Value(elapsedDays),
      lastElapsedDays: Value(lastElapsedDays),
      scheduledDays: Value(scheduledDays),
      reviewDate: Value(reviewDate),
    );
  }

  factory RevlogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RevlogEntry(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      deckTable: serializer.fromJson<String>(json['deckTable']),
      rating: serializer.fromJson<int>(json['rating']),
      state: serializer.fromJson<int>(json['state']),
      due: serializer.fromJson<String>(json['due']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      lastElapsedDays: serializer.fromJson<int>(json['lastElapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      reviewDate: serializer.fromJson<String>(json['reviewDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'deckTable': serializer.toJson<String>(deckTable),
      'rating': serializer.toJson<int>(rating),
      'state': serializer.toJson<int>(state),
      'due': serializer.toJson<String>(due),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'lastElapsedDays': serializer.toJson<int>(lastElapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'reviewDate': serializer.toJson<String>(reviewDate),
    };
  }

  RevlogEntry copyWith(
          {int? id,
          int? cardId,
          String? deckTable,
          int? rating,
          int? state,
          String? due,
          double? stability,
          double? difficulty,
          int? elapsedDays,
          int? lastElapsedDays,
          int? scheduledDays,
          String? reviewDate}) =>
      RevlogEntry(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        deckTable: deckTable ?? this.deckTable,
        rating: rating ?? this.rating,
        state: state ?? this.state,
        due: due ?? this.due,
        stability: stability ?? this.stability,
        difficulty: difficulty ?? this.difficulty,
        elapsedDays: elapsedDays ?? this.elapsedDays,
        lastElapsedDays: lastElapsedDays ?? this.lastElapsedDays,
        scheduledDays: scheduledDays ?? this.scheduledDays,
        reviewDate: reviewDate ?? this.reviewDate,
      );
  RevlogEntry copyWithCompanion(RevlogEntriesCompanion data) {
    return RevlogEntry(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      deckTable: data.deckTable.present ? data.deckTable.value : this.deckTable,
      rating: data.rating.present ? data.rating.value : this.rating,
      state: data.state.present ? data.state.value : this.state,
      due: data.due.present ? data.due.value : this.due,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      elapsedDays:
          data.elapsedDays.present ? data.elapsedDays.value : this.elapsedDays,
      lastElapsedDays: data.lastElapsedDays.present
          ? data.lastElapsedDays.value
          : this.lastElapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      reviewDate:
          data.reviewDate.present ? data.reviewDate.value : this.reviewDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RevlogEntry(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('deckTable: $deckTable, ')
          ..write('rating: $rating, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('lastElapsedDays: $lastElapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reviewDate: $reviewDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cardId,
      deckTable,
      rating,
      state,
      due,
      stability,
      difficulty,
      elapsedDays,
      lastElapsedDays,
      scheduledDays,
      reviewDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RevlogEntry &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.deckTable == this.deckTable &&
          other.rating == this.rating &&
          other.state == this.state &&
          other.due == this.due &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.elapsedDays == this.elapsedDays &&
          other.lastElapsedDays == this.lastElapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.reviewDate == this.reviewDate);
}

class RevlogEntriesCompanion extends UpdateCompanion<RevlogEntry> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> deckTable;
  final Value<int> rating;
  final Value<int> state;
  final Value<String> due;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> elapsedDays;
  final Value<int> lastElapsedDays;
  final Value<int> scheduledDays;
  final Value<String> reviewDate;
  const RevlogEntriesCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.deckTable = const Value.absent(),
    this.rating = const Value.absent(),
    this.state = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.lastElapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reviewDate = const Value.absent(),
  });
  RevlogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String deckTable,
    required int rating,
    required int state,
    required String due,
    required double stability,
    required double difficulty,
    required int elapsedDays,
    this.lastElapsedDays = const Value.absent(),
    required int scheduledDays,
    required String reviewDate,
  })  : cardId = Value(cardId),
        deckTable = Value(deckTable),
        rating = Value(rating),
        state = Value(state),
        due = Value(due),
        stability = Value(stability),
        difficulty = Value(difficulty),
        elapsedDays = Value(elapsedDays),
        scheduledDays = Value(scheduledDays),
        reviewDate = Value(reviewDate);
  static Insertable<RevlogEntry> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? deckTable,
    Expression<int>? rating,
    Expression<int>? state,
    Expression<String>? due,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? elapsedDays,
    Expression<int>? lastElapsedDays,
    Expression<int>? scheduledDays,
    Expression<String>? reviewDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (deckTable != null) 'deck_table': deckTable,
      if (rating != null) 'rating': rating,
      if (state != null) 'state': state,
      if (due != null) 'due': due,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (lastElapsedDays != null) 'last_elapsed_days': lastElapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (reviewDate != null) 'review_date': reviewDate,
    });
  }

  RevlogEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? cardId,
      Value<String>? deckTable,
      Value<int>? rating,
      Value<int>? state,
      Value<String>? due,
      Value<double>? stability,
      Value<double>? difficulty,
      Value<int>? elapsedDays,
      Value<int>? lastElapsedDays,
      Value<int>? scheduledDays,
      Value<String>? reviewDate}) {
    return RevlogEntriesCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      deckTable: deckTable ?? this.deckTable,
      rating: rating ?? this.rating,
      state: state ?? this.state,
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      lastElapsedDays: lastElapsedDays ?? this.lastElapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reviewDate: reviewDate ?? this.reviewDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (deckTable.present) {
      map['deck_table'] = Variable<String>(deckTable.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (due.present) {
      map['due'] = Variable<String>(due.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (lastElapsedDays.present) {
      map['last_elapsed_days'] = Variable<int>(lastElapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (reviewDate.present) {
      map['review_date'] = Variable<String>(reviewDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevlogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('deckTable: $deckTable, ')
          ..write('rating: $rating, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('lastElapsedDays: $lastElapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reviewDate: $reviewDate')
          ..write(')'))
        .toString();
  }
}

class $DeckConfigsTable extends DeckConfigs
    with TableInfo<$DeckConfigsTable, DeckConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _maxNewPerDayMeta =
      const VerificationMeta('maxNewPerDay');
  @override
  late final GeneratedColumn<int> maxNewPerDay = GeneratedColumn<int>(
      'max_new_per_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _maxReviewsPerDayMeta =
      const VerificationMeta('maxReviewsPerDay');
  @override
  late final GeneratedColumn<int> maxReviewsPerDay = GeneratedColumn<int>(
      'max_reviews_per_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _learningStepsMeta =
      const VerificationMeta('learningSteps');
  @override
  late final GeneratedColumn<String> learningSteps = GeneratedColumn<String>(
      'learning_steps', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[1,10]'));
  static const VerificationMeta _enableFuzzMeta =
      const VerificationMeta('enableFuzz');
  @override
  late final GeneratedColumn<int> enableFuzz = GeneratedColumn<int>(
      'enable_fuzz', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _requestRetentionMeta =
      const VerificationMeta('requestRetention');
  @override
  late final GeneratedColumn<double> requestRetention = GeneratedColumn<double>(
      'request_retention', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.9));
  static const VerificationMeta _wMeta = const VerificationMeta('w');
  @override
  late final GeneratedColumn<String> w = GeneratedColumn<String>(
      'w', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        level,
        maxNewPerDay,
        maxReviewsPerDay,
        learningSteps,
        enableFuzz,
        requestRetention,
        w
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_config';
  @override
  VerificationContext validateIntegrity(Insertable<DeckConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('max_new_per_day')) {
      context.handle(
          _maxNewPerDayMeta,
          maxNewPerDay.isAcceptableOrUnknown(
              data['max_new_per_day']!, _maxNewPerDayMeta));
    }
    if (data.containsKey('max_reviews_per_day')) {
      context.handle(
          _maxReviewsPerDayMeta,
          maxReviewsPerDay.isAcceptableOrUnknown(
              data['max_reviews_per_day']!, _maxReviewsPerDayMeta));
    }
    if (data.containsKey('learning_steps')) {
      context.handle(
          _learningStepsMeta,
          learningSteps.isAcceptableOrUnknown(
              data['learning_steps']!, _learningStepsMeta));
    }
    if (data.containsKey('enable_fuzz')) {
      context.handle(
          _enableFuzzMeta,
          enableFuzz.isAcceptableOrUnknown(
              data['enable_fuzz']!, _enableFuzzMeta));
    }
    if (data.containsKey('request_retention')) {
      context.handle(
          _requestRetentionMeta,
          requestRetention.isAcceptableOrUnknown(
              data['request_retention']!, _requestRetentionMeta));
    }
    if (data.containsKey('w')) {
      context.handle(_wMeta, w.isAcceptableOrUnknown(data['w']!, _wMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {level};
  @override
  DeckConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckConfig(
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      maxNewPerDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_new_per_day'])!,
      maxReviewsPerDay: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}max_reviews_per_day'])!,
      learningSteps: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}learning_steps'])!,
      enableFuzz: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}enable_fuzz'])!,
      requestRetention: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}request_retention'])!,
      w: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}w']),
    );
  }

  @override
  $DeckConfigsTable createAlias(String alias) {
    return $DeckConfigsTable(attachedDatabase, alias);
  }
}

class DeckConfig extends DataClass implements Insertable<DeckConfig> {
  final String level;
  final int maxNewPerDay;
  final int maxReviewsPerDay;
  final String learningSteps;
  final int enableFuzz;
  final double requestRetention;
  final String? w;
  const DeckConfig(
      {required this.level,
      required this.maxNewPerDay,
      required this.maxReviewsPerDay,
      required this.learningSteps,
      required this.enableFuzz,
      required this.requestRetention,
      this.w});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['level'] = Variable<String>(level);
    map['max_new_per_day'] = Variable<int>(maxNewPerDay);
    map['max_reviews_per_day'] = Variable<int>(maxReviewsPerDay);
    map['learning_steps'] = Variable<String>(learningSteps);
    map['enable_fuzz'] = Variable<int>(enableFuzz);
    map['request_retention'] = Variable<double>(requestRetention);
    if (!nullToAbsent || w != null) {
      map['w'] = Variable<String>(w);
    }
    return map;
  }

  DeckConfigsCompanion toCompanion(bool nullToAbsent) {
    return DeckConfigsCompanion(
      level: Value(level),
      maxNewPerDay: Value(maxNewPerDay),
      maxReviewsPerDay: Value(maxReviewsPerDay),
      learningSteps: Value(learningSteps),
      enableFuzz: Value(enableFuzz),
      requestRetention: Value(requestRetention),
      w: w == null && nullToAbsent ? const Value.absent() : Value(w),
    );
  }

  factory DeckConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckConfig(
      level: serializer.fromJson<String>(json['level']),
      maxNewPerDay: serializer.fromJson<int>(json['maxNewPerDay']),
      maxReviewsPerDay: serializer.fromJson<int>(json['maxReviewsPerDay']),
      learningSteps: serializer.fromJson<String>(json['learningSteps']),
      enableFuzz: serializer.fromJson<int>(json['enableFuzz']),
      requestRetention: serializer.fromJson<double>(json['requestRetention']),
      w: serializer.fromJson<String?>(json['w']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'level': serializer.toJson<String>(level),
      'maxNewPerDay': serializer.toJson<int>(maxNewPerDay),
      'maxReviewsPerDay': serializer.toJson<int>(maxReviewsPerDay),
      'learningSteps': serializer.toJson<String>(learningSteps),
      'enableFuzz': serializer.toJson<int>(enableFuzz),
      'requestRetention': serializer.toJson<double>(requestRetention),
      'w': serializer.toJson<String?>(w),
    };
  }

  DeckConfig copyWith(
          {String? level,
          int? maxNewPerDay,
          int? maxReviewsPerDay,
          String? learningSteps,
          int? enableFuzz,
          double? requestRetention,
          Value<String?> w = const Value.absent()}) =>
      DeckConfig(
        level: level ?? this.level,
        maxNewPerDay: maxNewPerDay ?? this.maxNewPerDay,
        maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
        learningSteps: learningSteps ?? this.learningSteps,
        enableFuzz: enableFuzz ?? this.enableFuzz,
        requestRetention: requestRetention ?? this.requestRetention,
        w: w.present ? w.value : this.w,
      );
  DeckConfig copyWithCompanion(DeckConfigsCompanion data) {
    return DeckConfig(
      level: data.level.present ? data.level.value : this.level,
      maxNewPerDay: data.maxNewPerDay.present
          ? data.maxNewPerDay.value
          : this.maxNewPerDay,
      maxReviewsPerDay: data.maxReviewsPerDay.present
          ? data.maxReviewsPerDay.value
          : this.maxReviewsPerDay,
      learningSteps: data.learningSteps.present
          ? data.learningSteps.value
          : this.learningSteps,
      enableFuzz:
          data.enableFuzz.present ? data.enableFuzz.value : this.enableFuzz,
      requestRetention: data.requestRetention.present
          ? data.requestRetention.value
          : this.requestRetention,
      w: data.w.present ? data.w.value : this.w,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckConfig(')
          ..write('level: $level, ')
          ..write('maxNewPerDay: $maxNewPerDay, ')
          ..write('maxReviewsPerDay: $maxReviewsPerDay, ')
          ..write('learningSteps: $learningSteps, ')
          ..write('enableFuzz: $enableFuzz, ')
          ..write('requestRetention: $requestRetention, ')
          ..write('w: $w')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(level, maxNewPerDay, maxReviewsPerDay,
      learningSteps, enableFuzz, requestRetention, w);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckConfig &&
          other.level == this.level &&
          other.maxNewPerDay == this.maxNewPerDay &&
          other.maxReviewsPerDay == this.maxReviewsPerDay &&
          other.learningSteps == this.learningSteps &&
          other.enableFuzz == this.enableFuzz &&
          other.requestRetention == this.requestRetention &&
          other.w == this.w);
}

class DeckConfigsCompanion extends UpdateCompanion<DeckConfig> {
  final Value<String> level;
  final Value<int> maxNewPerDay;
  final Value<int> maxReviewsPerDay;
  final Value<String> learningSteps;
  final Value<int> enableFuzz;
  final Value<double> requestRetention;
  final Value<String?> w;
  final Value<int> rowid;
  const DeckConfigsCompanion({
    this.level = const Value.absent(),
    this.maxNewPerDay = const Value.absent(),
    this.maxReviewsPerDay = const Value.absent(),
    this.learningSteps = const Value.absent(),
    this.enableFuzz = const Value.absent(),
    this.requestRetention = const Value.absent(),
    this.w = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeckConfigsCompanion.insert({
    required String level,
    this.maxNewPerDay = const Value.absent(),
    this.maxReviewsPerDay = const Value.absent(),
    this.learningSteps = const Value.absent(),
    this.enableFuzz = const Value.absent(),
    this.requestRetention = const Value.absent(),
    this.w = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : level = Value(level);
  static Insertable<DeckConfig> custom({
    Expression<String>? level,
    Expression<int>? maxNewPerDay,
    Expression<int>? maxReviewsPerDay,
    Expression<String>? learningSteps,
    Expression<int>? enableFuzz,
    Expression<double>? requestRetention,
    Expression<String>? w,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (level != null) 'level': level,
      if (maxNewPerDay != null) 'max_new_per_day': maxNewPerDay,
      if (maxReviewsPerDay != null) 'max_reviews_per_day': maxReviewsPerDay,
      if (learningSteps != null) 'learning_steps': learningSteps,
      if (enableFuzz != null) 'enable_fuzz': enableFuzz,
      if (requestRetention != null) 'request_retention': requestRetention,
      if (w != null) 'w': w,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeckConfigsCompanion copyWith(
      {Value<String>? level,
      Value<int>? maxNewPerDay,
      Value<int>? maxReviewsPerDay,
      Value<String>? learningSteps,
      Value<int>? enableFuzz,
      Value<double>? requestRetention,
      Value<String?>? w,
      Value<int>? rowid}) {
    return DeckConfigsCompanion(
      level: level ?? this.level,
      maxNewPerDay: maxNewPerDay ?? this.maxNewPerDay,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
      learningSteps: learningSteps ?? this.learningSteps,
      enableFuzz: enableFuzz ?? this.enableFuzz,
      requestRetention: requestRetention ?? this.requestRetention,
      w: w ?? this.w,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (maxNewPerDay.present) {
      map['max_new_per_day'] = Variable<int>(maxNewPerDay.value);
    }
    if (maxReviewsPerDay.present) {
      map['max_reviews_per_day'] = Variable<int>(maxReviewsPerDay.value);
    }
    if (learningSteps.present) {
      map['learning_steps'] = Variable<String>(learningSteps.value);
    }
    if (enableFuzz.present) {
      map['enable_fuzz'] = Variable<int>(enableFuzz.value);
    }
    if (requestRetention.present) {
      map['request_retention'] = Variable<double>(requestRetention.value);
    }
    if (w.present) {
      map['w'] = Variable<String>(w.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckConfigsCompanion(')
          ..write('level: $level, ')
          ..write('maxNewPerDay: $maxNewPerDay, ')
          ..write('maxReviewsPerDay: $maxReviewsPerDay, ')
          ..write('learningSteps: $learningSteps, ')
          ..write('enableFuzz: $enableFuzz, ')
          ..write('requestRetention: $requestRetention, ')
          ..write('w: $w, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mainLanguageMeta =
      const VerificationMeta('mainLanguage');
  @override
  late final GeneratedColumn<String> mainLanguage = GeneratedColumn<String>(
      'mainLanguage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetLanguageMeta =
      const VerificationMeta('targetLanguage');
  @override
  late final GeneratedColumn<String> targetLanguage = GeneratedColumn<String>(
      'targetLanguage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstTimeMeta =
      const VerificationMeta('firstTime');
  @override
  late final GeneratedColumn<String> firstTime = GeneratedColumn<String>(
      'firstTime', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [mainLanguage, targetLanguage, firstTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mainLanguage')) {
      context.handle(
          _mainLanguageMeta,
          mainLanguage.isAcceptableOrUnknown(
              data['mainLanguage']!, _mainLanguageMeta));
    } else if (isInserting) {
      context.missing(_mainLanguageMeta);
    }
    if (data.containsKey('targetLanguage')) {
      context.handle(
          _targetLanguageMeta,
          targetLanguage.isAcceptableOrUnknown(
              data['targetLanguage']!, _targetLanguageMeta));
    } else if (isInserting) {
      context.missing(_targetLanguageMeta);
    }
    if (data.containsKey('firstTime')) {
      context.handle(_firstTimeMeta,
          firstTime.isAcceptableOrUnknown(data['firstTime']!, _firstTimeMeta));
    } else if (isInserting) {
      context.missing(_firstTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      mainLanguage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mainLanguage'])!,
      targetLanguage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}targetLanguage'])!,
      firstTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firstTime'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String mainLanguage;
  final String targetLanguage;
  final String firstTime;
  const UserSetting(
      {required this.mainLanguage,
      required this.targetLanguage,
      required this.firstTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mainLanguage'] = Variable<String>(mainLanguage);
    map['targetLanguage'] = Variable<String>(targetLanguage);
    map['firstTime'] = Variable<String>(firstTime);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      mainLanguage: Value(mainLanguage),
      targetLanguage: Value(targetLanguage),
      firstTime: Value(firstTime),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      mainLanguage: serializer.fromJson<String>(json['mainLanguage']),
      targetLanguage: serializer.fromJson<String>(json['targetLanguage']),
      firstTime: serializer.fromJson<String>(json['firstTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mainLanguage': serializer.toJson<String>(mainLanguage),
      'targetLanguage': serializer.toJson<String>(targetLanguage),
      'firstTime': serializer.toJson<String>(firstTime),
    };
  }

  UserSetting copyWith(
          {String? mainLanguage, String? targetLanguage, String? firstTime}) =>
      UserSetting(
        mainLanguage: mainLanguage ?? this.mainLanguage,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        firstTime: firstTime ?? this.firstTime,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      mainLanguage: data.mainLanguage.present
          ? data.mainLanguage.value
          : this.mainLanguage,
      targetLanguage: data.targetLanguage.present
          ? data.targetLanguage.value
          : this.targetLanguage,
      firstTime: data.firstTime.present ? data.firstTime.value : this.firstTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('mainLanguage: $mainLanguage, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('firstTime: $firstTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mainLanguage, targetLanguage, firstTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.mainLanguage == this.mainLanguage &&
          other.targetLanguage == this.targetLanguage &&
          other.firstTime == this.firstTime);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> mainLanguage;
  final Value<String> targetLanguage;
  final Value<String> firstTime;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.mainLanguage = const Value.absent(),
    this.targetLanguage = const Value.absent(),
    this.firstTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String mainLanguage,
    required String targetLanguage,
    required String firstTime,
    this.rowid = const Value.absent(),
  })  : mainLanguage = Value(mainLanguage),
        targetLanguage = Value(targetLanguage),
        firstTime = Value(firstTime);
  static Insertable<UserSetting> custom({
    Expression<String>? mainLanguage,
    Expression<String>? targetLanguage,
    Expression<String>? firstTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mainLanguage != null) 'mainLanguage': mainLanguage,
      if (targetLanguage != null) 'targetLanguage': targetLanguage,
      if (firstTime != null) 'firstTime': firstTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? mainLanguage,
      Value<String>? targetLanguage,
      Value<String>? firstTime,
      Value<int>? rowid}) {
    return UserSettingsCompanion(
      mainLanguage: mainLanguage ?? this.mainLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      firstTime: firstTime ?? this.firstTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mainLanguage.present) {
      map['mainLanguage'] = Variable<String>(mainLanguage.value);
    }
    if (targetLanguage.present) {
      map['targetLanguage'] = Variable<String>(targetLanguage.value);
    }
    if (firstTime.present) {
      map['firstTime'] = Variable<String>(firstTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('mainLanguage: $mainLanguage, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('firstTime: $firstTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FavTable fav = $FavTable(this);
  late final $RevlogEntriesTable revlogEntries = $RevlogEntriesTable(this);
  late final $DeckConfigsTable deckConfigs = $DeckConfigsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [fav, revlogEntries, deckConfigs, userSettings];
}

typedef $$FavTableCreateCompanionBuilder = FavCompanion Function({
  Value<int> id,
  required String word,
  required String sentence,
  required String level,
  Value<int> isSeen,
  Value<int> feedback,
  Value<String?> date,
  Value<String?> backword,
  Value<String?> backsentence,
  Value<int> cardState,
  Value<double> stability,
  Value<double> difficulty,
  Value<String?> due,
  Value<int> elapsedDays,
  Value<int> scheduledDays,
  Value<int> reps,
  Value<int> lapses,
  Value<String?> lastReview,
});
typedef $$FavTableUpdateCompanionBuilder = FavCompanion Function({
  Value<int> id,
  Value<String> word,
  Value<String> sentence,
  Value<String> level,
  Value<int> isSeen,
  Value<int> feedback,
  Value<String?> date,
  Value<String?> backword,
  Value<String?> backsentence,
  Value<int> cardState,
  Value<double> stability,
  Value<double> difficulty,
  Value<String?> due,
  Value<int> elapsedDays,
  Value<int> scheduledDays,
  Value<int> reps,
  Value<int> lapses,
  Value<String?> lastReview,
});

class $$FavTableFilterComposer extends Composer<_$AppDatabase, $FavTable> {
  $$FavTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sentence => $composableBuilder(
      column: $table.sentence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isSeen => $composableBuilder(
      column: $table.isSeen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get feedback => $composableBuilder(
      column: $table.feedback, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backword => $composableBuilder(
      column: $table.backword, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backsentence => $composableBuilder(
      column: $table.backsentence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardState => $composableBuilder(
      column: $table.cardState, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get due => $composableBuilder(
      column: $table.due, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lapses => $composableBuilder(
      column: $table.lapses, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastReview => $composableBuilder(
      column: $table.lastReview, builder: (column) => ColumnFilters(column));
}

class $$FavTableOrderingComposer extends Composer<_$AppDatabase, $FavTable> {
  $$FavTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sentence => $composableBuilder(
      column: $table.sentence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isSeen => $composableBuilder(
      column: $table.isSeen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get feedback => $composableBuilder(
      column: $table.feedback, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backword => $composableBuilder(
      column: $table.backword, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backsentence => $composableBuilder(
      column: $table.backsentence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardState => $composableBuilder(
      column: $table.cardState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get due => $composableBuilder(
      column: $table.due, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lapses => $composableBuilder(
      column: $table.lapses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastReview => $composableBuilder(
      column: $table.lastReview, builder: (column) => ColumnOrderings(column));
}

class $$FavTableAnnotationComposer extends Composer<_$AppDatabase, $FavTable> {
  $$FavTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get sentence =>
      $composableBuilder(column: $table.sentence, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get isSeen =>
      $composableBuilder(column: $table.isSeen, builder: (column) => column);

  GeneratedColumn<int> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get backword =>
      $composableBuilder(column: $table.backword, builder: (column) => column);

  GeneratedColumn<String> get backsentence => $composableBuilder(
      column: $table.backsentence, builder: (column) => column);

  GeneratedColumn<int> get cardState =>
      $composableBuilder(column: $table.cardState, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => column);

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<String> get lastReview => $composableBuilder(
      column: $table.lastReview, builder: (column) => column);
}

class $$FavTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavTable,
    FavData,
    $$FavTableFilterComposer,
    $$FavTableOrderingComposer,
    $$FavTableAnnotationComposer,
    $$FavTableCreateCompanionBuilder,
    $$FavTableUpdateCompanionBuilder,
    (FavData, BaseReferences<_$AppDatabase, $FavTable, FavData>),
    FavData,
    PrefetchHooks Function()> {
  $$FavTableTableManager(_$AppDatabase db, $FavTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<String> sentence = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<int> isSeen = const Value.absent(),
            Value<int> feedback = const Value.absent(),
            Value<String?> date = const Value.absent(),
            Value<String?> backword = const Value.absent(),
            Value<String?> backsentence = const Value.absent(),
            Value<int> cardState = const Value.absent(),
            Value<double> stability = const Value.absent(),
            Value<double> difficulty = const Value.absent(),
            Value<String?> due = const Value.absent(),
            Value<int> elapsedDays = const Value.absent(),
            Value<int> scheduledDays = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<int> lapses = const Value.absent(),
            Value<String?> lastReview = const Value.absent(),
          }) =>
              FavCompanion(
            id: id,
            word: word,
            sentence: sentence,
            level: level,
            isSeen: isSeen,
            feedback: feedback,
            date: date,
            backword: backword,
            backsentence: backsentence,
            cardState: cardState,
            stability: stability,
            difficulty: difficulty,
            due: due,
            elapsedDays: elapsedDays,
            scheduledDays: scheduledDays,
            reps: reps,
            lapses: lapses,
            lastReview: lastReview,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String word,
            required String sentence,
            required String level,
            Value<int> isSeen = const Value.absent(),
            Value<int> feedback = const Value.absent(),
            Value<String?> date = const Value.absent(),
            Value<String?> backword = const Value.absent(),
            Value<String?> backsentence = const Value.absent(),
            Value<int> cardState = const Value.absent(),
            Value<double> stability = const Value.absent(),
            Value<double> difficulty = const Value.absent(),
            Value<String?> due = const Value.absent(),
            Value<int> elapsedDays = const Value.absent(),
            Value<int> scheduledDays = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<int> lapses = const Value.absent(),
            Value<String?> lastReview = const Value.absent(),
          }) =>
              FavCompanion.insert(
            id: id,
            word: word,
            sentence: sentence,
            level: level,
            isSeen: isSeen,
            feedback: feedback,
            date: date,
            backword: backword,
            backsentence: backsentence,
            cardState: cardState,
            stability: stability,
            difficulty: difficulty,
            due: due,
            elapsedDays: elapsedDays,
            scheduledDays: scheduledDays,
            reps: reps,
            lapses: lapses,
            lastReview: lastReview,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavTable,
    FavData,
    $$FavTableFilterComposer,
    $$FavTableOrderingComposer,
    $$FavTableAnnotationComposer,
    $$FavTableCreateCompanionBuilder,
    $$FavTableUpdateCompanionBuilder,
    (FavData, BaseReferences<_$AppDatabase, $FavTable, FavData>),
    FavData,
    PrefetchHooks Function()>;
typedef $$RevlogEntriesTableCreateCompanionBuilder = RevlogEntriesCompanion
    Function({
  Value<int> id,
  required int cardId,
  required String deckTable,
  required int rating,
  required int state,
  required String due,
  required double stability,
  required double difficulty,
  required int elapsedDays,
  Value<int> lastElapsedDays,
  required int scheduledDays,
  required String reviewDate,
});
typedef $$RevlogEntriesTableUpdateCompanionBuilder = RevlogEntriesCompanion
    Function({
  Value<int> id,
  Value<int> cardId,
  Value<String> deckTable,
  Value<int> rating,
  Value<int> state,
  Value<String> due,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> elapsedDays,
  Value<int> lastElapsedDays,
  Value<int> scheduledDays,
  Value<String> reviewDate,
});

class $$RevlogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RevlogEntriesTable> {
  $$RevlogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckTable => $composableBuilder(
      column: $table.deckTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get due => $composableBuilder(
      column: $table.due, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastElapsedDays => $composableBuilder(
      column: $table.lastElapsedDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => ColumnFilters(column));
}

class $$RevlogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RevlogEntriesTable> {
  $$RevlogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckTable => $composableBuilder(
      column: $table.deckTable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get due => $composableBuilder(
      column: $table.due, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastElapsedDays => $composableBuilder(
      column: $table.lastElapsedDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => ColumnOrderings(column));
}

class $$RevlogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevlogEntriesTable> {
  $$RevlogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get deckTable =>
      $composableBuilder(column: $table.deckTable, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => column);

  GeneratedColumn<int> get lastElapsedDays => $composableBuilder(
      column: $table.lastElapsedDays, builder: (column) => column);

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays, builder: (column) => column);

  GeneratedColumn<String> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => column);
}

class $$RevlogEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RevlogEntriesTable,
    RevlogEntry,
    $$RevlogEntriesTableFilterComposer,
    $$RevlogEntriesTableOrderingComposer,
    $$RevlogEntriesTableAnnotationComposer,
    $$RevlogEntriesTableCreateCompanionBuilder,
    $$RevlogEntriesTableUpdateCompanionBuilder,
    (
      RevlogEntry,
      BaseReferences<_$AppDatabase, $RevlogEntriesTable, RevlogEntry>
    ),
    RevlogEntry,
    PrefetchHooks Function()> {
  $$RevlogEntriesTableTableManager(_$AppDatabase db, $RevlogEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevlogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevlogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevlogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> cardId = const Value.absent(),
            Value<String> deckTable = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<int> state = const Value.absent(),
            Value<String> due = const Value.absent(),
            Value<double> stability = const Value.absent(),
            Value<double> difficulty = const Value.absent(),
            Value<int> elapsedDays = const Value.absent(),
            Value<int> lastElapsedDays = const Value.absent(),
            Value<int> scheduledDays = const Value.absent(),
            Value<String> reviewDate = const Value.absent(),
          }) =>
              RevlogEntriesCompanion(
            id: id,
            cardId: cardId,
            deckTable: deckTable,
            rating: rating,
            state: state,
            due: due,
            stability: stability,
            difficulty: difficulty,
            elapsedDays: elapsedDays,
            lastElapsedDays: lastElapsedDays,
            scheduledDays: scheduledDays,
            reviewDate: reviewDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int cardId,
            required String deckTable,
            required int rating,
            required int state,
            required String due,
            required double stability,
            required double difficulty,
            required int elapsedDays,
            Value<int> lastElapsedDays = const Value.absent(),
            required int scheduledDays,
            required String reviewDate,
          }) =>
              RevlogEntriesCompanion.insert(
            id: id,
            cardId: cardId,
            deckTable: deckTable,
            rating: rating,
            state: state,
            due: due,
            stability: stability,
            difficulty: difficulty,
            elapsedDays: elapsedDays,
            lastElapsedDays: lastElapsedDays,
            scheduledDays: scheduledDays,
            reviewDate: reviewDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RevlogEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RevlogEntriesTable,
    RevlogEntry,
    $$RevlogEntriesTableFilterComposer,
    $$RevlogEntriesTableOrderingComposer,
    $$RevlogEntriesTableAnnotationComposer,
    $$RevlogEntriesTableCreateCompanionBuilder,
    $$RevlogEntriesTableUpdateCompanionBuilder,
    (
      RevlogEntry,
      BaseReferences<_$AppDatabase, $RevlogEntriesTable, RevlogEntry>
    ),
    RevlogEntry,
    PrefetchHooks Function()>;
typedef $$DeckConfigsTableCreateCompanionBuilder = DeckConfigsCompanion
    Function({
  required String level,
  Value<int> maxNewPerDay,
  Value<int> maxReviewsPerDay,
  Value<String> learningSteps,
  Value<int> enableFuzz,
  Value<double> requestRetention,
  Value<String?> w,
  Value<int> rowid,
});
typedef $$DeckConfigsTableUpdateCompanionBuilder = DeckConfigsCompanion
    Function({
  Value<String> level,
  Value<int> maxNewPerDay,
  Value<int> maxReviewsPerDay,
  Value<String> learningSteps,
  Value<int> enableFuzz,
  Value<double> requestRetention,
  Value<String?> w,
  Value<int> rowid,
});

class $$DeckConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $DeckConfigsTable> {
  $$DeckConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxNewPerDay => $composableBuilder(
      column: $table.maxNewPerDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxReviewsPerDay => $composableBuilder(
      column: $table.maxReviewsPerDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get learningSteps => $composableBuilder(
      column: $table.learningSteps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get enableFuzz => $composableBuilder(
      column: $table.enableFuzz, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get requestRetention => $composableBuilder(
      column: $table.requestRetention,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get w => $composableBuilder(
      column: $table.w, builder: (column) => ColumnFilters(column));
}

class $$DeckConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckConfigsTable> {
  $$DeckConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxNewPerDay => $composableBuilder(
      column: $table.maxNewPerDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxReviewsPerDay => $composableBuilder(
      column: $table.maxReviewsPerDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get learningSteps => $composableBuilder(
      column: $table.learningSteps,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get enableFuzz => $composableBuilder(
      column: $table.enableFuzz, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get requestRetention => $composableBuilder(
      column: $table.requestRetention,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get w => $composableBuilder(
      column: $table.w, builder: (column) => ColumnOrderings(column));
}

class $$DeckConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckConfigsTable> {
  $$DeckConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get maxNewPerDay => $composableBuilder(
      column: $table.maxNewPerDay, builder: (column) => column);

  GeneratedColumn<int> get maxReviewsPerDay => $composableBuilder(
      column: $table.maxReviewsPerDay, builder: (column) => column);

  GeneratedColumn<String> get learningSteps => $composableBuilder(
      column: $table.learningSteps, builder: (column) => column);

  GeneratedColumn<int> get enableFuzz => $composableBuilder(
      column: $table.enableFuzz, builder: (column) => column);

  GeneratedColumn<double> get requestRetention => $composableBuilder(
      column: $table.requestRetention, builder: (column) => column);

  GeneratedColumn<String> get w =>
      $composableBuilder(column: $table.w, builder: (column) => column);
}

class $$DeckConfigsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeckConfigsTable,
    DeckConfig,
    $$DeckConfigsTableFilterComposer,
    $$DeckConfigsTableOrderingComposer,
    $$DeckConfigsTableAnnotationComposer,
    $$DeckConfigsTableCreateCompanionBuilder,
    $$DeckConfigsTableUpdateCompanionBuilder,
    (DeckConfig, BaseReferences<_$AppDatabase, $DeckConfigsTable, DeckConfig>),
    DeckConfig,
    PrefetchHooks Function()> {
  $$DeckConfigsTableTableManager(_$AppDatabase db, $DeckConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> level = const Value.absent(),
            Value<int> maxNewPerDay = const Value.absent(),
            Value<int> maxReviewsPerDay = const Value.absent(),
            Value<String> learningSteps = const Value.absent(),
            Value<int> enableFuzz = const Value.absent(),
            Value<double> requestRetention = const Value.absent(),
            Value<String?> w = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeckConfigsCompanion(
            level: level,
            maxNewPerDay: maxNewPerDay,
            maxReviewsPerDay: maxReviewsPerDay,
            learningSteps: learningSteps,
            enableFuzz: enableFuzz,
            requestRetention: requestRetention,
            w: w,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String level,
            Value<int> maxNewPerDay = const Value.absent(),
            Value<int> maxReviewsPerDay = const Value.absent(),
            Value<String> learningSteps = const Value.absent(),
            Value<int> enableFuzz = const Value.absent(),
            Value<double> requestRetention = const Value.absent(),
            Value<String?> w = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeckConfigsCompanion.insert(
            level: level,
            maxNewPerDay: maxNewPerDay,
            maxReviewsPerDay: maxReviewsPerDay,
            learningSteps: learningSteps,
            enableFuzz: enableFuzz,
            requestRetention: requestRetention,
            w: w,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeckConfigsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeckConfigsTable,
    DeckConfig,
    $$DeckConfigsTableFilterComposer,
    $$DeckConfigsTableOrderingComposer,
    $$DeckConfigsTableAnnotationComposer,
    $$DeckConfigsTableCreateCompanionBuilder,
    $$DeckConfigsTableUpdateCompanionBuilder,
    (DeckConfig, BaseReferences<_$AppDatabase, $DeckConfigsTable, DeckConfig>),
    DeckConfig,
    PrefetchHooks Function()>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  required String mainLanguage,
  required String targetLanguage,
  required String firstTime,
  Value<int> rowid,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> mainLanguage,
  Value<String> targetLanguage,
  Value<String> firstTime,
  Value<int> rowid,
});

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mainLanguage => $composableBuilder(
      column: $table.mainLanguage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetLanguage => $composableBuilder(
      column: $table.targetLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstTime => $composableBuilder(
      column: $table.firstTime, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mainLanguage => $composableBuilder(
      column: $table.mainLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetLanguage => $composableBuilder(
      column: $table.targetLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstTime => $composableBuilder(
      column: $table.firstTime, builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mainLanguage => $composableBuilder(
      column: $table.mainLanguage, builder: (column) => column);

  GeneratedColumn<String> get targetLanguage => $composableBuilder(
      column: $table.targetLanguage, builder: (column) => column);

  GeneratedColumn<String> get firstTime =>
      $composableBuilder(column: $table.firstTime, builder: (column) => column);
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> mainLanguage = const Value.absent(),
            Value<String> targetLanguage = const Value.absent(),
            Value<String> firstTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            mainLanguage: mainLanguage,
            targetLanguage: targetLanguage,
            firstTime: firstTime,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String mainLanguage,
            required String targetLanguage,
            required String firstTime,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            mainLanguage: mainLanguage,
            targetLanguage: targetLanguage,
            firstTime: firstTime,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FavTableTableManager get fav => $$FavTableTableManager(_db, _db.fav);
  $$RevlogEntriesTableTableManager get revlogEntries =>
      $$RevlogEntriesTableTableManager(_db, _db.revlogEntries);
  $$DeckConfigsTableTableManager get deckConfigs =>
      $$DeckConfigsTableTableManager(_db, _db.deckConfigs);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
}
