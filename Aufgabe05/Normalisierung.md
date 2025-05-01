Wir haben die Annahme getroffen, dass das raw-Schema bereits keine Fehler enthält, da dies auf den Folien auch so niedergeschrieben ist.
Trotzdessen gab es vereinzelt noch Probleme mit `NULL`-Werten. Diese werden allerdings direkt in den Queries gelöst.

### Kurze Einführung für weiteres Verständnis

Hier in dieser Teilaufgabe nutzen wir einen besonderen Ansatz um Strings zu Comma-seperieren.
Dieser wird im folgenden erläutert.

Als erstes erstellen wir eine temporäre Tabelle, die die Werte 1-10 als `INTEGER` enthält.
```sql
CREATE TEMPORARY TABLE IF NOT EXISTS numbers (
        n INT
    );
INSERT INTO numbers (n) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);
```

Als nächstes ist es wichtig folgenden Ausdruck zu verstehen:
```sql
SUBSTRING_INDEX(SUBSTRING_INDEX(column_name, ',', 5), ',', -1)
```
Dieser Ausdruck seperiert als erstes den String in der Spalte `column_name` bei dem 5. Komma und gibt den gesamten String bis zu diesem zurück.
Dann wird der Wert des ab dem letzten Komma durch den zweiten SUBSTRING_INDEX Ausdruck zurückgegeben.

**Beispiel:**

```
SUBSTRING_INDEX('Action,Drama,Comedy', ',', 2) => 'Action,Drama'
SUBSTRING_INDEX('Action,Drama', ',', -1) => 'Drama'
```

Nun können wir diese Tabelle und diesen Audruck sinnvoll nutzen:

```sql
SELECT DISTINCT SUBSTRING_INDEX(SUBSTRING_INDEX(genres, ',', numbers.n), ',', -1) FROM title_basics
CROSS JOIN numbers
WHERE
    numbers.n <= 1 + LENGTH(genres) - LENGTH(REPLACE(genres, ',', ''));
```

Durch das Cross-Join mit der `numbers` Tabelle wird der oben erläuterte Audruck nun für jeden der Werte `numbers.n` durchgeführt, was dazu führt, dass alle Werte Komma seperiert zurückgegeben werden.

- Ausdruck für `numbers.n = 1` => `SUBSTRING_INDEX(SUBSTRING_INDEX(genres, ',', 1), ',', -1)` => 'Action'
- Ausdruck für `numbers.n = 2` => `SUBSTRING_INDEX(SUBSTRING_INDEX(genres, ',', 1), ',', -1)` => 'Drama'
- Ausdruck für `numbers.n = 1` => `SUBSTRING_INDEX(SUBSTRING_INDEX(genres, ',', 1), ',', -1)` => 'Comedy'

Die `WHERE`-Clause besagt nun, dass numbers.n nicht größer sein darf, als 1 + die Anzahl an Commas in der angegebenen Spalte. `1+n` daher, da es bei n Commas immer `1+n` Werte in der Spalte gibt.

Durch das `DISTINCT` werden die Werte nur einmal zurückgegeben.


### Tatsächliche SQL-Statements

Zuerst müssen wir in unserem Core-Schema die `genres`-Tabelle mit allen Genres der `title_basics`-Tabelle befüllen:
```sql
INSERT INTO core.genre (name)
SELECT DISTINCT SUBSTRING_INDEX(SUBSTRING_INDEX(genres, ',', numbers.n), ',', -1) FROM raw_extract.title_basics
CROSS JOIN numbers
WHERE
    numbers.n <= 1 + LENGTH(genres) - LENGTH(REPLACE(genres, ',', ''));
```

Im nächsten Schritt wird nun die `title`-Tabelle mit den Titeln befüllt
```sql
INSERT INTO core.title (id, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes)
SELECT tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes FROM raw_extract.title_basics
WHERE runtimeMinutes IS NOT NULL AND startYear IS NOT NULL
```

Nun wird die Join-Tabelle zwischen der `title` und der `genre`-Tabelle befüllt
```sql
INSERT INTO core.title_genre (title_id, genre_id)
SELECT DISTINCT tconst, genre.id FROM title_basics
    -- Sicherstellen, dass die titles tatsächlich auch im neuen Core-DW existieren
    JOIN core.title ON title_basics.tconst = core.title.id
    -- Cross Join hier sehr teuer, aber aufgrund der geringen Datenmenge noch verkraftbar. Für die weiteren Tabellen wird ein anderer Ansatz verwendet
    CROSS JOIN core.genre
WHERE INSTR(title_basics.genres, genre.name) AND title.id = tconst
```

Nun werden die Professions aus der `name_basics`-Tabelle des raw_extract-Schemas in unser normalisiertes Core-Schema übertragen
```sql
INSERT INTO core.profession (name)
SELECT DISTINCT SUBSTRING_INDEX(SUBSTRING_INDEX(primaryProfession, ',', numbers.n), ',', -1) FROM raw_extract.name_basics
CROSS JOIN numbers
WHERE
    numbers.n <= 1 + LENGTH(primaryProfession) - LENGTH(REPLACE(primaryProfession, ',', ''));
```

Nun werden alle Personen in das core-Schema aus der `name_basics`-Tabelle geladen
```sql
INSERT INTO core.persons (id, primaryName, birthYear, deathYear)
SELECT nconst, primaryName, birthYear, deathYear FROM raw_extract.name_basics
WHERE birthYear IS NOT NULL
```

Als nächstes wird die Mapping-Tabelle zwischen Title und Personen gefüllt. Es ist die ursprüngliche Darstellung der `knownForTitle`-Spalte in der `name_basics`-Tabelle
```sql
INSERT INTO core.knownForTitle (person_id, title_id)
SELECT DISTINCT nconst, core.title.id FROM raw_extract.name_basics
JOIN core.title ON INSTR(knownForTitles, core.title.id)
WHERE
    -- Nur für namen, die tatsächlich auch schon im core-Schema enthalten sind
    nconst IN (SELECT id FROM core.persons)
```

Als nächstes wird die Mapping-Tabelle zwischen Profession und Personen gefüllt. Es ist die ursprüngliche Darstellung der `primaryProfession`-Spalte in der `name_basics`-Tabelle
```sql
INSERT INTO core.person_profession (person_id, profession_id)
SELECT DISTINCT nconst, core.profession.id FROM raw_extract.name_basics
 JOIN core.profession ON INSTR(name_basics.primaryProfession ,core.profession.name)
WHERE
    -- Nur für personen, die tatsächlich auch schon im core-Schema enthalten sind
    nconst IN (SELECT id FROM core.persons)
```

Nun gefüllen wir für die Title-Akas die normalisierte Tabelle für die Attribute
```sql
INSERT INTO core.attributes (name)
SELECT DISTINCT SUBSTRING_INDEX(SUBSTRING_INDEX(attributes, ' ', numbers.n), ' ', -1) FROM raw_extract.title_akas
CROSS JOIN numbers
WHERE
    attributes IS NOT NULL AND numbers.n <= 1 + LENGTH(attributes) - LENGTH(REPLACE(attributes, ' ', ''));
```

Nun wird die Akas Tabelle mit den Inhalten der `title_akas`-Tabelle befüllt
```sql
INSERT INTO core.akas (titleId, ordering, title, region, language, types, isOriginalTitle)
SELECT titleId, ordering, title, region, language, types, isOriginalTitle FROM raw_extract.title_akas
-- Nur titles, die schon im core-Datenbestand enthalten sind
WHERE titleId IN (SELECT id FROM core.title)
```


Im nächsten Schritt befüllen wir die Join-Tabelle `akas_attributes`, die eine Verbindung zwischen den Attributen und den "Also known as"-Namen herstellt
```sql
INSERT INTO core.akas_attributes (title_id, ordering, attribute_id)
SELECT titleId, ordering, attributes.id FROM raw_extract.title_akas
JOIN core.attributes ON INSTR(title_akas.attributes, core.attributes.name)
WHERE (titleId, ordering) IN (SELECT titleId, ordering FROM core.akas)
```

Einfügen aller Episoden in das normalisierte Core-Schema
```sql
INSERT INTO core.episodes (episode_id, title_id, seasonNumber, episodeNumber)
SELECT tconst, parentTconst, seasonNumber, episodeNumber FROM raw_extract.title_episode
WHERE tconst IN (SELECT id FROM core.title) AND parentTconst IN (SELECT id FROm core.title)
```

Einfpgen aller Directors eines Titles. Hierbei handelt es sich in unserem Core-Schema um eine Join-Tabelle zwischen Personen und Titeln
```sql
INSERT INTO core.title_directors(title_id, person_id)
SELECT DISTINCT tconst, core.persons.id FROM raw_extract.title_crew
JOIN core.persons ON INSTR(title_crew.directors, core.persons.id)
WHERE tconst IN (SELECT id FROM core.title)
```

Einfügen aller Schreiber eines Titles. Hierbei handelt es sich in unserem Core-Schema um eine Join-Tabelle zwischen Personen und Titeln
```sql
INSERT INTO core.title_writers(title_id, person_id)
SELECT DISTINCT tconst, core.persons.id FROM raw_extract.title_crew
JOIN core.persons ON INSTR(title_crew.writers, core.persons.id)
WHERE tconst IN (SELECT id FROM core.title)
```

Nun gefüllen wir die Principals-Tabelle mit den Datten aus dem raw_extract Schema
```sql
INSERT INTO core.principals (titleId, ordering, person_id, category, job, characters)
SELECT tconst, ordering, nconst, category, job,
  REPLACE(REPLACE(REPLACE(characters, '""', '"'), '"["', ''), '"]"', '') FROM title_principals
WHERE tconst IN (SELECT id FROM core.title) AND nconst IN (SELECT  id FROM core.persons)
```
**NOTE:** Das `REPLACE`-Konstrukt entfernt hierbei die eckigen Klammern

Zuletzt werden nun alle Ratings übertragen
```sql
INSERT INTO core.ratings (title_id, averageRating, numVotes)
SELECT tconst, averageRating, numVotes FROM raw_extract.title_ratings
WHERE tconst IN (SELECT id FROM core.title)
```