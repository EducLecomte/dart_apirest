# API de gestion de stocks de bière

Cette API REST, développée avec [Dart](https://dart.dev/),
[Shelf](https://pub.dev/packages/shelf) et SQLite, permet de consulter et
d'ajouter des stocks de bière, ainsi que de gérer leurs types et leurs formats.
La page `/` contient une documentation sous forme d'exemples.

## Prérequis

- Dart SDK compatible avec la version `^3.9.2`.
- La bibliothèque native SQLite 3 accessible par le programme. Sous Linux,
  le paquet de développement SQLite fournit généralement `libsqlite3.so`.

## Démarrage

Depuis la racine du projet :

```bash
dart pub get
dart run bin/server.dart
```

Le serveur écoute sur toutes les interfaces IPv4, sur le port `8080` par
défaut. Pour choisir un autre port :

```bash
PORT=3000 dart run bin/server.dart
```

La base `beer_stock.db` est ouverte ou créée dans le répertoire courant.
Lorsque la table des types est vide, des types, des formats et un stock
d'exemple sont ajoutés. Les données persistent dans ce fichier entre les
redémarrages.

## Routes

| Méthode | Route | Description |
| --- | --- | --- |
| GET | `/` | Documentation et exemples |
| GET | `/echo/<message>` | Route de test renvoyant le message |
| GET | `/beers` | Liste des stocks |
| POST | `/beers` | Ajout d'un stock |
| GET, POST | `/types` | Liste ou création des types |
| PUT, DELETE | `/types/<id>` | Modification ou suppression d'un type |
| GET, POST | `/formats` | Liste ou création des formats |
| PUT, DELETE | `/formats/<id>` | Modification ou suppression d'un format |

Les listes sont renvoyées en JSON. Pour créer un stock, `idType`, `idFormat`
et `quantite` doivent être des entiers ; le type et le format doivent exister.
Pour créer ou modifier un type ou un format, le champ `libelle` doit être une
chaîne non vide. Les identifiants utilisés dans les exemples suivants dépendent
des données présentes dans la base.

### Exemples

```bash
# Consulter les types, formats et stocks.
curl http://localhost:8080/types
curl http://localhost:8080/formats
curl http://localhost:8080/beers

# Ajouter un stock en utilisant des identifiants existants.
curl -X POST http://localhost:8080/beers \
  -H 'Content-Type: application/json' \
  -d '{"idType":1,"idFormat":1,"quantite":150}'

# Créer un type.
curl -X POST http://localhost:8080/types \
  -H 'Content-Type: application/json' \
  -d '{"libelle":"Stout"}'

# Modifier puis supprimer un format existant non utilisé.
curl -X PUT http://localhost:8080/formats/5 \
  -H 'Content-Type: application/json' \
  -d '{"libelle":"Bouteille 25cl"}'
curl -X DELETE http://localhost:8080/formats/5
```

Les créations réussies répondent avec le code `201` ; les autres opérations
réussies utilisent `200`. Une requête invalide reçoit `400`, une ressource
absente reçoit `404`, et une référence inexistante ou une suppression empêchée
par un stock reçoit `409`. Une erreur interne reçoit `500` ; ses détails sont
journalisés côté serveur.

## Docker

Le [Dockerfile](./Dockerfile) compile le serveur dans une image minimale :

```bash
docker build -t dart-apirest .
docker run --rm -p 8080:8080 dart-apirest
```

L'image d'exécution doit rendre la bibliothèque native SQLite 3 disponible sous
le nom `libsqlite3.so` ; le Dockerfile ne l'ajoute pas explicitement. Les
données créées dans le conteneur disparaissent à sa suppression, sauf si un
stockage persistant est configuré pour le répertoire courant du serveur.

## Tests

```bash
dart analyze
dart test
```

Les tests de l'API utilisent une base SQLite en mémoire ; les tests du serveur
utilisent une base temporaire.

## Structure

- [`bin/server.dart`](./bin/server.dart) : démarrage, journalisation et arrêt du serveur.
- [`lib/api_handler.dart`](./lib/api_handler.dart) : déclaration des routes.
- [`lib/src/api/beer_handler.dart`](./lib/src/api/beer_handler.dart) : gestion des stocks.
- [`lib/src/api/type_handler.dart`](./lib/src/api/type_handler.dart) : gestion des types.
- [`lib/src/api/format_handler.dart`](./lib/src/api/format_handler.dart) : gestion des formats.
- [`lib/src/api/http_helpers.dart`](./lib/src/api/http_helpers.dart) : validation et gestion des erreurs HTTP.
- [`lib/database.dart`](./lib/database.dart) : accès et initialisation SQLite.
- [`lib/documentation_page.dart`](./lib/documentation_page.dart) : page de documentation servie à la racine.
- [`test/`](./test/) : tests des routes et du serveur.
