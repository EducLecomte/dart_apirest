class DocumentationPage {
  static const String htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <title>Documentation API Bières</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; line-height: 1.6; padding: 2em; color: #333; }
        h1, h2, h3 { color: #222; border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
        code { font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace; background-color: #f6f8fa; padding: .2em .4em; margin: 0; font-size: 85%; border-radius: 6px; }
        pre { background-color: #f6f8fa; padding: 16px; overflow: auto; font-size: 85%; line-height: 1.45; border-radius: 6px; }
        .endpoint { border-left: 4px solid #0366d6; padding-left: 1.5em; margin-bottom: 2.5em; }
        .method { font-weight: bold; color: #0366d6; }
    </style>
</head>
<body>
    <h1>Documentation API Bières</h1>
    <p>Bienvenue sur l'API de gestion de stock de bières.</p>

    <h2>Stocks (/beers)</h2>
    <div class="endpoint">
        <h3><span class="method">GET</span> /beers</h3>
        <p>Récupère la liste de tous les stocks de bières.</p>
        <p><strong>Exemple cURL :</strong></p>
        <pre><code>curl http://localhost:8080/beers</code></pre>
    </div>
    <div class="endpoint">
        <h3><span class="method">POST</span> /beers</h3>
        <p>Ajoute un nouveau stock de bière.</p>
        <p><strong>Corps de la requête (JSON) :</strong></p>
        <pre><code>{
    "idType": 1,
    "idFormat": 2,
    "quantite": 150
}</code></pre>
        <p><strong>Exemple cURL :</strong></p>
        <pre><code>curl -X POST -H "Content-Type: application/json" \\
  -d '{"idType": 1, "idFormat": 2, "quantite": 150}' \\
  http://localhost:8080/beers</code></pre>
    </div>

    <h2>Types de bière (/types)</h2>
    <div class="endpoint">
        <h3><span class="method">GET</span> /types</h3>
        <p>Récupère la liste de tous les types de bières (ex: Blonde, Brune).</p>
        <pre><code>curl http://localhost:8080/types</code></pre>
    </div>
    <div class="endpoint">
        <h3><span class="method">POST</span> /types</h3>
        <p>Ajoute un nouveau type de bière.</p>
        <pre><code>curl -X POST -H "Content-Type: application/json" -d '{"libelle": "Stout"}' http://localhost:8080/types</code></pre>
    </div>
    <div class="endpoint">
        <h3><span class="method">PUT</span> /types/&lt;id&gt;</h3>
        <p>Met à jour le libellé d'un type de bière existant.</p>
        <pre><code>curl -X PUT -H "Content-Type: application/json" -d '{"libelle": "Imperial Stout"}' http://localhost:8080/types/5</code></pre>
    </div>
    <div class="endpoint">
        <h3><span class="method">DELETE</span> /types/&lt;id&gt;</h3>
        <p>Supprime un type de bière (échoue si le type est utilisé dans un stock).</p>
        <pre><code>curl -X DELETE http://localhost:8080/types/5</code></pre>
    </div>

    <h2>Formats de bière (/formats)</h2>
    <div class="endpoint">
        <h3><span class="method">GET</span> /formats</h3>
        <p>Récupère la liste de tous les formats (ex: Bouteille 33cl).</p>
        <pre><code>curl http://localhost:8080/formats</code></pre>
    </div>
    <div class="endpoint">
        <h3><span class="method">POST</span> /formats</h3>
        <p>Ajoute un nouveau format.</p>
        <pre><code>curl -X POST -H "Content-Type: application/json" -d '{"libelle": "Growler 2L"}' http://localhost:8080/formats</code></pre>
    </div>
    <div class="endpoint">
        <h3><span class="method">PUT</span> /formats/&lt;id&gt;</h3>
        <p>Met à jour le libellé d'un format existant.</p>
        <pre><code>curl -X PUT -H "Content-Type: application/json" -d '{"libelle": "Bouteille 25cl"}' http://localhost:8080/formats/1</code></pre>
    </div>
    <div class="endpoint">
        <h3><span class="method">DELETE</span> /formats/&lt;id&gt;</h3>
        <p>Supprime un format.</p>
        <pre><code>curl -X DELETE http://localhost:8080/formats/4</code></pre>
    </div>
</body>
</html>
''';
}
