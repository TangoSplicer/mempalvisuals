import 'package:drift/drift.dart';

class Palaces extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Nodes extends Table {
  TextColumn get id => text()(); // The actual entity (e.g., "MG ZS")
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Edges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceId => text().references(Nodes, #id)();
  TextColumn get targetId => text().references(Nodes, #id)();
  TextColumn get label => text()(); // The relationship (e.g., "is a")
  IntColumn get palaceId =>
      integer().references(Palaces, #id)(); // Tracks origin
}
