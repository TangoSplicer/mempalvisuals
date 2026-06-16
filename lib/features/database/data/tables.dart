import 'package:drift/drift.dart';

class Palaces extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get palaceId => integer().references(Palaces, #id)();
  TextColumn get text => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Nodes extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Edges extends Table {
  IntColumn get id => integer().autoIncrement()();
  @ReferenceName('sourceEdges')
  TextColumn get sourceId => text().references(Nodes, #id)();
  @ReferenceName('targetEdges')
  TextColumn get targetId => text().references(Nodes, #id)();
  TextColumn get label => text()();
  IntColumn get palaceId => integer().references(Palaces, #id)();
}
