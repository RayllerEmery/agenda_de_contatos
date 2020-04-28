import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

final String contactTable = "contact_table";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  factory ContactHelper() => _instance;
  static final ContactHelper _instance = ContactHelper.internal();
  String nome = "";

  ContactHelper.internal() {

  }

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> map = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (map.length > 0) {
      return Contact.fromMap(map.first);
    } else
      return null;
  }

  Future dropTable() async {
    Database dbContact = await db;
    return await dbContact.rawQuery("DROP TABLE $contactTable");
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ${contact.id}");
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> list = List();
    listMap.forEach((f) {
      list.add(Contact.fromMap(f));
    });
    return list;
  }

  Future getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    return await dbContact.close();
  }

  Future<Database> initDb() async {
    final String databasePath = await getDatabasesPath();
    final path = join(databasePath, "contactsNews.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS $contactTable ($idColumn INTEGER PRIMARY KEY, "
          "$nameColumn TEXT, "
          "$emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    this.id = map[idColumn];
    this.name = map[nameColumn];
    this.email = map[emailColumn];
    this.phone = map[phoneColumn];
    this.img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Contact: (id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
