
## Teilaufgabe 01

Es befinden sich keine Duplikatsfehler in der `title_akas` Tabelle. Deshalb wird diese 1:1 übernommen
```sql
INSERT INTO error_unified.title_akas
SELECT * FROM error_cleaned.title_akas
```

Gleiches gilt für die `title_ratings` Tabelle
```sql
INSERT INTO error_unified.title_ratings
SELECT * FROM error_cleaned.title_ratings
```

In der Tabelle `name_basics` gibt es doppelte Zeilen. Deshalb nutzen wir hier `GROUP BY` mit allen Spalten der Tabelle, um diese Duplikate vollständig zu entfernen und in das neue Schema einzufügen
```sql
INSERT INTO error_unified.name_basics
SELECT * FROM error_cleaned.name_basics
GROUP BY name_basics.nconst, name_basics.primaryName, name_basics.birthYear, name_basics.deathYear, name_basics.primaryProfession, name_basics.knownForTitles 
```

Gleiches Vorgehen auch bei der `title_basics` Tabelle
```sql
INSERT INTO error_unified.title_basics
SELECT * FROM error_cleaned.title_basics
GROUP BY title_basics.tconst, title_basics.titleType, title_basics.primaryTitle, title_basics.originalTitle, title_basics.isAdult, title_basics.startYear, title_basics.endYear, title_basics.runtimeMinutes, title_basics.genres 
```

Gleiches Vorgehen auch bei der `title_crew` Tabelle
```sql
INSERT INTO error_unified.title_crew
SELECT * FROM error_cleaned.title_crew
GROUP BY title_crew.tconst, title_crew.directors, title_crew.writers 
```

Gleiches Vorgehen auch bei der `title_principals` Tabelle
```sql
INSERT INTO error_unified.title_principals
SELECT * FROM error_cleaned.title_principals
GROUP BY title_principals.tconst, title_principals.ordering, title_principals.nconst, title_principals.category, title_principals.job, title_principals.characters
```

Die Tabelle `title_episode` enthält keine Duplikate und wird deshalb 1:1 in das Unified Schema übernommen
```sql
INSERT INTO error_unified.title_episode
SELECT * FROM error_cleaned.title_episode
```

## Teilaufgabe 02
