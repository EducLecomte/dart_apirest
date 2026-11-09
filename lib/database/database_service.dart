import 'package:sqlite3/sqlite3.dart';

class DatabaseService {
  DatabaseService({this.path = 'beer_stock.db'});

  final String path;
  late final Database _db;

  void initialize() {
    // Ouvre la base de données (la crée si elle n'existe pas)
    _db = sqlite3.open(path);
    _db.execute('PRAGMA foreign_keys = ON');

    // Crée les tables si elles n'existent pas.
    // Le schéma est adapté pour SQLite.
    _db.execute('''
      CREATE TABLE IF NOT EXISTS beer_type (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        libelle TEXT NOT NULL
      );
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS beer_format (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        libelle TEXT NOT NULL
      );
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS beer_stock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idFormat INTEGER NOT NULL,
        idType INTEGER NOT NULL,
        quantite INTEGER,
        FOREIGN KEY (idFormat) REFERENCES beer_format (id),
        FOREIGN KEY (idType) REFERENCES beer_type (id)
      );
    ''');

    // Ajoute des données de test si les tables sont vides
    final typeCount = _db.select('SELECT COUNT(*) as count FROM beer_type');
    if (typeCount.first['count'] == 0) {
      print('Populating database with initial data...');
      _db.execute(
        "INSERT INTO beer_type (libelle) VALUES ('Blonde'), ('Brune'), ('Ambrée'), ('IPA');",
      );
      _db.execute(
        "INSERT INTO beer_format (libelle) VALUES ('Bouteille 33cl'), ('Bouteille 75cl'), ('Canette 50cl'), ('Fût 5L');",
      );
      // Vous pouvez même ajouter un premier stock pour l'exemple
      final typeId =
          _db
                  .select("SELECT id FROM beer_type WHERE libelle = 'Blonde'")
                  .first['id']
              as int;
      final formatId =
          _db
                  .select(
                    "SELECT id FROM beer_format WHERE libelle = 'Bouteille 33cl' ORDER BY id DESC",
                  )
                  .first['id']
              as int;
      addBeerStock(idFormat: formatId, idType: typeId, quantite: 120);
      print('Database populated.');
    }
  }

  // Récupère tous les stocks de bières avec les détails
  ResultSet getBeers() {
    return _db.select('''
      SELECT 
        bs.id, 
        bt.libelle as type, 
        bf.libelle as format, 
        bs.quantite 
      FROM beer_stock bs
      JOIN beer_type bt ON bs.idType = bt.id
      JOIN beer_format bf ON bs.idFormat = bf.id;
    ''');
  }

  Map<String, Object?>? getBeer(int id) {
    final beers = _db.select(
      '''
      SELECT
        bs.id,
        bt.libelle as type,
        bf.libelle as format,
        bs.quantite
      FROM beer_stock bs
      JOIN beer_type bt ON bs.idType = bt.id
      JOIN beer_format bf ON bs.idFormat = bf.id
      WHERE bs.id = ?
      ''',
      [id],
    );
    return beers.isEmpty ? null : Map<String, Object?>.from(beers.first);
  }

  // Ajoute un nouvel enregistrement de stock
  void addBeerStock({
    required int idFormat,
    required int idType,
    required int quantite,
  }) {
    _db.execute(
      'INSERT INTO beer_stock (idFormat, idType, quantite) VALUES (?, ?, ?)',
      [idFormat, idType, quantite],
    );
  }

  // Ferme la connexion à la base de données
  void dispose() {
    _db.dispose();
  }

  // --- Méthodes pour Beer Type ---

  ResultSet getTypes() {
    return _db.select('SELECT * FROM beer_type ORDER BY libelle');
  }

  void addType({required String libelle}) {
    _db.execute('INSERT INTO beer_type (libelle) VALUES (?)', [libelle]);
  }

  bool updateType({required int id, required String libelle}) {
    _db.execute('UPDATE beer_type SET libelle = ? WHERE id = ?', [libelle, id]);
    return _db.updatedRows > 0;
  }

  bool deleteType({required int id}) {
    _db.execute('DELETE FROM beer_type WHERE id = ?', [id]);
    return _db.updatedRows > 0;
  }

  // --- Méthodes pour Beer Format ---

  ResultSet getFormats() {
    return _db.select('SELECT * FROM beer_format ORDER BY libelle');
  }

  void addFormat({required String libelle}) {
    _db.execute('INSERT INTO beer_format (libelle) VALUES (?)', [libelle]);
  }

  bool updateFormat({required int id, required String libelle}) {
    _db.execute('UPDATE beer_format SET libelle = ? WHERE id = ?', [
      libelle,
      id,
    ]);
    return _db.updatedRows > 0;
  }

  bool deleteFormat({required int id}) {
    _db.execute('DELETE FROM beer_format WHERE id = ?', [id]);
    return _db.updatedRows > 0;
  }
}
