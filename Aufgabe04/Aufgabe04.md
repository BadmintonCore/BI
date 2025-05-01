
Übertragen der fehlerfreien Daten der `name_basics`-Tabelle nach folgenden Regeln:
- Geburtsjahr < Todesjahr
- Todesjahr <= aktuelles Jahr
- Geburtsjahr >= 0
- Der Name enthält Vorname und Nachname
```sql
INSERT INTO error_cleaned.name_basics 
SELECT * FROM error_extract.name_basics 
         WHERE birthYear < deathYear 
           AND deathYear <= 2025 
           AND birthYear >= 0 
           AND primaryName LIKE '% %';
```

Übertragen der fehlerfreien Daten der `title_akas`-Tabelle nach folgenden Regeln:
- Die Region ist ein ISO 3166-1 Ländercode
- Die Sprache ist ein ISO 639 Sprachencode
- Der Titel kann zu utf8mb4 konvertiert werden
```sql
INSERT INTO error_cleaned.title_akas 
SELECT * FROM error_extract.title_akas 
         WHERE region IN ('AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'AO', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AW', 'AX', 'AZ','BA', 'BB', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI', 'BJ', 'BL', 'BM', 'BN', 'BO', 'BQ', 'BR', 'BS','BT', 'BV', 'BW', 'BY', 'BZ', 'CA', 'CC', 'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN','CO', 'CR', 'CU', 'CV', 'CW', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM', 'DO', 'DZ', 'EC', 'EE','EG', 'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FM', 'FO', 'FR', 'GA', 'GB', 'GD', 'GE', 'GF', 'GG','GH', 'GI', 'GL', 'GM', 'GN', 'GP', 'GQ', 'GR', 'GT', 'GU', 'GW', 'GY', 'HK', 'HM', 'HN', 'HR','HT', 'HU', 'ID', 'IE', 'IL', 'IM', 'IN', 'IO', 'IQ', 'IR', 'IS', 'IT', 'JE', 'JM', 'JO', 'JP','KE', 'KG', 'KH', 'KI', 'KM', 'KN', 'KP', 'KR', 'KW', 'KY', 'KZ', 'LA', 'LB', 'LC', 'LI', 'LK','LR', 'LS', 'LT', 'LU', 'LV', 'LY', 'MA', 'MC', 'MD', 'ME', 'MF', 'MG', 'MH', 'MK', 'ML', 'MM','MN', 'MO', 'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW', 'MX', 'MY', 'MZ', 'NA', 'NC', 'NE','NF', 'NG', 'NI', 'NL', 'NO', 'NP', 'NR', 'NU', 'NZ', 'OM', 'PA', 'PE', 'PF', 'PG', 'PH', 'PK','PL', 'PM', 'PN', 'PR', 'PT', 'PW', 'PY', 'QA', 'RE', 'RO', 'RS', 'RU', 'RW', 'SA', 'SB', 'SC','SD', 'SE', 'SG', 'SH', 'SI', 'SJ', 'SK', 'SL', 'SM', 'SN', 'SO', 'SR', 'SS', 'ST', 'SV', 'SX','SY', 'SZ', 'TC', 'TD', 'TF', 'TG', 'TH', 'TJ', 'TK', 'TL', 'TM', 'TN', 'TO', 'TR', 'TT', 'TV','TW', 'TZ', 'UA', 'UG', 'UM', 'US', 'UY', 'UZ', 'VA', 'VC', 'VE', 'VG', 'VI', 'VN', 'VU', 'WF','WS', 'YE', 'YT', 'ZA', 'ZM', 'ZW') 
           AND language IN ('aa', 'ab', 'ae', 'af', 'ak', 'am', 'an', 'ar', 'as', 'av', 'ay', 'az','ba', 'be', 'bg', 'bh', 'bi', 'bm', 'bn', 'bo', 'br', 'bs', 'ca', 'ce','ch', 'co', 'cr', 'cs', 'cu', 'cv', 'cy', 'da', 'de', 'dv', 'dz', 'ee','el', 'en', 'eo', 'es', 'et', 'eu', 'fa', 'ff', 'fi', 'fj', 'fo', 'fr','fy', 'ga', 'gd', 'gl', 'gn', 'gu', 'gv', 'ha', 'he', 'hi', 'ho', 'hr','ht', 'hu', 'hy', 'hz', 'ia', 'id', 'ie', 'ig', 'ii', 'ik', 'io', 'is','it', 'iu', 'ja', 'jv', 'ka', 'kg', 'ki', 'kj', 'kk', 'kl', 'km', 'kn','ko', 'kr', 'ks', 'ku', 'kv', 'kw', 'ky', 'la', 'lb', 'lg', 'li', 'ln','lo', 'lt', 'lu', 'lv', 'mg', 'mh', 'mi', 'mk', 'ml', 'mn', 'mr', 'ms','mt', 'my', 'na', 'nb', 'nd', 'ne', 'ng', 'nl', 'nn', 'no', 'nr', 'nv','ny', 'oc', 'oj', 'om', 'or', 'os', 'pa', 'pi', 'pl', 'ps', 'pt', 'qu','rm', 'rn', 'ro', 'ru', 'rw', 'sa', 'sc', 'sd', 'se', 'sg', 'si', 'sk','sl', 'sm', 'sn', 'so', 'sq', 'sr', 'ss', 'st', 'su', 'sv', 'sw', 'ta','te', 'tg', 'th', 'ti', 'tk', 'tl', 'tn', 'to', 'tr', 'ts', 'tt', 'tw','ty', 'ug', 'uk', 'ur', 'uz', 've', 'vi', 'vo', 'wa', 'wo', 'xh', 'yi','yo', 'za', 'zh', 'zu' ) 
           AND CHAR_LENGTH(title) = LENGTH(CONVERT(title USING utf8mb4));
```


Übertragen der fehlerfreien Daten der `title_basics`-Tabelle nach folgenden Regeln:
- Die Laufzeit des Filmes ist > 0 
- Die Laufzeit des Filmes ist nicht `NULL`
- Der Wertebereich für `isAdult` ist 0 oder 1 für Wahr oder Falsch
- Das Startjahr ist nicht `NULL`
```sql
INSERT INTO error_cleaned.title_basics 
SELECT * FROM error_extract.title_basics 
         WHERE runtimeMinutes > 0
           AND runtimeMinutes IS NOT NULL 
           AND isAdult IN (0, 1) 
           AND startYear IS NOT NULL;
```

Übertragen der fehlerfreien Daten der `title_ratings`-Tabelle nach folgenden Regeln:
- Das durchschnittliche Rating ist <= 10
- Das durchschnittliche Rating ist >= 0
- Die Anzahl der Stimmen ist > 0
```sql
INSERT INTO error_cleaned.title_ratings 
SELECT * FROM error_extract.title_ratings 
         WHERE averageRating <= 10 
           AND averageRating >= 0 
           AND numVotes > 0;
```

Diese Tabelle enthält keine Fehler und kann daher 1:1 übertragen werden
```sql
INSERT INTO error_cleaned.title_crew SELECT * FROM error_extract.title_crew;
```

Diese Tabelle enthält keine Fehler und kann daher 1:1 übertragen werden
```sql
INSERT INTO error_cleaned.title_episode SELECT * FROM error_extract.title_episode;
```

Diese Tabelle enthält keine Fehler und kann daher 1:1 übertragen werden
```sql
INSERT INTO error_cleaned.title_principals SELECT * FROM error_extract.title_principals
```