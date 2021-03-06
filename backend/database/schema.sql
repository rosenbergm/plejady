ALTER ROLE plejady SUPERUSER;

CREATE EXTENSION if not exists "uuid-ossp";

CREATE TABLE dream_session (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  expires_at REAL NOT NULL,
  payload TEXT NOT NULL
);

CREATE TABLE rooms (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  capacity INTEGER NOT NULL
);
CREATE UNIQUE INDEX rooms_uniques ON rooms(name);

CREATE TABLE timeblocks (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  block_start TIME NOT NULL,
  block_end TIME NOT NULL
);

CREATE TABLE talks (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  annotation TEXT NOT NULL,
  timeblock uuid NOT NULL,
  room uuid NOT NULL,
  CONSTRAINT fk_talks_timeblock
    FOREIGN KEY (timeblock)
    REFERENCES timeblocks(id),
  CONSTRAINT fk_talks_room
    FOREIGN KEY (room)
    REFERENCES rooms(id)
);

CREATE TABLE students (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  gid TEXT NOT NULL,
  email TEXT NOT NULL,
  is_admin BOOLEAN NOT NULL DEFAULT false
);
CREATE UNIQUE INDEX students_uniques ON students(gid, email);

INSERT INTO students (gid, email, is_admin) VALUES ('', 'rosenberg.martin@student.alej.cz', TRUE);

CREATE TABLE students_talks (
  student uuid NOT NULL,
  talk uuid NOT NULL,
  CONSTRAINT fk_students_talks_student
    FOREIGN KEY (student)
    REFERENCES students(id),
  CONSTRAINT fk_students_talks_talk
    FOREIGN KEY (talk)
    REFERENCES talks(id)
);

