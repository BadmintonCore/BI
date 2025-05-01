create table attributes
(
    id   int auto_increment
        primary key,
    name varchar(255) not null
);

create table genre
(
    id   int auto_increment
        primary key,
    name varchar(255) null
);

create table persons
(
    id          varchar(255) not null comment 'Name-ID'
        primary key,
    primaryName text         not null comment 'Rufname des Schauspielers',
    birthYear   int          not null comment 'Geburtsjahr',
    deathYear   int          null comment 'Todesjahr'
)
    comment 'Produktions-Beteiligten';

create table profession
(
    id   int auto_increment
        primary key,
    name varchar(255) not null
);

create table person_profession
(
    person_id     varchar(255) not null,
    profession_id int          not null,
    primary key (person_id, profession_id),
    constraint person_profession_ibfk_1
        foreign key (person_id) references persons (id),
    constraint person_profession_ibfk_2
        foreign key (profession_id) references profession (id)
);

create index profession_id
    on person_profession (profession_id);

create table title
(
    id             varchar(255) not null
        primary key,
    titleType      text         not null comment 'Typ',
    primaryTitle   text         not null comment 'Haupt-Titel',
    originalTitle  text         not null comment 'Original-Titel',
    isAdult        tinyint(1)   not null comment '18+ Film',
    startYear      int          not null comment 'Startjahr',
    endYear        year         null comment 'Endjahr',
    runtimeMinutes int          not null comment 'Dauer'
);

create table akas
(
    titleId         varchar(255) not null,
    ordering        int          not null,
    title           text         not null comment 'Titel',
    region          text         null comment 'Region',
    language        text         null comment 'Sprache',
    types           text         null comment 'Typen',
    isOriginalTitle tinyint(1)   not null comment 'Originaltitel?',
    primary key (titleId, ordering),
    constraint akas_ibfk_1
        foreign key (titleId) references title (id)
)
    comment 'Alternative Titelname';

create table akas_attributes
(
    title_id     varchar(255) not null,
    ordering     int          not null,
    attribute_id int          not null,
    primary key (title_id, ordering, attribute_id),
    constraint akas_attributes_ibfk_1
        foreign key (attribute_id) references attributes (id),
    constraint akas_attributes_ibfk_2
        foreign key (title_id, ordering) references akas (titleId, ordering)
);

create index attribute_id
    on akas_attributes (attribute_id);

create table episodes
(
    episode_id    varchar(255) not null,
    title_id      varchar(255) not null,
    seasonNumber  varchar(255) null comment 'Staffel-Nr.',
    episodeNumber text         null comment 'Folgen-Nr.',
    primary key (episode_id, title_id),
    constraint episodes_ibfk_1
        foreign key (episode_id) references title (id),
    constraint episodes_ibfk_2
        foreign key (title_id) references title (id)
);

create index title_id
    on episodes (title_id);

create table knownForTitle
(
    person_id varchar(255) not null,
    title_id  varchar(255) not null,
    primary key (person_id, title_id),
    constraint knownForTitle_ibfk_1
        foreign key (person_id) references persons (id),
    constraint knownForTitle_ibfk_2
        foreign key (title_id) references title (id)
);

create index title_id
    on knownForTitle (title_id);

create table principals
(
    titleId    varchar(255) not null,
    ordering   int          not null comment 'Sortierung',
    person_id  varchar(255) null comment 'Name-ID',
    category   text         null comment 'Kategorie',
    job        text         null comment 'Tätigkeit',
    characters varchar(255) null,
    primary key (titleId, ordering),
    constraint principals_ibfk_1
        foreign key (titleId) references title (id),
    constraint principals_persons_id_fk
        foreign key (person_id) references persons (id)
)
    comment 'Hauptbeteiligte';

create table ratings
(
    title_id      varchar(255) not null,
    averageRating double       null comment 'Durchschnittliche Bewertung',
    numVotes      int          null comment 'Bewertungsanzahl',
    constraint ratings_ibfk_1
        foreign key (title_id) references title (id)
)
    comment 'Bewertungen';

create index title_id
    on ratings (title_id);

create table title_directors
(
    title_id  varchar(255) not null,
    person_id varchar(255) not null,
    primary key (title_id, person_id),
    constraint title_directors_ibfk_1
        foreign key (title_id) references title (id),
    constraint title_directors_ibfk_2
        foreign key (person_id) references persons (id)
);

create index person_id
    on title_directors (person_id);

create table title_genre
(
    title_id varchar(255) not null,
    genre_id int          not null,
    primary key (title_id, genre_id),
    constraint title_genre_ibfk_1
        foreign key (title_id) references title (id),
    constraint title_genre_ibfk_2
        foreign key (genre_id) references genre (id)
);

create index genre_id
    on title_genre (genre_id);

create table title_writers
(
    title_id  varchar(255) not null,
    person_id varchar(255) not null,
    primary key (title_id, person_id),
    constraint title_writers_ibfk_1
        foreign key (title_id) references title (id),
    constraint title_writers_ibfk_2
        foreign key (person_id) references persons (id)
);

create index person_id
    on title_writers (person_id);

