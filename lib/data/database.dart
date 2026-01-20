import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get phoneNumber => text().withDefault(const Constant(''))();
  TextColumn get fax => text().withDefault(const Constant(''))();
  TextColumn get contactName => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get type => text().withDefault(const Constant('fixed'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  DateTimeColumn get invoiceDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get clientId => text().nullable().references(Clients, #id)();
  TextColumn get clientName => text().withDefault(const Constant(''))();
  TextColumn get clientPhoneNumber => text().withDefault(const Constant(''))();
  TextColumn get itemName => text().withDefault(const Constant(''))();
  RealColumn get itemPrice => real().withDefault(const Constant(0.0))();
  IntColumn get itemQuantity => integer().withDefault(const Constant(1))();
  RealColumn get tax => real().withDefault(const Constant(0.0))();
  TextColumn get signature => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Clients, Items, Invoices])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'quick_invoice.db');
  }

  // Client methods
  Future<List<Client>> getAllClients() => select(clients).get();
  
  Stream<List<Client>> watchAllClients() => select(clients).watch();

  Future<Client?> getClientById(String id) =>
      (select(clients)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertClient(ClientsCompanion client) =>
      into(clients).insert(client, mode: InsertMode.insertOrReplace);

  Future<bool> updateClient(ClientsCompanion client) =>
      update(clients).replace(client);

  Future<int> deleteClient(String id) =>
      (delete(clients)..where((t) => t.id.equals(id))).go();

  // Item methods
  Future<List<Item>> getAllItems() => select(items).get();
  
  Stream<List<Item>> watchAllItems() => select(items).watch();

  Future<Item?> getItemById(String id) =>
      (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertItem(ItemsCompanion item) =>
      into(items).insert(item, mode: InsertMode.insertOrReplace);

  Future<bool> updateItem(ItemsCompanion item) =>
      update(items).replace(item);

  Future<int> deleteItem(String id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();

  // Invoice methods
  Future<List<Invoice>> getAllInvoices() => select(invoices).get();
  
  Stream<List<Invoice>> watchAllInvoices() => select(invoices).watch();

  Future<Invoice?> getInvoiceById(String id) =>
      (select(invoices)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertInvoice(InvoicesCompanion invoice) =>
      into(invoices).insert(invoice, mode: InsertMode.insertOrReplace);

  Future<bool> updateInvoice(InvoicesCompanion invoice) =>
      update(invoices).replace(invoice);

  Future<int> deleteInvoice(String id) =>
      (delete(invoices)..where((t) => t.id.equals(id))).go();

  Future<List<Invoice>> getInvoicesByStatus(String status) =>
      (select(invoices)..where((t) => t.status.equals(status))).get();

  Stream<List<Invoice>> watchInvoicesByStatus(String status) =>
      (select(invoices)..where((t) => t.status.equals(status))).watch();
}
