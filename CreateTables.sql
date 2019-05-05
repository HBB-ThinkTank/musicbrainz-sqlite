--
-- File generated with SQLiteStudio v3.2.1 on So Mai 5 13:58:07 2019
--
-- Adapted from https://github.com/metabrainz/musicbrainz-server/blob/master/admin/sql/CreateTables.sql
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: alternative_medium
CREATE TABLE alternative_medium (-- replicate
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    medium              INTEGER NOT NULL,-- FK, references medium.id
    alternative_release INTEGER NOT NULL,-- references alternative_release.id
    name                VARCHAR CHECK (name != '') 
);


-- Table: alternative_medium_track
CREATE TABLE alternative_medium_track (-- replicate
    alternative_medium INTEGER NOT NULL,-- PK, references alternative_medium.id
    track              INTEGER NOT NULL,-- PK, references track.id
    alternative_track  INTEGER NOT NULL-- references alternative_track.id
);


-- Table: alternative_release
CREATE TABLE alternative_release (-- replicate
    id            INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    gid           TEXT          NOT NULL,
    [release]     INTEGER       NOT NULL,-- references release.id
    name          VARCHAR,
    artist_credit INTEGER,-- references artist_credit.id
    type          INTEGER       NOT NULL,-- references alternative_release_type.id
    language      INTEGER       NOT NULL,-- references language.id
    script        INTEGER       NOT NULL,-- references script.id
    comment       VARCHAR (255) NOT NULL
                                DEFAULT ''
                                CHECK (name != '') 
);


-- Table: alternative_release_type
CREATE TABLE alternative_release_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references alternative_release_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: alternative_track
CREATE TABLE alternative_track (-- replicate
    id            INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    name          VARCHAR,
    artist_credit INTEGER,-- references artist_credit.id
    ref_count     INTEGER NOT NULL
                          DEFAULT 0
                          CHECK (name != '' AND 
                                 (name IS NOT NULL OR 
                                  artist_credit IS NOT NULL) ) 
);


-- Table: annotation
CREATE TABLE annotation (-- replicate (verbose)
    id        INTEGER       PRIMARY KEY AUTOINCREMENT,
    editor    INTEGER       NOT NULL,-- references editor.id
    text      TEXT,
    changelog VARCHAR (255),
    created   TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: application
CREATE TABLE application (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    owner              INTEGER NOT NULL,-- references editor.id
    name               TEXT    NOT NULL,
    oauth_id           TEXT    NOT NULL,
    oauth_secret       TEXT    NOT NULL,
    oauth_redirect_uri TEXT
);


-- Table: area
CREATE TABLE area (-- replicate (verbose)
    id               INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    gid              TEXT          NOT NULL,
    name             VARCHAR       NOT NULL,
    type             INTEGER,-- references area_type.id
    edits_pending    INTEGER       NOT NULL
                                   DEFAULT 0
                                   CHECK (edits_pending >= 0),
    last_updated     TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    begin_date_year  INTEGER,
    begin_date_month INTEGER,
    begin_date_day   INTEGER,
    end_date_year    INTEGER,
    end_date_month   INTEGER,
    end_date_day     INTEGER,
    ended            BOOLEAN       NOT NULL
                                   DEFAULT FALSE
                                   CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                              end_date_month IS NOT NULL OR 
                                              end_date_day IS NOT NULL) AND 
                                             ended = TRUE) OR 
                                           (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                              end_date_month IS NULL AND 
                                              end_date_day IS NULL) ) ),
    comment          VARCHAR (255) NOT NULL
                                   DEFAULT ''
);


-- Table: area_alias
CREATE TABLE area_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    area               INTEGER NOT NULL,-- references area.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references area_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT FALSE,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ) 
);


-- Table: area_alias_type
CREATE TABLE area_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,-- PK,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references area_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: area_annotation
CREATE TABLE area_annotation (-- replicate (verbose)
    area       INTEGER NOT NULL,-- PK, references area.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: area_attribute
CREATE TABLE area_attribute (-- replicate (verbose)
    id                                INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    area                              INTEGER NOT NULL,-- references area.id
    area_attribute_type               INTEGER NOT NULL,-- references area_attribute_type.id
    area_attribute_type_allowed_value INTEGER,-- references area_attribute_type_allowed_value.id
    area_attribute_text               TEXT    CHECK ( (area_attribute_type_allowed_value IS NULL AND 
                                                       area_attribute_text IS NOT NULL) OR 
                                                      (area_attribute_type_allowed_value IS NOT NULL AND 
                                                       area_attribute_text IS NULL) ) 
);


-- Table: area_attribute_type
CREATE TABLE area_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references area_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: area_attribute_type_allowed_value
CREATE TABLE area_attribute_type_allowed_value (-- replicate (verbose)
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    area_attribute_type INTEGER NOT NULL,-- references area_attribute_type.id
    value               TEXT,
    parent              INTEGER,-- references area_attribute_type_allowed_value.id
    child_order         INTEGER NOT NULL
                                DEFAULT 0,
    description         TEXT,
    gid                 TEXT    NOT NULL
);


-- Table: area_gid_redirect
CREATE TABLE area_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references area.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: area_tag
CREATE TABLE area_tag (-- replicate (verbose)
    area         INTEGER NOT NULL,-- PK, references area.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: area_tag_raw
CREATE TABLE area_tag_raw (
    area      INTEGER NOT NULL,-- PK, references area.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: area_type
CREATE TABLE area_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references area_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: artist
CREATE TABLE artist (-- replicate (verbose)
    id               INTEGER       PRIMARY KEY AUTOINCREMENT,
    gid              TEXT          NOT NULL,
    name             VARCHAR       NOT NULL,
    sort_name        VARCHAR       NOT NULL,
    begin_date_year  INTEGER,
    begin_date_month INTEGER,
    begin_date_day   INTEGER,
    end_date_year    INTEGER,
    end_date_month   INTEGER,
    end_date_day     INTEGER,
    type             INTEGER,-- references artist_type.id
    area             INTEGER,-- references area.id
    gender           INTEGER,-- references gender.id
    comment          VARCHAR (255) NOT NULL
                                   DEFAULT '',
    edits_pending    INTEGER       NOT NULL
                                   DEFAULT 0
                                   CHECK (edits_pending >= 0),
    last_updated     TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    ended            BOOLEAN       NOT NULL
                                   DEFAULT FALSE
                                   CONSTRAINT artist_ended_check CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                                                            end_date_month IS NOT NULL OR 
                                                                            end_date_day IS NOT NULL) AND 
                                                                           ended = TRUE) OR 
                                                                         (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                                                            end_date_month IS NULL AND 
                                                                            end_date_day IS NULL) ) ),
    begin_area       INTEGER,-- references area.id
    end_area         INTEGER-- references area.id
);


-- Table: artist_alias
CREATE TABLE artist_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    artist             INTEGER NOT NULL,-- references artist.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references artist_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ),
    CONSTRAINT search_hints_are_empty CHECK ( (type <> 3) OR 
                                              (type = 3 AND 
                                               sort_name = name AND 
                                               begin_date_year IS NULL AND 
                                               begin_date_month IS NULL AND 
                                               begin_date_day IS NULL AND 
                                               end_date_year IS NULL AND 
                                               end_date_month IS NULL AND 
                                               end_date_day IS NULL AND 
                                               primary_for_locale IS FALSE AND 
                                               locale IS NULL) ) 
);


-- Table: artist_alias_type
CREATE TABLE artist_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references artist_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: artist_annotation
CREATE TABLE artist_annotation (-- replicate (verbose)
    artist     INTEGER NOT NULL,-- PK, references artist.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: artist_attribute
CREATE TABLE artist_attribute (-- replicate (verbose)
    id                                  INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    artist                              INTEGER NOT NULL,-- references artist.id
    artist_attribute_type               INTEGER NOT NULL,-- references artist_attribute_type.id
    artist_attribute_type_allowed_value INTEGER,-- references artist_attribute_type_allowed_value.id
    artist_attribute_text               TEXT    CHECK ( (artist_attribute_type_allowed_value IS NULL AND 
                                                         artist_attribute_text IS NOT NULL) OR 
                                                        (artist_attribute_type_allowed_value IS NOT NULL AND 
                                                         artist_attribute_text IS NULL) ) 
);


-- Table: artist_attribute_type
CREATE TABLE artist_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references artist_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: artist_attribute_type_allowed_value
CREATE TABLE artist_attribute_type_allowed_value (-- replicate (verbose)
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    artist_attribute_type INTEGER NOT NULL,-- references artist_attribute_type.id
    value                 TEXT,
    parent                INTEGER,-- references artist_attribute_type_allowed_value.id
    child_order           INTEGER NOT NULL
                                  DEFAULT 0,
    description           TEXT,
    gid                   TEXT    NOT NULL
);


-- Table: artist_credit
CREATE TABLE artist_credit (-- replicate
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    name         VARCHAR NOT NULL,
    artist_count INTEGER NOT NULL,
    ref_count    INTEGER DEFAULT 0,
    created      TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: artist_credit_name
CREATE TABLE artist_credit_name (-- replicate (verbose)
    artist_credit INTEGER NOT NULL,-- PK, references artist_credit.id CASCADE
    position      INTEGER NOT NULL,-- PK
    artist        INTEGER NOT NULL,-- references artist.id CASCADE
    name          VARCHAR NOT NULL,
    join_phrase   TEXT    NOT NULL
                          DEFAULT ''
);


-- Table: artist_gid_redirect
CREATE TABLE artist_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references artist.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: artist_ipi
CREATE TABLE artist_ipi (-- replicate (verbose)
    artist        INTEGER   NOT NULL,-- PK, references artist.id
    ipi           CHAR (11) NOT NULL,-- PK CHECK (ipi ~ E'^\\d{11}$')
    edits_pending INTEGER   NOT NULL
                            DEFAULT 0
                            CHECK (edits_pending >= 0),
    created       TEXT      DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: artist_isni
CREATE TABLE artist_isni (-- replicate (verbose)
    artist        INTEGER   NOT NULL,-- PK, references artist.id
    isni          CHAR (16) NOT NULL,-- PK CHECK (isni ~ E'^\\d{15}[\\dX]$')
    edits_pending INTEGER   NOT NULL
                            DEFAULT 0
                            CHECK (edits_pending >= 0),
    created       TEXT      DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: artist_meta
CREATE TABLE artist_meta (-- replicate
    id           INTEGER NOT NULL,-- PK, references artist.id CASCADE
    rating       INTEGER CHECK (rating >= 0 AND 
                                rating <= 100),
    rating_count INTEGER
);


-- Table: artist_rating_raw
CREATE TABLE artist_rating_raw (
    artist INTEGER NOT NULL,-- PK, references artist.id
    editor INTEGER NOT NULL,-- PK, references editor.id
    rating INTEGER NOT NULL
                   CHECK (rating >= 0 AND 
                          rating <= 100) 
);


-- Table: artist_tag
CREATE TABLE artist_tag (-- replicate (verbose)
    artist       INTEGER NOT NULL,-- PK, references artist.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: artist_tag_raw
CREATE TABLE artist_tag_raw (
    artist    INTEGER NOT NULL,-- PK, references artist.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: artist_type
CREATE TABLE artist_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references artist_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: autoeditor_election
CREATE TABLE autoeditor_election (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    candidate    INTEGER NOT NULL,-- references editor.id
    proposer     INTEGER NOT NULL,-- references editor.id
    seconder_1   INTEGER,-- references editor.id
    seconder_2   INTEGER,-- references editor.id
    status       INTEGER NOT NULL
                         DEFAULT 1
                         CHECK (status IN (1, 2, 3, 4, 5, 6) ),-- 1 : has proposer
    /* 2 : has seconder_1 */yes_votes    INTEGER NOT NULL
                         DEFAULT 0,
    no_votes     INTEGER NOT NULL
                         DEFAULT 0,
    propose_time TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    open_time    TEXT,
    close_time   TEXT
);
-- 3 : has seconder_2 (voting open)-- 4 : accepted!-- 5 : rejected-- 6 : cancelled (by proposer)

-- Table: autoeditor_election_vote
CREATE TABLE autoeditor_election_vote (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    autoeditor_election INTEGER NOT NULL,-- references autoeditor_election.id
    voter               INTEGER NOT NULL,-- references editor.id
    vote                INTEGER NOT NULL
                                CHECK (vote IN ( -1, 0, 1) ),
    vote_time           TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
                                NOT NULL
);


-- Table: cdtoc
CREATE TABLE cdtoc (-- replicate
    id             INTEGER      PRIMARY KEY AUTOINCREMENT,
    discid         CHAR (28)    NOT NULL,
    freedb_id      CHAR (8)     NOT NULL,
    track_count    INTEGER      NOT NULL,
    leadout_offset INTEGER      NOT NULL,
    track_offset   "INTEGER []" NOT NULL,
    degraded       BOOLEAN      NOT NULL
                                DEFAULT FALSE,
    created        TEXT         DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: cdtoc_raw
CREATE TABLE cdtoc_raw (-- replicate
    id             INTEGER      PRIMARY KEY AUTOINCREMENT,-- PK
    [release]      INTEGER      NOT NULL,-- references release_raw.id
    discid         CHAR (28)    NOT NULL,
    track_count    INTEGER      NOT NULL,
    leadout_offset INTEGER      NOT NULL,
    track_offset   "INTEGER []" NOT NULL
);


-- Table: country_area
CREATE TABLE country_area (-- replicate (verbose)
    area INTEGER-- PK, references area.id
);


-- Table: deleted_entity
CREATE TABLE deleted_entity (
    gid        TEXT  NOT NULL,-- PK
    data       JSONB NOT NULL,
    deleted_at TEXT  DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: edit
CREATE TABLE edit (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    editor      INTEGER NOT NULL,-- references editor.id
    type        INTEGER NOT NULL,
    status      INTEGER NOT NULL,
    autoedit    INTEGER NOT NULL
                        DEFAULT 0,
    open_time   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    close_time  TEXT,
    expire_time TEXT    NOT NULL,
    language    INTEGER,-- references language.id
    quality     INTEGER NOT NULL
                        DEFAULT 1
);


-- Table: edit_area
CREATE TABLE edit_area (
    edit INTEGER NOT NULL,-- PK, references edit.id
    area INTEGER NOT NULL-- PK, references area.id CASCADE
);


-- Table: edit_artist
CREATE TABLE edit_artist (
    edit   INTEGER NOT NULL,-- PK, references edit.id
    artist INTEGER NOT NULL,-- PK, references artist.id CASCADE
    status INTEGER NOT NULL-- materialized from edit.status
);


-- Table: edit_data
CREATE TABLE edit_data (
    edit INTEGER NOT NULL,-- PK, references edit.id
    data JSONB   NOT NULL
);


-- Table: edit_event
CREATE TABLE edit_event (
    edit  INTEGER NOT NULL,-- PK, references edit.id
    event INTEGER NOT NULL-- PK, references event.id CASCADE
);


-- Table: edit_instrument
CREATE TABLE edit_instrument (
    edit       INTEGER NOT NULL,-- PK, references edit.id
    instrument INTEGER NOT NULL-- PK, references instrument.id CASCADE
);


-- Table: edit_label
CREATE TABLE edit_label (
    edit   INTEGER NOT NULL,-- PK, references edit.id
    label  INTEGER NOT NULL,-- PK, references label.id CASCADE
    status INTEGER NOT NULL-- materialized from edit.status
);


-- Table: edit_note
CREATE TABLE edit_note (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    editor    INTEGER NOT NULL,-- references editor.id
    edit      INTEGER NOT NULL,-- references edit.id
    text      TEXT    NOT NULL,
    post_time TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: edit_note_recipient
CREATE TABLE edit_note_recipient (
    recipient INTEGER NOT NULL,-- PK, references editor.id
    edit_note INTEGER NOT NULL-- PK, references edit_note.id
);


-- Table: edit_place
CREATE TABLE edit_place (
    edit  INTEGER NOT NULL,-- PK, references edit.id
    place INTEGER NOT NULL-- PK, references place.id CASCADE
);


-- Table: edit_recording
CREATE TABLE edit_recording (
    edit      INTEGER NOT NULL,-- PK, references edit.id
    recording INTEGER NOT NULL-- PK, references recording.id CASCADE
);


-- Table: edit_release
CREATE TABLE edit_release (
    edit      INTEGER NOT NULL,-- PK, references edit.id
    [release] INTEGER NOT NULL-- PK, references release.id CASCADE
);


-- Table: edit_release_group
CREATE TABLE edit_release_group (
    edit          INTEGER NOT NULL,-- PK, references edit.id
    release_group INTEGER NOT NULL-- PK, references release_group.id CASCADE
);


-- Table: edit_series
CREATE TABLE edit_series (
    edit   INTEGER NOT NULL,-- PK, references edit.id
    series INTEGER NOT NULL-- PK, references series.id CASCADE
);


-- Table: edit_url
CREATE TABLE edit_url (
    edit INTEGER NOT NULL,-- PK, references edit.id
    url  INTEGER NOT NULL-- PK, references url.id CASCADE
);


-- Table: edit_work
CREATE TABLE edit_work (
    edit INTEGER NOT NULL,-- PK, references edit.id
    work INTEGER NOT NULL-- PK, references work.id CASCADE
);


-- Table: editor
CREATE TABLE editor (
    id                 INTEGER       PRIMARY KEY AUTOINCREMENT,
    name               VARCHAR (64)  NOT NULL,
    privs              INTEGER       DEFAULT 0,
    email              VARCHAR (64)  DEFAULT NULL,
    website            VARCHAR (255) DEFAULT NULL,
    bio                TEXT          DEFAULT NULL,
    member_since       TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    email_confirm_date TEXT,
    last_login_date    TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    last_updated       TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    birth_date         DATE,
    gender             INTEGER,-- references gender.id
    area               INTEGER,-- references area.id
    password           VARCHAR (128) NOT NULL,
    ha1                CHAR (32)     NOT NULL,
    deleted            BOOLEAN       NOT NULL
                                     DEFAULT FALSE
);


-- Table: editor_collection
CREATE TABLE editor_collection (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    gid         TEXT    NOT NULL,
    editor      INTEGER NOT NULL,-- references editor.id
    name        VARCHAR NOT NULL,
    public      BOOLEAN NOT NULL
                        DEFAULT FALSE,
    description TEXT    DEFAULT ''
                        NOT NULL,
    type        INTEGER NOT NULL-- references editor_collection_type.id
);


-- Table: editor_collection_area
CREATE TABLE editor_collection_area (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    area       INTEGER NOT NULL-- PK, references area.id
);


-- Table: editor_collection_artist
CREATE TABLE editor_collection_artist (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    artist     INTEGER NOT NULL-- PK, references artist.id
);


-- Table: editor_collection_deleted_entity
CREATE TABLE editor_collection_deleted_entity (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    gid        TEXT    NOT NULL-- PK, references deleted_entity.gid
);


-- Table: editor_collection_event
CREATE TABLE editor_collection_event (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    event      INTEGER NOT NULL-- PK, references event.id
);


-- Table: editor_collection_instrument
CREATE TABLE editor_collection_instrument (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    instrument INTEGER NOT NULL-- PK, references instrument.id
);


-- Table: editor_collection_label
CREATE TABLE editor_collection_label (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    label      INTEGER NOT NULL-- PK, references label.id
);


-- Table: editor_collection_place
CREATE TABLE editor_collection_place (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    place      INTEGER NOT NULL-- PK, references place.id
);


-- Table: editor_collection_recording
CREATE TABLE editor_collection_recording (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    recording  INTEGER NOT NULL-- PK, references recording.id
);


-- Table: editor_collection_release
CREATE TABLE editor_collection_release (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    [release]  INTEGER NOT NULL-- PK, references release.id
);


-- Table: editor_collection_release_group
CREATE TABLE editor_collection_release_group (
    collection    INTEGER NOT NULL,-- PK, references editor_collection.id
    release_group INTEGER NOT NULL-- PK, references release_group.id
);


-- Table: editor_collection_series
CREATE TABLE editor_collection_series (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    series     INTEGER NOT NULL-- PK, references series.id
);


-- Table: editor_collection_type
CREATE TABLE editor_collection_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    entity_type VARCHAR (50)  NOT NULL,
    parent      INTEGER,-- references editor_collection_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: editor_collection_work
CREATE TABLE editor_collection_work (
    collection INTEGER NOT NULL,-- PK, references editor_collection.id
    work       INTEGER NOT NULL-- PK, references work.id
);


-- Table: editor_language
CREATE TABLE editor_language (
    editor   INTEGER NOT NULL,-- PK, references editor.id
    language INTEGER NOT NULL,-- PK, references language.id
    fluency  INTEGER NOT NULL
                     CHECK (fluency IN ('basic', 'intermediate', 'advanced', 'native') ) 
);


-- Table: editor_oauth_token
CREATE TABLE editor_oauth_token (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    editor             INTEGER NOT NULL,-- references editor.id
    application        INTEGER NOT NULL,-- references application.id
    authorization_code TEXT,
    refresh_token      TEXT,
    access_token       TEXT,
    expire_time        TEXT    NOT NULL,
    scope              INTEGER NOT NULL
                               DEFAULT 0,
    granted            TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
                               NOT NULL
);


-- Table: editor_preference
CREATE TABLE editor_preference (
    id     INTEGER       PRIMARY KEY AUTOINCREMENT,
    editor INTEGER       NOT NULL,-- references editor.id
    name   VARCHAR (50)  NOT NULL,
    value  VARCHAR (100) NOT NULL
);


-- Table: editor_subscribe_artist
CREATE TABLE editor_subscribe_artist (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    editor         INTEGER NOT NULL,-- references editor.id
    artist         INTEGER NOT NULL,-- references artist.id
    last_edit_sent INTEGER NOT NULL-- references edit.id
);


-- Table: editor_subscribe_artist_deleted
CREATE TABLE editor_subscribe_artist_deleted (
    editor     INTEGER NOT NULL,-- PK, references editor.id
    gid        TEXT    NOT NULL,-- PK, references deleted_entity.gid
    deleted_by INTEGER NOT NULL-- references edit.id
);


-- Table: editor_subscribe_collection
CREATE TABLE editor_subscribe_collection (
    id             INTEGER       PRIMARY KEY AUTOINCREMENT,
    editor         INTEGER       NOT NULL,-- references editor.id
    collection     INTEGER       NOT NULL,-- weakly references editor_collection.id
    last_edit_sent INTEGER       NOT NULL,-- weakly references edit.id
    available      BOOLEAN       NOT NULL
                                 DEFAULT TRUE,
    last_seen_name VARCHAR (255) 
);


-- Table: editor_subscribe_editor
CREATE TABLE editor_subscribe_editor (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    editor            INTEGER NOT NULL,-- references editor.id (the one who has subscribed)
    subscribed_editor INTEGER NOT NULL,-- references editor.id (the one being subscribed)
    last_edit_sent    INTEGER NOT NULL-- weakly references edit.id
);


-- Table: editor_subscribe_label
CREATE TABLE editor_subscribe_label (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    editor         INTEGER NOT NULL,-- references editor.id
    label          INTEGER NOT NULL,-- references label.id
    last_edit_sent INTEGER NOT NULL-- references edit.id
);


-- Table: editor_subscribe_label_deleted
CREATE TABLE editor_subscribe_label_deleted (
    editor     INTEGER NOT NULL,-- PK, references editor.id
    gid        TEXT    NOT NULL,-- PK, references deleted_entity.gid
    deleted_by INTEGER NOT NULL-- references edit.id
);


-- Table: editor_subscribe_series
CREATE TABLE editor_subscribe_series (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    editor         INTEGER NOT NULL,-- references editor.id
    series         INTEGER NOT NULL,-- references series.id
    last_edit_sent INTEGER NOT NULL-- references edit.id
);


-- Table: editor_subscribe_series_deleted
CREATE TABLE editor_subscribe_series_deleted (
    editor     INTEGER NOT NULL,-- PK, references editor.id
    gid        TEXT    NOT NULL,-- PK, references deleted_entity.gid
    deleted_by INTEGER NOT NULL-- references edit.id
);


-- Table: editor_watch_artist
CREATE TABLE editor_watch_artist (
    artist INTEGER NOT NULL,-- PK, references artist.id CASCADE
    editor INTEGER NOT NULL-- PK, references editor.id CASCADE
);


-- Table: editor_watch_preferences
CREATE TABLE editor_watch_preferences (
    editor                 INTEGER  NOT NULL,-- PK, references editor.id CASCADE
    notify_via_email       BOOLEAN  NOT NULL
                                    DEFAULT TRUE,
    notification_timeframe INTERVAL NOT NULL
                                    DEFAULT '1 week',
    last_checked           TEXT     DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
                                    NOT NULL
);


-- Table: editor_watch_release_group_type
CREATE TABLE editor_watch_release_group_type (
    editor             INTEGER NOT NULL,-- PK, references editor.id CASCADE
    release_group_type INTEGER NOT NULL-- PK, references release_group_primary_type.id
);


-- Table: editor_watch_release_status
CREATE TABLE editor_watch_release_status (
    editor         INTEGER NOT NULL,-- PK, references editor.id CASCADE
    release_status INTEGER NOT NULL-- PK, references release_status.id
);


-- Table: event
CREATE TABLE event (-- replicate (verbose)
    id               INTEGER                  PRIMARY KEY AUTOINCREMENT,
    gid              TEXT                     NOT NULL,
    name             VARCHAR                  NOT NULL,
    begin_date_year  INTEGER,
    begin_date_month INTEGER,
    begin_date_day   INTEGER,
    end_date_year    INTEGER,
    end_date_month   INTEGER,
    end_date_day     INTEGER,
    time             [TIME WITHOUT TIME ZONE],
    type             INTEGER,
    cancelled        BOOLEAN                  NOT/* references event_type.id */ NULL
                                              DEFAULT FALSE,
    setlist          TEXT,
    comment          VARCHAR (255)            NOT NULL
                                              DEFAULT '',
    edits_pending    INTEGER                  NOT NULL
                                              DEFAULT 0
                                              CHECK (edits_pending >= 0),
    last_updated     TEXT                     DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    ended            BOOLEAN                  NOT NULL
                                              DEFAULT FALSE
                                              CONSTRAINT event_ended_check CHECK ( ( (end_date_year IS/* If any end date fields are not null, then ended must be true */ NOT NULL OR 
                                                                                      end_date_month IS NOT NULL OR 
                                                                                      end_date_day IS NOT NULL) AND 
                                                                                     ended = TRUE) OR 
                                                                                   ( (end_date_year IS/* Otherwise, all end date fields must be null */ NULL AND 
                                                                                      end_date_month IS NULL AND 
                                                                                      end_date_day IS NULL) ) ) 
);


-- Table: event_alias
CREATE TABLE event_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    event              INTEGER NOT NULL,-- references event.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references event_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ),
    CONSTRAINT search_hints_are_empty CHECK ( (type <> 2) OR 
                                              (type = 2 AND 
                                               sort_name = name AND 
                                               begin_date_year IS NULL AND 
                                               begin_date_month IS NULL AND 
                                               begin_date_day IS NULL AND 
                                               end_date_year IS NULL AND 
                                               end_date_month IS NULL AND 
                                               end_date_day IS NULL AND 
                                               primary_for_locale IS FALSE AND 
                                               locale IS NULL) ) 
);


-- Table: event_alias_type
CREATE TABLE event_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references event_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: event_annotation
CREATE TABLE event_annotation (-- replicate (verbose)
    event      INTEGER NOT NULL,-- PK, references event.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: event_attribute
CREATE TABLE event_attribute (-- replicate (verbose)
    id                                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    event                              INTEGER NOT NULL,-- references event.id
    event_attribute_type               INTEGER NOT NULL,-- references event_attribute_type.id
    event_attribute_type_allowed_value INTEGER,-- references event_attribute_type_allowed_value.id
    event_attribute_text               TEXT    CHECK ( (event_attribute_type_allowed_value IS NULL AND 
                                                        event_attribute_text IS NOT NULL) OR 
                                                       (event_attribute_type_allowed_value IS NOT NULL AND 
                                                        event_attribute_text IS NULL) ) 
);


-- Table: event_attribute_type
CREATE TABLE event_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references event_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: event_attribute_type_allowed_value
CREATE TABLE event_attribute_type_allowed_value (-- replicate (verbose)
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    event_attribute_type INTEGER NOT NULL,-- references event_attribute_type.id
    value                TEXT,
    parent               INTEGER,-- references event_attribute_type_allowed_value.id
    child_order          INTEGER NOT NULL
                                 DEFAULT 0,
    description          TEXT,
    gid                  TEXT    NOT NULL
);


-- Table: event_gid_redirect
CREATE TABLE event_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references event.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: event_meta
CREATE TABLE event_meta (-- replicate
    id           INTEGER NOT NULL,-- PK, references event.id CASCADE
    rating       INTEGER CHECK (rating >= 0 AND 
                                rating <= 100),
    rating_count INTEGER
);


-- Table: event_rating_raw
CREATE TABLE event_rating_raw (
    event  INTEGER NOT NULL,-- PK, references event.id
    editor INTEGER NOT NULL,-- PK, references editor.id
    rating INTEGER NOT NULL
                   CHECK (rating >= 0 AND 
                          rating <= 100) 
);


-- Table: event_tag
CREATE TABLE event_tag (-- replicate (verbose)
    event        INTEGER NOT NULL,-- PK, references event.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: event_tag_raw
CREATE TABLE event_tag_raw (
    event     INTEGER NOT NULL,-- PK, references event.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: event_type
CREATE TABLE event_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references event_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: gender
CREATE TABLE gender (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references gender.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: instrument
CREATE TABLE instrument (-- replicate (verbose)
    id            INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    gid           TEXT          NOT NULL,
    name          VARCHAR       NOT NULL,
    type          INTEGER,-- references instrument_type.id
    edits_pending INTEGER       NOT NULL
                                DEFAULT 0
                                CHECK (edits_pending >= 0),
    last_updated  TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    comment       VARCHAR (255) NOT NULL
                                DEFAULT '',
    description   TEXT          NOT NULL
                                DEFAULT ''
);


-- Table: instrument_alias
CREATE TABLE instrument_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    instrument         INTEGER NOT NULL,-- references instrument.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references instrument_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ),
    CONSTRAINT search_hints_are_empty CHECK ( (type <> 2) OR 
                                              (type = 2 AND 
                                               sort_name = name AND 
                                               begin_date_year IS NULL AND 
                                               begin_date_month IS NULL AND 
                                               begin_date_day IS NULL AND 
                                               end_date_year IS NULL AND 
                                               end_date_month IS NULL AND 
                                               end_date_day IS NULL AND 
                                               primary_for_locale IS FALSE AND 
                                               locale IS NULL) ) 
);


-- Table: instrument_alias_type
CREATE TABLE instrument_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,-- PK,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references instrument_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: instrument_annotation
CREATE TABLE instrument_annotation (-- replicate (verbose)
    instrument INTEGER NOT NULL,-- PK, references instrument.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: instrument_attribute
CREATE TABLE instrument_attribute (-- replicate (verbose)
    id                                      INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    instrument                              INTEGER NOT NULL,-- references instrument.id
    instrument_attribute_type               INTEGER NOT NULL,-- references instrument_attribute_type.id
    instrument_attribute_type_allowed_value INTEGER,-- references instrument_attribute_type_allowed_value.id
    instrument_attribute_text               TEXT    CHECK ( (instrument_attribute_type_allowed_value IS NULL AND 
                                                             instrument_attribute_text IS NOT NULL) OR 
                                                            (instrument_attribute_type_allowed_value IS NOT NULL AND 
                                                             instrument_attribute_text IS NULL) ) 
);


-- Table: instrument_attribute_type
CREATE TABLE instrument_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references instrument_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: instrument_attribute_type_allowed_value
CREATE TABLE instrument_attribute_type_allowed_value (-- replicate (verbose)
    id                        INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    instrument_attribute_type INTEGER NOT NULL,-- references instrument_attribute_type.id
    value                     TEXT,
    parent                    INTEGER,-- references instrument_attribute_type_allowed_value.id
    child_order               INTEGER NOT NULL
                                      DEFAULT 0,
    description               TEXT,
    gid                       TEXT    NOT NULL
);


-- Table: instrument_gid_redirect
CREATE TABLE instrument_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references instrument.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: instrument_tag
CREATE TABLE instrument_tag (-- replicate (verbose)
    instrument   INTEGER NOT NULL,-- PK, references instrument.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: instrument_tag_raw
CREATE TABLE instrument_tag_raw (
    instrument INTEGER NOT NULL,-- PK, references instrument.id
    editor     INTEGER NOT NULL,-- PK, references editor.id
    tag        INTEGER NOT NULL,-- PK, references tag.id
    is_upvote  BOOLEAN NOT NULL
                       DEFAULT TRUE
);


-- Table: instrument_type
CREATE TABLE instrument_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references instrument_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: iso_3166_1
CREATE TABLE iso_3166_1 (-- replicate
    area INTEGER  NOT NULL,-- references area.id
    code CHAR (2)-- PK 
);


-- Table: iso_3166_2
CREATE TABLE iso_3166_2 (-- replicate
    area INTEGER      NOT NULL,-- references area.id
    code VARCHAR (10)-- PK 
);


-- Table: iso_3166_3
CREATE TABLE iso_3166_3 (-- replicate
    area INTEGER  NOT NULL,-- references area.id
    code CHAR (4)-- PK 
);


-- Table: isrc
CREATE TABLE isrc (-- replicate (verbose)
    id            INTEGER   PRIMARY KEY AUTOINCREMENT,
    recording     INTEGER   NOT NULL,-- references recording.id
    isrc          CHAR (12) NOT NULL,-- CHECK (isrc ~ E'^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$')
    source        INTEGER,
    edits_pending INTEGER   NOT NULL
                            DEFAULT 0
                            CHECK (edits_pending >= 0),
    created       TEXT      DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: iswc
CREATE TABLE iswc (-- replicate (verbose)
    id            INTEGER   PRIMARY KEY AUTOINCREMENT
                            NOT NULL,
    work          INTEGER   NOT NULL,-- references work.id
    iswc          CHAR (15),-- CHECK (iswc ~ E'^T-?\\d{3}.?\\d{3}.?\\d{3}[-.]?\\d$')
    source        INTEGER,
    edits_pending INTEGER   NOT NULL
                            DEFAULT 0,
    created       TEXT      DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
                            NOT NULL
);


-- Table: l_area_area
CREATE TABLE l_area_area (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references area.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_artist
CREATE TABLE l_area_artist (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references artist.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_event
CREATE TABLE l_area_event (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references event.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_instrument
CREATE TABLE l_area_instrument (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references instrument.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_label
CREATE TABLE l_area_label (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references label.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_place
CREATE TABLE l_area_place (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references place.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_recording
CREATE TABLE l_area_recording (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references recording.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_release
CREATE TABLE l_area_release (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references release.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_release_group
CREATE TABLE l_area_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_series
CREATE TABLE l_area_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_url
CREATE TABLE l_area_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_area_work
CREATE TABLE l_area_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references area.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_artist
CREATE TABLE l_artist_artist (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references artist.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_event
CREATE TABLE l_artist_event (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references event.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_instrument
CREATE TABLE l_artist_instrument (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references instrument.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_label
CREATE TABLE l_artist_label (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references label.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_place
CREATE TABLE l_artist_place (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references place.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_recording
CREATE TABLE l_artist_recording (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references recording.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_release
CREATE TABLE l_artist_release (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references release.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_release_group
CREATE TABLE l_artist_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_series
CREATE TABLE l_artist_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_url
CREATE TABLE l_artist_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_artist_work
CREATE TABLE l_artist_work (-- replicate (verbose)
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references artist.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_event
CREATE TABLE l_event_event (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references event.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_instrument
CREATE TABLE l_event_instrument (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references instrument.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_label
CREATE TABLE l_event_label (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references label.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_place
CREATE TABLE l_event_place (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references place.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_recording
CREATE TABLE l_event_recording (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references recording.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_release
CREATE TABLE l_event_release (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references release.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_release_group
CREATE TABLE l_event_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_series
CREATE TABLE l_event_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_url
CREATE TABLE l_event_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_event_work
CREATE TABLE l_event_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references event.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_instrument
CREATE TABLE l_instrument_instrument (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references instrument.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_label
CREATE TABLE l_instrument_label (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references label.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_place
CREATE TABLE l_instrument_place (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references place.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_recording
CREATE TABLE l_instrument_recording (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references recording.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_release
CREATE TABLE l_instrument_release (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references release.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_release_group
CREATE TABLE l_instrument_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_series
CREATE TABLE l_instrument_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_url
CREATE TABLE l_instrument_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_instrument_work
CREATE TABLE l_instrument_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references instrument.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_label_label
CREATE TABLE l_label_label (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references label.id
    entity1        INTEGER NOT NULL,-- references label.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_label_place
CREATE TABLE l_label_place (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references label.id
    entity1        INTEGER NOT NULL,-- references place.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_label_recording
CREATE TABLE l_label_recording (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references label.id
    entity1        INTEGER NOT NULL,-- references recording.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_label_release
CREATE TABLE l_label_release (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references label.id
    entity1        INTEGER NOT NULL,-- references release.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_label_release_group
CREATE TABLE l_label_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references label.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_label_series
CREATE TABLE l_label_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references label.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_label_url
CREATE TABLE l_label_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references label.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_label_work
CREATE TABLE l_label_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references label.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_place_place
CREATE TABLE l_place_place (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references place.id
    entity1        INTEGER NOT NULL,-- references place.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_place_recording
CREATE TABLE l_place_recording (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references place.id
    entity1        INTEGER NOT NULL,-- references recording.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_place_release
CREATE TABLE l_place_release (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references place.id
    entity1        INTEGER NOT NULL,-- references release.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_place_release_group
CREATE TABLE l_place_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references place.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_place_series
CREATE TABLE l_place_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references place.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_place_url
CREATE TABLE l_place_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references place.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_place_work
CREATE TABLE l_place_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references place.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_recording_recording
CREATE TABLE l_recording_recording (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references recording.id
    entity1        INTEGER NOT NULL,-- references recording.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_recording_release
CREATE TABLE l_recording_release (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references recording.id
    entity1        INTEGER NOT NULL,-- references release.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_recording_release_group
CREATE TABLE l_recording_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references recording.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_recording_series
CREATE TABLE l_recording_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references recording.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_recording_url
CREATE TABLE l_recording_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references recording.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_recording_work
CREATE TABLE l_recording_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references recording.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_group_release_group
CREATE TABLE l_release_group_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release_group.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_group_series
CREATE TABLE l_release_group_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release_group.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_group_url
CREATE TABLE l_release_group_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release_group.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_group_work
CREATE TABLE l_release_group_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release_group.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_release
CREATE TABLE l_release_release (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release.id
    entity1        INTEGER NOT NULL,-- references release.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_release_group
CREATE TABLE l_release_release_group (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release.id
    entity1        INTEGER NOT NULL,-- references release_group.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_series
CREATE TABLE l_release_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_url
CREATE TABLE l_release_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_release_work
CREATE TABLE l_release_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references release.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_series_series
CREATE TABLE l_series_series (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references series.id
    entity1        INTEGER NOT NULL,-- references series.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_series_url
CREATE TABLE l_series_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references series.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_series_work
CREATE TABLE l_series_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references series.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_url_url
CREATE TABLE l_url_url (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references url.id
    entity1        INTEGER NOT NULL,-- references url.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_url_work
CREATE TABLE l_url_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references url.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: l_work_work
CREATE TABLE l_work_work (-- replicate
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    link           INTEGER NOT NULL,-- references link.id
    entity0        INTEGER NOT NULL,-- references work.id
    entity1        INTEGER NOT NULL,-- references work.id
    edits_pending  INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (edits_pending >= 0),
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    link_order     INTEGER NOT NULL
                           DEFAULT 0
                           CHECK (link_order >= 0),
    entity0_credit TEXT    NOT NULL
                           DEFAULT '',
    entity1_credit TEXT    NOT NULL
                           DEFAULT ''
);


-- Table: label
CREATE TABLE label (-- replicate (verbose)
    id               INTEGER       PRIMARY KEY AUTOINCREMENT,
    gid              TEXT          NOT NULL,
    name             VARCHAR       NOT NULL,
    begin_date_year  INTEGER,
    begin_date_month INTEGER,
    begin_date_day   INTEGER,
    end_date_year    INTEGER,
    end_date_month   INTEGER,
    end_date_day     INTEGER,
    label_code       INTEGER       CHECK (label_code > 0 AND 
                                          label_code < 100000),
    type             INTEGER,-- references label_type.id
    area             INTEGER,-- references area.id
    comment          VARCHAR (255) NOT NULL
                                   DEFAULT '',
    edits_pending    INTEGER       NOT NULL
                                   DEFAULT 0
                                   CHECK (edits_pending >= 0),
    last_updated     TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    ended            BOOLEAN       NOT NULL
                                   DEFAULT FALSE
                                   CONSTRAINT label_ended_check CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                                                           end_date_month IS NOT NULL OR 
                                                                           end_date_day IS NOT NULL) AND 
                                                                          ended = TRUE) OR 
                                                                        (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                                                           end_date_month IS NULL AND 
                                                                           end_date_day IS NULL) ) ) 
);


-- Table: label_alias
CREATE TABLE label_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    label              INTEGER NOT NULL,-- references label.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references label_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ),
    CONSTRAINT search_hints_are_empty CHECK ( (type <> 2) OR 
                                              (type = 2 AND 
                                               sort_name = name AND 
                                               begin_date_year IS NULL AND 
                                               begin_date_month IS NULL AND 
                                               begin_date_day IS NULL AND 
                                               end_date_year IS NULL AND 
                                               end_date_month IS NULL AND 
                                               end_date_day IS NULL AND 
                                               primary_for_locale IS FALSE AND 
                                               locale IS NULL) ) 
);


-- Table: label_alias_type
CREATE TABLE label_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references label_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: label_annotation
CREATE TABLE label_annotation (-- replicate (verbose)
    label      INTEGER NOT NULL,-- PK, references label.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: label_attribute
CREATE TABLE label_attribute (-- replicate (verbose)
    id                                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    label                              INTEGER NOT NULL,-- references label.id
    label_attribute_type               INTEGER NOT NULL,-- references label_attribute_type.id
    label_attribute_type_allowed_value INTEGER,-- references label_attribute_type_allowed_value.id
    label_attribute_text               TEXT    CHECK ( (label_attribute_type_allowed_value IS NULL AND 
                                                        label_attribute_text IS NOT NULL) OR 
                                                       (label_attribute_type_allowed_value IS NOT NULL AND 
                                                        label_attribute_text IS NULL) ) 
);


-- Table: label_attribute_type
CREATE TABLE label_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references label_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: label_attribute_type_allowed_value
CREATE TABLE label_attribute_type_allowed_value (-- replicate (verbose)
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    label_attribute_type INTEGER NOT NULL,-- references label_attribute_type.id
    value                TEXT,
    parent               INTEGER,-- references label_attribute_type_allowed_value.id
    child_order          INTEGER NOT NULL
                                 DEFAULT 0,
    description          TEXT,
    gid                  TEXT    NOT NULL
);


-- Table: label_gid_redirect
CREATE TABLE label_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references label.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: label_ipi
CREATE TABLE label_ipi (-- replicate (verbose)
    label         INTEGER   NOT NULL,-- PK, references label.id
    ipi           CHAR (11) NOT NULL,-- PK CHECK (ipi ~ E'^\\d{11}$')
    edits_pending INTEGER   NOT NULL
                            DEFAULT 0
                            CHECK (edits_pending >= 0),
    created       TEXT      DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: label_isni
CREATE TABLE label_isni (-- replicate (verbose)
    label         INTEGER   NOT NULL,-- PK, references label.id
    isni          CHAR (16) NOT NULL,-- PK CHECK (isni ~ E'^\\d{15}[\\dX]$')
    edits_pending INTEGER   NOT NULL
                            DEFAULT 0
                            CHECK (edits_pending >= 0),
    created       TEXT      DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: label_meta
CREATE TABLE label_meta (-- replicate
    id           INTEGER NOT NULL,-- PK, references label.id CASCADE
    rating       INTEGER CHECK (rating >= 0 AND 
                                rating <= 100),
    rating_count INTEGER
);


-- Table: label_rating_raw
CREATE TABLE label_rating_raw (
    label  INTEGER NOT NULL,-- PK, references label.id
    editor INTEGER NOT NULL,-- PK, references editor.id
    rating INTEGER NOT NULL
                   CHECK (rating >= 0 AND 
                          rating <= 100) 
);


-- Table: label_tag
CREATE TABLE label_tag (-- replicate (verbose)
    label        INTEGER NOT NULL,-- PK, references label.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: label_tag_raw
CREATE TABLE label_tag_raw (
    label     INTEGER NOT NULL,-- PK, references label.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: label_type
CREATE TABLE label_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references label_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: language
CREATE TABLE language (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    iso_code_2t CHAR (3),-- ISO 639-2 (T)
    iso_code_2b CHAR (3),-- ISO 639-2 (B)
    iso_code_1  CHAR (2),-- ISO 639
    name        VARCHAR (100) NOT NULL,
    frequency   INTEGER       NOT NULL
                              DEFAULT 0,
    iso_code_3  CHAR (3)/* ISO 639-3, */      CHECK (iso_code_2t IS NOT NULL OR 
                                     iso_code_3 IS NOT NULL) 
);


-- Table: link
CREATE TABLE link (-- replicate
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    link_type        INTEGER NOT NULL,-- references link_type.id
    begin_date_year  INTEGER,
    begin_date_month INTEGER,
    begin_date_day   INTEGER,
    end_date_year    INTEGER,
    end_date_month   INTEGER,
    end_date_day     INTEGER,
    attribute_count  INTEGER NOT NULL
                             DEFAULT 0,
    created          TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    ended            BOOLEAN NOT NULL
                             DEFAULT FALSE
                             CONSTRAINT link_ended_check CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                                                    end_date_month IS NOT NULL OR 
                                                                    end_date_day IS NOT NULL) AND 
                                                                   ended = TRUE) OR 
                                                                 (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                                                    end_date_month IS NULL AND 
                                                                    end_date_day IS NULL) ) ) 
);


-- Table: link_attribute
CREATE TABLE link_attribute (-- replicate
    link           INTEGER NOT NULL,-- PK, references link.id
    attribute_type INTEGER NOT NULL,-- PK, references link_attribute_type.id
    created        TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: link_attribute_credit
CREATE TABLE link_attribute_credit (-- replicate
    link           INT  NOT NULL,-- PK, references link.id
    attribute_type INT  NOT NULL,-- PK, references link_creditable_attribute_type.attribute_type
    credited_as    TEXT NOT NULL
);


-- Table: link_attribute_text_value
CREATE TABLE link_attribute_text_value (-- replicate
    link           INT  NOT NULL,-- PK, references link.id
    attribute_type INT  NOT NULL,-- PK, references link_text_attribute_type.attribute_type
    text_value     TEXT NOT NULL
);


-- Table: link_attribute_type
CREATE TABLE link_attribute_type (-- replicate
    id           INTEGER       PRIMARY KEY AUTOINCREMENT,
    parent       INTEGER,-- references link_attribute_type.id
    root         INTEGER       NOT NULL,-- references link_attribute_type.id
    child_order  INTEGER       NOT NULL
                               DEFAULT 0,
    gid          TEXT          NOT NULL,
    name         VARCHAR (255) NOT NULL,
    description  TEXT,
    last_updated TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: link_creditable_attribute_type
CREATE TABLE link_creditable_attribute_type (-- replicate
    attribute_type INT NOT NULL-- PK, references link_attribute_type.id CASCADE
);


-- Table: link_text_attribute_type
CREATE TABLE link_text_attribute_type (-- replicate
    attribute_type INT NOT NULL-- PK, references link_attribute_type.id CASCADE
);


-- Table: link_type
CREATE TABLE link_type (-- replicate
    id                  INTEGER       PRIMARY KEY AUTOINCREMENT,
    parent              INTEGER,-- references link_type.id
    child_order         INTEGER       NOT NULL
                                      DEFAULT 0,
    gid                 TEXT          NOT NULL,
    entity_type0        VARCHAR (50)  NOT NULL,
    entity_type1        VARCHAR (50)  NOT NULL,
    name                VARCHAR (255) NOT NULL,
    description         TEXT,
    link_phrase         VARCHAR (255) NOT NULL,
    reverse_link_phrase VARCHAR (255) NOT NULL,
    long_link_phrase    VARCHAR (255) NOT NULL,
    priority            INTEGER       NOT NULL
                                      DEFAULT 0,
    last_updated        TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    is_deprecated       BOOLEAN       NOT NULL
                                      DEFAULT false,
    has_dates           BOOLEAN       NOT NULL
                                      DEFAULT true,
    entity0_cardinality INTEGER       NOT NULL
                                      DEFAULT 0,
    entity1_cardinality INTEGER       NOT NULL
                                      DEFAULT 0
);


-- Table: link_type_attribute_type
CREATE TABLE link_type_attribute_type (-- replicate
    link_type      INTEGER NOT NULL,-- PK, references link_type.id
    attribute_type INTEGER NOT NULL,-- PK, references link_attribute_type.id
    min            INTEGER,
    max            INTEGER,
    last_updated   TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: medium
CREATE TABLE medium (-- replicate (verbose)
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    [release]     INTEGER NOT NULL,-- references release.id
    position      INTEGER NOT NULL,
    format        INTEGER,-- references medium_format.id
    name          VARCHAR NOT NULL
                          DEFAULT '',
    edits_pending INTEGER NOT NULL
                          DEFAULT 0
                          CHECK (edits_pending >= 0),
    last_updated  TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    track_count   INTEGER NOT NULL
                          DEFAULT 0
);


-- Table: medium_attribute
CREATE TABLE medium_attribute (-- replicate (verbose)
    id                                  INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    medium                              INTEGER NOT NULL,-- references medium.id
    medium_attribute_type               INTEGER NOT NULL,-- references medium_attribute_type.id
    medium_attribute_type_allowed_value INTEGER,-- references medium_attribute_type_allowed_value.id
    medium_attribute_text               TEXT    CHECK ( (medium_attribute_type_allowed_value IS NULL AND 
                                                         medium_attribute_text IS NOT NULL) OR 
                                                        (medium_attribute_type_allowed_value IS NOT NULL AND 
                                                         medium_attribute_text IS NULL) ) 
);


-- Table: medium_attribute_type
CREATE TABLE medium_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references medium_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: medium_attribute_type_allowed_format
CREATE TABLE medium_attribute_type_allowed_format (-- replicate (verbose)
    medium_format         INTEGER NOT NULL,-- PK, references medium_format.id,
    medium_attribute_type INTEGER NOT NULL-- PK, references medium_attribute_type.id
);


-- Table: medium_attribute_type_allowed_value
CREATE TABLE medium_attribute_type_allowed_value (-- replicate (verbose)
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    medium_attribute_type INTEGER NOT NULL,-- references medium_attribute_type.id
    value                 TEXT,
    parent                INTEGER,-- references medium_attribute_type_allowed_value.id
    child_order           INTEGER NOT NULL
                                  DEFAULT 0,
    description           TEXT,
    gid                   TEXT    NOT NULL
);


-- Table: medium_attribute_type_allowed_value_allowed_format
CREATE TABLE medium_attribute_type_allowed_value_allowed_format (-- replicate (verbose)
    medium_format                       INTEGER NOT NULL,-- PK, references medium_format.id,
    medium_attribute_type_allowed_value INTEGER NOT NULL-- PK, references medium_attribute_type_allowed_value.id
);


-- Table: medium_cdtoc
CREATE TABLE medium_cdtoc (-- replicate (verbose)
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    medium        INTEGER NOT NULL,-- references medium.id
    cdtoc         INTEGER NOT NULL,-- references cdtoc.id
    edits_pending INTEGER NOT NULL
                          DEFAULT 0
                          CHECK (edits_pending >= 0),
    last_updated  TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: medium_format
CREATE TABLE medium_format (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (100) NOT NULL,
    parent      INTEGER,-- references medium_format.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    year        INTEGER,
    has_discids BOOLEAN       NOT NULL
                              DEFAULT FALSE,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: medium_index
CREATE TABLE medium_index (-- replicate
    medium INTEGER,-- PK, references medium.id CASCADE
    toc    CUBE
);


-- Table: old_editor_name
CREATE TABLE old_editor_name (
    name VARCHAR (64) NOT NULL
);


-- Table: orderable_link_type
CREATE TABLE orderable_link_type (-- replicate
    link_type INTEGER NOT NULL,-- PK, references link_type.id
    direction INTEGER NOT NULL
                      DEFAULT 1
                      CHECK (direction = 1 OR 
                             direction = 2) 
);


-- Table: place
CREATE TABLE place (-- replicate (verbose)
    id               INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    gid              TEXT          NOT NULL,
    name             VARCHAR       NOT NULL,
    type             INTEGER,-- references place_type.id
    address          VARCHAR       NOT NULL
                                   DEFAULT '',
    area             INTEGER,-- references area.id
    coordinates      POINT,
    comment          VARCHAR (255) NOT NULL
                                   DEFAULT '',
    edits_pending    INTEGER       NOT NULL
                                   DEFAULT 0
                                   CHECK (edits_pending >= 0),
    last_updated     TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    begin_date_year  INTEGER,
    begin_date_month INTEGER,
    begin_date_day   INTEGER,
    end_date_year    INTEGER,
    end_date_month   INTEGER,
    end_date_day     INTEGER,
    ended            BOOLEAN       NOT NULL
                                   DEFAULT FALSE
                                   CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                              end_date_month IS NOT NULL OR 
                                              end_date_day IS NOT NULL) AND 
                                             ended = TRUE) OR 
                                           (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                              end_date_month IS NULL AND 
                                              end_date_day IS NULL) ) ) 
);


-- Table: place_alias
CREATE TABLE place_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    place              INTEGER NOT NULL,-- references place.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references place_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ),
    CONSTRAINT search_hints_are_empty CHECK ( (type <> 2) OR 
                                              (type = 2 AND 
                                               sort_name = name AND 
                                               begin_date_year IS NULL AND 
                                               begin_date_month IS NULL AND 
                                               begin_date_day IS NULL AND 
                                               end_date_year IS NULL AND 
                                               end_date_month IS NULL AND 
                                               end_date_day IS NULL AND 
                                               primary_for_locale IS FALSE AND 
                                               locale IS NULL) ) 
);


-- Table: place_alias_type
CREATE TABLE place_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references place_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: place_annotation
CREATE TABLE place_annotation (-- replicate (verbose)
    place      INTEGER NOT NULL,-- PK, references place.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: place_attribute
CREATE TABLE place_attribute (-- replicate (verbose)
    id                                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    place                              INTEGER NOT NULL,-- references place.id
    place_attribute_type               INTEGER NOT NULL,-- references place_attribute_type.id
    place_attribute_type_allowed_value INTEGER,-- references place_attribute_type_allowed_value.id
    place_attribute_text               TEXT    CHECK ( (place_attribute_type_allowed_value IS NULL AND 
                                                        place_attribute_text IS NOT NULL) OR 
                                                       (place_attribute_type_allowed_value IS NOT NULL AND 
                                                        place_attribute_text IS NULL) ) 
);


-- Table: place_attribute_type
CREATE TABLE place_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references place_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: place_attribute_type_allowed_value
CREATE TABLE place_attribute_type_allowed_value (-- replicate (verbose)
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    place_attribute_type INTEGER NOT NULL,-- references place_attribute_type.id
    value                TEXT,
    parent               INTEGER,-- references place_attribute_type_allowed_value.id
    child_order          INTEGER NOT NULL
                                 DEFAULT 0,
    description          TEXT,
    gid                  TEXT    NOT NULL
);


-- Table: place_gid_redirect
CREATE TABLE place_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references place.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: place_tag
CREATE TABLE place_tag (-- replicate (verbose)
    place        INTEGER NOT NULL,-- PK, references place.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: place_tag_raw
CREATE TABLE place_tag_raw (
    place     INTEGER NOT NULL,-- PK, references place.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: place_type
CREATE TABLE place_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references place_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: recording
CREATE TABLE recording (-- replicate (verbose)
    id            INTEGER       PRIMARY KEY AUTOINCREMENT,
    gid           TEXT          NOT NULL,
    name          VARCHAR       NOT NULL,
    artist_credit INTEGER       NOT NULL,-- references artist_credit.id
    length        INTEGER       CHECK (length IS NULL OR 
                                       length > 0),
    comment       VARCHAR (255) NOT NULL
                                DEFAULT '',
    edits_pending INTEGER       NOT NULL
                                DEFAULT 0
                                CHECK (edits_pending >= 0),
    last_updated  TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    video         BOOLEAN       NOT NULL
                                DEFAULT FALSE
);


-- Table: recording_alias
CREATE TABLE recording_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    recording          INTEGER NOT NULL,-- references recording.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references recording_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ) 
);


-- Table: recording_alias_type
CREATE TABLE recording_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,-- PK,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references recording_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: recording_annotation
CREATE TABLE recording_annotation (-- replicate (verbose)
    recording  INTEGER NOT NULL,-- PK, references recording.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: recording_attribute
CREATE TABLE recording_attribute (-- replicate (verbose)
    id                                     INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    recording                              INTEGER NOT NULL,-- references recording.id
    recording_attribute_type               INTEGER NOT NULL,-- references recording_attribute_type.id
    recording_attribute_type_allowed_value INTEGER,-- references recording_attribute_type_allowed_value.id
    recording_attribute_text               TEXT    CHECK ( (recording_attribute_type_allowed_value IS NULL AND 
                                                            recording_attribute_text IS NOT NULL) OR 
                                                           (recording_attribute_type_allowed_value IS NOT NULL AND 
                                                            recording_attribute_text IS NULL) ) 
);


-- Table: recording_attribute_type
CREATE TABLE recording_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references recording_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: recording_attribute_type_allowed_value
CREATE TABLE recording_attribute_type_allowed_value (-- replicate (verbose)
    id                       INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    recording_attribute_type INTEGER NOT NULL,-- references recording_attribute_type.id
    value                    TEXT,
    parent                   INTEGER,-- references recording_attribute_type_allowed_value.id
    child_order              INTEGER NOT NULL
                                     DEFAULT 0,
    description              TEXT,
    gid                      TEXT    NOT NULL
);


-- Table: recording_gid_redirect
CREATE TABLE recording_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references recording.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: recording_meta
CREATE TABLE recording_meta (-- replicate
    id           INTEGER NOT NULL,-- PK, references recording.id CASCADE
    rating       INTEGER CHECK (rating >= 0 AND 
                                rating <= 100),
    rating_count INTEGER
);


-- Table: recording_rating_raw
CREATE TABLE recording_rating_raw (
    recording INTEGER NOT NULL,-- PK, references recording.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    rating    INTEGER NOT NULL
                      CHECK (rating >= 0 AND 
                             rating <= 100) 
);


-- Table: recording_tag
CREATE TABLE recording_tag (-- replicate (verbose)
    recording    INTEGER NOT NULL,-- PK, references recording.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: recording_tag_raw
CREATE TABLE recording_tag_raw (
    recording INTEGER NOT NULL,-- PK, references recording.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: release
CREATE TABLE [release] (-- replicate (verbose)
    id            INTEGER       PRIMARY KEY AUTOINCREMENT,
    gid           TEXT          NOT NULL,
    name          VARCHAR       NOT NULL,
    artist_credit INTEGER       NOT NULL,-- references artist_credit.id
    release_group INTEGER       NOT NULL,-- references release_group.id
    status        INTEGER,-- references release_status.id
    packaging     INTEGER,-- references release_packaging.id
    language      INTEGER,-- references language.id
    script        INTEGER,-- references script.id
    barcode       VARCHAR (255),
    comment       VARCHAR (255) NOT NULL
                                DEFAULT '',
    edits_pending INTEGER       NOT NULL
                                DEFAULT 0
                                CHECK (edits_pending >= 0),
    quality       INTEGER       NOT NULL
                                DEFAULT -1,
    last_updated  TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: release_alias
CREATE TABLE release_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    [release]          INTEGER NOT NULL,-- references release.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references release_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ) 
);


-- Table: release_alias_type
CREATE TABLE release_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,-- PK,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references release_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: release_annotation
CREATE TABLE release_annotation (-- replicate (verbose)
    [release]  INTEGER NOT NULL,-- PK, references release.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: release_attribute
CREATE TABLE release_attribute (-- replicate (verbose)
    id                                   INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    [release]                            INTEGER NOT NULL,-- references release.id
    release_attribute_type               INTEGER NOT NULL,-- references release_attribute_type.id
    release_attribute_type_allowed_value INTEGER,-- references release_attribute_type_allowed_value.id
    release_attribute_text               TEXT    CHECK ( (release_attribute_type_allowed_value IS NULL AND 
                                                          release_attribute_text IS NOT NULL) OR 
                                                         (release_attribute_type_allowed_value IS NOT NULL AND 
                                                          release_attribute_text IS NULL) ) 
);


-- Table: release_attribute_type
CREATE TABLE release_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references release_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: release_attribute_type_allowed_value
CREATE TABLE release_attribute_type_allowed_value (-- replicate (verbose)
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    release_attribute_type INTEGER NOT NULL,-- references release_attribute_type.id
    value                  TEXT,
    parent                 INTEGER,-- references release_attribute_type_allowed_value.id
    child_order            INTEGER NOT NULL
                                   DEFAULT 0,
    description            TEXT,
    gid                    TEXT    NOT NULL
);


-- Table: release_country
CREATE TABLE release_country (-- replicate (verbose)
    [release]  INTEGER NOT NULL,-- PK, references release.id
    country    INTEGER NOT NULL,-- PK, references country_area.area
    date_year  INTEGER,
    date_month INTEGER,
    date_day   INTEGER
);


-- Table: release_coverart
CREATE TABLE release_coverart (
    id            INTEGER       NOT NULL,-- PK, references release.id CASCADE
    last_updated  TEXT,
    cover_art_url VARCHAR (255) 
);


-- Table: release_gid_redirect
CREATE TABLE release_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references release.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: release_group
CREATE TABLE release_group (-- replicate (verbose)
    id            INTEGER       PRIMARY KEY AUTOINCREMENT,
    gid           TEXT          NOT NULL,
    name          VARCHAR       NOT NULL,
    artist_credit INTEGER       NOT NULL,-- references artist_credit.id
    type          INTEGER,-- references release_group_primary_type.id
    comment       VARCHAR (255) NOT NULL
                                DEFAULT '',
    edits_pending INTEGER       NOT NULL
                                DEFAULT 0
                                CHECK (edits_pending >= 0),
    last_updated  TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: release_group_alias
CREATE TABLE release_group_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    release_group      INTEGER NOT NULL,-- references release_group.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references release_group_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ) 
);


-- Table: release_group_alias_type
CREATE TABLE release_group_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,-- PK,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references release_group_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: release_group_annotation
CREATE TABLE release_group_annotation (-- replicate (verbose)
    release_group INTEGER NOT NULL,-- PK, references release_group.id
    annotation    INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: release_group_attribute
CREATE TABLE release_group_attribute (-- replicate (verbose)
    id                                         INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    release_group                              INTEGER NOT NULL,-- references release_group.id
    release_group_attribute_type               INTEGER NOT NULL,-- references release_group_attribute_type.id
    release_group_attribute_type_allowed_value INTEGER,-- references release_group_attribute_type_allowed_value.id
    release_group_attribute_text               TEXT    CHECK ( (release_group_attribute_type_allowed_value IS NULL AND 
                                                                release_group_attribute_text IS NOT NULL) OR 
                                                               (release_group_attribute_type_allowed_value IS NOT NULL AND 
                                                                release_group_attribute_text IS NULL) ) 
);


-- Table: release_group_attribute_type
CREATE TABLE release_group_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references release_group_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: release_group_attribute_type_allowed_value
CREATE TABLE release_group_attribute_type_allowed_value (-- replicate (verbose)
    id                           INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    release_group_attribute_type INTEGER NOT NULL,-- references release_group_attribute_type.id
    value                        TEXT,
    parent                       INTEGER,-- references release_group_attribute_type_allowed_value.id
    child_order                  INTEGER NOT NULL
                                         DEFAULT 0,
    description                  TEXT,
    gid                          TEXT    NOT NULL
);


-- Table: release_group_gid_redirect
CREATE TABLE release_group_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references release_group.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: release_group_meta
CREATE TABLE release_group_meta (-- replicate
    id                       INTEGER NOT NULL,-- PK, references release_group.id CASCADE
    release_count            INTEGER NOT NULL
                                     DEFAULT 0,
    first_release_date_year  INTEGER,
    first_release_date_month INTEGER,
    first_release_date_day   INTEGER,
    rating                   INTEGER CHECK (rating >= 0 AND 
                                            rating <= 100),
    rating_count             INTEGER
);


-- Table: release_group_primary_type
CREATE TABLE release_group_primary_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references release_group_primary_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: release_group_rating_raw
CREATE TABLE release_group_rating_raw (
    release_group INTEGER NOT NULL,-- PK, references release_group.id
    editor        INTEGER NOT NULL,-- PK, references editor.id
    rating        INTEGER NOT NULL
                          CHECK (rating >= 0 AND 
                                 rating <= 100) 
);


-- Table: release_group_secondary_type
CREATE TABLE release_group_secondary_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT
                        NOT NULL,-- PK
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references release_group_secondary_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: release_group_secondary_type_join
CREATE TABLE release_group_secondary_type_join (-- replicate (verbose)
    release_group  INTEGER NOT NULL,-- PK, references release_group.id,
    secondary_type INTEGER NOT NULL,-- PK, references release_group_secondary_type.id
    created        TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
                           NOT NULL
);


-- Table: release_group_tag
CREATE TABLE release_group_tag (-- replicate (verbose)
    release_group INTEGER NOT NULL,-- PK, references release_group.id
    tag           INTEGER NOT NULL,-- PK, references tag.id
    count         INTEGER NOT NULL,
    last_updated  TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: release_group_tag_raw
CREATE TABLE release_group_tag_raw (
    release_group INTEGER NOT NULL,-- PK, references release_group.id
    editor        INTEGER NOT NULL,-- PK, references editor.id
    tag           INTEGER NOT NULL,-- PK, references tag.id
    is_upvote     BOOLEAN NOT NULL
                          DEFAULT TRUE
);


-- Table: release_label
CREATE TABLE release_label (-- replicate (verbose)
    id             INTEGER       PRIMARY KEY AUTOINCREMENT,
    [release]      INTEGER       NOT NULL,-- references release.id
    label          INTEGER,-- references label.id
    catalog_number VARCHAR (255),
    last_updated   TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: release_meta
CREATE TABLE release_meta (-- replicate (verbose)
    id                 INTEGER       NOT NULL,-- PK, references release.id CASCADE
    date_added         TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    info_url           VARCHAR (255),
    amazon_asin        VARCHAR (10),
    amazon_store       VARCHAR (20),
    cover_art_presence TEXT          NOT NULL
                                     DEFAULT 'absent'
                                     CHECK (cover_art_presence IN ('absent', 'present', 'darkened') ) 
);


-- Table: release_packaging
CREATE TABLE release_packaging (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references release_packaging.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: release_raw
CREATE TABLE release_raw (-- replicate
    id            INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    title         VARCHAR (255) NOT NULL,
    artist        VARCHAR (255),
    added         TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    last_modified TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    lookup_count  INTEGER       DEFAULT 0,
    modify_count  INTEGER       DEFAULT 0,
    source        INTEGER       DEFAULT 0,
    barcode       VARCHAR (255),
    comment       VARCHAR (255) NOT NULL
                                DEFAULT ''
);


-- Table: release_status
CREATE TABLE release_status (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references release_status.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: release_tag
CREATE TABLE release_tag (-- replicate (verbose)
    [release]    INTEGER NOT NULL,-- PK, references release.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: release_tag_raw
CREATE TABLE release_tag_raw (
    [release] INTEGER NOT NULL,-- PK, references release.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: release_unknown_country
CREATE TABLE release_unknown_country (-- replicate (verbose)
    [release]  INTEGER NOT NULL,-- PK, references release.id
    date_year  INTEGER,
    date_month INTEGER,
    date_day   INTEGER
);


-- Table: replication_control
CREATE TABLE replication_control (-- replicate
    id                           INTEGER PRIMARY KEY AUTOINCREMENT,
    current_schema_sequence      INTEGER NOT NULL,
    current_replication_sequence INTEGER,
    last_replication_date        TEXT
);


-- Table: script
CREATE TABLE script (-- replicate
    id         INTEGER       PRIMARY KEY AUTOINCREMENT,
    iso_code   CHAR (4)      NOT NULL,-- ISO 15924
    iso_number CHAR (3)      NOT NULL,-- ISO 15924
    name       VARCHAR (100) NOT NULL,
    frequency  INTEGER       NOT NULL
                             DEFAULT 0
);


-- Table: series
CREATE TABLE series (-- replicate (verbose)
    id                 INTEGER       PRIMARY KEY AUTOINCREMENT,
    gid                TEXT          NOT NULL,
    name               VARCHAR       NOT NULL,
    comment            VARCHAR (255) NOT NULL
                                     DEFAULT '',
    type               INTEGER       NOT NULL,-- references series_type.id
    ordering_attribute INTEGER       NOT NULL,-- references link_text_attribute_type.attribute_type
    ordering_type      INTEGER       NOT NULL,-- references series_ordering_type.id
    edits_pending      INTEGER       NOT NULL
                                     DEFAULT 0
                                     CHECK (edits_pending >= 0),
    last_updated       TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: series_alias
CREATE TABLE series_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    series             INTEGER NOT NULL,-- references series.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references series_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT FALSE,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ),
    CONSTRAINT search_hints_are_empty CHECK ( (type <> 2) OR 
                                              (type = 2 AND 
                                               sort_name = name AND 
                                               begin_date_year IS NULL AND 
                                               begin_date_month IS NULL AND 
                                               begin_date_day IS NULL AND 
                                               end_date_year IS NULL AND 
                                               end_date_month IS NULL AND 
                                               end_date_day IS NULL AND 
                                               primary_for_locale IS FALSE AND 
                                               locale IS NULL) ) 
);


-- Table: series_alias_type
CREATE TABLE series_alias_type (-- replicate (verbose)
    id          INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references series_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: series_annotation
CREATE TABLE series_annotation (-- replicate (verbose)
    series     INTEGER NOT NULL,-- PK, references series.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: series_attribute
CREATE TABLE series_attribute (-- replicate (verbose)
    id                                  INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    series                              INTEGER NOT NULL,-- references series.id
    series_attribute_type               INTEGER NOT NULL,-- references series_attribute_type.id
    series_attribute_type_allowed_value INTEGER,-- references series_attribute_type_allowed_value.id
    series_attribute_text               TEXT    CHECK ( (series_attribute_type_allowed_value IS NULL AND 
                                                         series_attribute_text IS NOT NULL) OR 
                                                        (series_attribute_type_allowed_value IS NOT NULL AND 
                                                         series_attribute_text IS NULL) ) 
);


-- Table: series_attribute_type
CREATE TABLE series_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references series_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: series_attribute_type_allowed_value
CREATE TABLE series_attribute_type_allowed_value (-- replicate (verbose)
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    series_attribute_type INTEGER NOT NULL,-- references series_attribute_type.id
    value                 TEXT,
    parent                INTEGER,-- references series_attribute_type_allowed_value.id
    child_order           INTEGER NOT NULL
                                  DEFAULT 0,
    description           TEXT,
    gid                   TEXT    NOT NULL
);


-- Table: series_gid_redirect
CREATE TABLE series_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references series.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: series_ordering_type
CREATE TABLE series_ordering_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references series_ordering_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: series_tag
CREATE TABLE series_tag (-- replicate (verbose)
    series       INTEGER NOT NULL,-- PK, references series.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: series_tag_raw
CREATE TABLE series_tag_raw (
    series    INTEGER NOT NULL,-- PK, references series.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: series_type
CREATE TABLE series_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    entity_type VARCHAR (50)  NOT NULL,
    parent      INTEGER,-- references series_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: tag
CREATE TABLE tag (-- replicate (verbose)
    id        INTEGER       PRIMARY KEY AUTOINCREMENT,
    name      VARCHAR (255) NOT NULL,
    ref_count INTEGER       NOT NULL
                            DEFAULT 0
);


-- Table: tag_relation
CREATE TABLE tag_relation (
    tag1         INTEGER NOT NULL,-- PK, references tag.id
    tag2         INTEGER NOT NULL,-- PK, references tag.id
    weight       INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    CHECK (tag1 < tag2) 
);


-- Table: track
CREATE TABLE track (-- replicate (verbose)
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    gid           TEXT    NOT NULL,
    recording     INTEGER NOT NULL,-- references recording.id
    medium        INTEGER NOT NULL,-- references medium.id
    position      INTEGER NOT NULL,
    number        TEXT    NOT NULL,
    name          VARCHAR NOT NULL,
    artist_credit INTEGER NOT NULL,-- references artist_credit.id
    length        INTEGER CHECK (length IS NULL OR 
                                 length > 0),
    edits_pending INTEGER NOT NULL
                          DEFAULT 0
                          CHECK (edits_pending >= 0),
    last_updated  TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    is_data_track BOOLEAN NOT NULL
                          DEFAULT FALSE
);


-- Table: track_gid_redirect
CREATE TABLE track_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references track.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: track_raw
CREATE TABLE track_raw (-- replicate
    id        INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    [release] INTEGER       NOT NULL,-- references release_raw.id
    title     VARCHAR (255) NOT NULL,
    artist    VARCHAR (255),-- For VA albums, otherwise empty
    sequence  INTEGER       NOT NULL
);


-- Table: url
CREATE TABLE url (-- replicate
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    gid           TEXT    NOT NULL,
    url           TEXT    NOT NULL,
    edits_pending INTEGER NOT NULL
                          DEFAULT 0
                          CHECK (edits_pending >= 0),
    last_updated  TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: url_gid_redirect
CREATE TABLE url_gid_redirect (-- replicate
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references url.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: vote
CREATE TABLE vote (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    editor     INTEGER NOT NULL,-- references editor.id
    edit       INTEGER NOT NULL,-- references edit.id
    vote       INTEGER NOT NULL,
    vote_time  TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    superseded BOOLEAN NOT NULL
                       DEFAULT FALSE
);


-- Table: work
CREATE TABLE work (-- replicate (verbose)
    id            INTEGER       PRIMARY KEY AUTOINCREMENT,
    gid           TEXT          NOT NULL,
    name          VARCHAR       NOT NULL,
    type          INTEGER,-- references work_type.id
    comment       VARCHAR (255) NOT NULL
                                DEFAULT '',
    edits_pending INTEGER       NOT NULL
                                DEFAULT 0
                                CHECK (edits_pending >= 0),
    last_updated  TEXT          DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: work_alias
CREATE TABLE work_alias (-- replicate (verbose)
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    work               INTEGER NOT NULL,-- references work.id
    name               VARCHAR NOT NULL,
    locale             TEXT,
    edits_pending      INTEGER NOT NULL
                               DEFAULT 0
                               CHECK (edits_pending >= 0),
    last_updated       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ),
    type               INTEGER,-- references work_alias_type.id
    sort_name          VARCHAR NOT NULL,
    begin_date_year    INTEGER,
    begin_date_month   INTEGER,
    begin_date_day     INTEGER,
    end_date_year      INTEGER,
    end_date_month     INTEGER,
    end_date_day       INTEGER,
    primary_for_locale BOOLEAN NOT NULL
                               DEFAULT false,
    ended              BOOLEAN NOT NULL
                               DEFAULT FALSE
                               CHECK ( (/* If any end date fields are not null, then ended must be true */ (end_date_year IS NOT NULL OR 
                                          end_date_month IS NOT NULL OR 
                                          end_date_day IS NOT NULL) AND 
                                         ended = TRUE) OR 
                                       (/* Otherwise, all end date fields must be null */ (end_date_year IS NULL AND 
                                          end_date_month IS NULL AND 
                                          end_date_day IS NULL) ) ),
    CONSTRAINT primary_check CHECK ( (locale IS NULL AND 
                                      primary_for_locale IS FALSE) OR 
                                     (locale IS NOT NULL) ),
    CONSTRAINT search_hints_are_empty CHECK ( (type <> 2) OR 
                                              (type = 2 AND 
                                               sort_name = name AND 
                                               begin_date_year IS NULL AND 
                                               begin_date_month IS NULL AND 
                                               begin_date_day IS NULL AND 
                                               end_date_year IS NULL AND 
                                               end_date_month IS NULL AND 
                                               end_date_day IS NULL AND 
                                               primary_for_locale IS FALSE AND 
                                               locale IS NULL) ) 
);


-- Table: work_alias_type
CREATE TABLE work_alias_type (-- replicate
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    parent      INTEGER,-- references work_alias_type.id
    child_order INTEGER NOT NULL
                        DEFAULT 0,
    description TEXT,
    gid         TEXT    NOT NULL
);


-- Table: work_annotation
CREATE TABLE work_annotation (-- replicate (verbose)
    work       INTEGER NOT NULL,-- PK, references work.id
    annotation INTEGER NOT NULL-- PK, references annotation.id
);


-- Table: work_attribute
CREATE TABLE work_attribute (-- replicate (verbose)
    id                                INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    work                              INTEGER NOT NULL,-- references work.id
    work_attribute_type               INTEGER NOT NULL,-- references work_attribute_type.id
    work_attribute_type_allowed_value INTEGER,-- references work_attribute_type_allowed_value.id
    work_attribute_text               TEXT    CHECK ( (work_attribute_type_allowed_value IS NULL AND 
                                                       work_attribute_text IS NOT NULL) OR 
                                                      (work_attribute_type_allowed_value IS NOT NULL AND 
                                                       work_attribute_text IS NULL) ) 
);


-- Table: work_attribute_type
CREATE TABLE work_attribute_type (-- replicate (verbose)
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,-- PK
    name        VARCHAR (255) NOT NULL,
    comment     VARCHAR (255) NOT NULL
                              DEFAULT '',
    free_text   BOOLEAN       NOT NULL,
    parent      INTEGER,-- references work_attribute_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


-- Table: work_attribute_type_allowed_value
CREATE TABLE work_attribute_type_allowed_value (-- replicate (verbose)
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,-- PK
    work_attribute_type INTEGER NOT NULL,-- references work_attribute_type.id
    value               TEXT,
    parent              INTEGER,-- references work_attribute_type_allowed_value.id
    child_order         INTEGER NOT NULL
                                DEFAULT 0,
    description         TEXT,
    gid                 TEXT    NOT NULL
);


-- Table: work_gid_redirect
CREATE TABLE work_gid_redirect (-- replicate (verbose)
    gid     TEXT    NOT NULL,-- PK
    new_id  INTEGER NOT NULL,-- references work.id
    created TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: work_language
CREATE TABLE work_language (-- replicate (verbose)
    work          INTEGER NOT NULL,-- PK, references work.id
    language      INTEGER NOT NULL,-- PK, references language.id
    edits_pending INTEGER NOT NULL
                          DEFAULT 0
                          CHECK (edits_pending >= 0),
    created       TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: work_meta
CREATE TABLE work_meta (-- replicate
    id           INTEGER NOT NULL,-- PK, references work.id CASCADE
    rating       INTEGER CHECK (rating >= 0 AND 
                                rating <= 100),
    rating_count INTEGER
);


-- Table: work_rating_raw
CREATE TABLE work_rating_raw (
    work   INTEGER NOT NULL,-- PK, references work.id
    editor INTEGER NOT NULL,-- PK, references editor.id
    rating INTEGER NOT NULL
                   CHECK (rating >= 0 AND 
                          rating <= 100) 
);


-- Table: work_tag
CREATE TABLE work_tag (-- replicate (verbose)
    work         INTEGER NOT NULL,-- PK, references work.id
    tag          INTEGER NOT NULL,-- PK, references tag.id
    count        INTEGER NOT NULL,
    last_updated TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%f+00', 'now') ) 
);


-- Table: work_tag_raw
CREATE TABLE work_tag_raw (
    work      INTEGER NOT NULL,-- PK, references work.id
    editor    INTEGER NOT NULL,-- PK, references editor.id
    tag       INTEGER NOT NULL,-- PK, references tag.id
    is_upvote BOOLEAN NOT NULL
                      DEFAULT TRUE
);


-- Table: work_type
CREATE TABLE work_type (-- replicate
    id          INTEGER       PRIMARY KEY AUTOINCREMENT,
    name        VARCHAR (255) NOT NULL,
    parent      INTEGER,-- references work_type.id
    child_order INTEGER       NOT NULL
                              DEFAULT 0,
    description TEXT,
    gid         TEXT          NOT NULL
);


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
