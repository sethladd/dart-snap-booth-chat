DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS friend;
DROP TABLE IF EXISTS picture;

CREATE TABLE IF NOT EXISTS user (
  id SERIAL PRIMARY KEY,
  gplus_id VARCHAR(255) UNIQUE,
  name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS friend (
  id SERIAL,
  user1_id integer,
  user2_id integer
);

CREATE INDEX ON friend (user1_id);
CREATE INDEX ON friend (user2_id);

CREATE TABLE IF NOT EXISTS picture (
  id SERIAL PRIMARY KEY,
  sender_id integer,
  receiver_id integer,
  picture_url VARCHAR(255),
  created_at TIMESTAMP,
  expires_at TIMESTAMP
);

CREATE INDEX ON picture (sender_id);
CREATE INDEX ON picture (receiver_id);

INSERT INTO user (gplus_id, name) VALUES ('100399120809275930649', 'Kathy Walrath');