
.open database.sqlite;
drop table if exists tb_user;
CREATE TABLE "tb_user" (
    "userId" INTEGER PRIMARY KEY autoincrement,
    "username" TEXT,
    "email" TEXT,
    "icon" text,
    "affUserId" INTEGER,
    "status" INTEGER,
    "vip_status" INTEGER,
    "vip_expired" INTEGER,
    "os" TEXT,
    "isInChat" boolean default 0,
    "register_time" INTEGER default 0
);

drop table if exists tb_message;
CREATE TABLE "tb_message" (
    "msgId" INTEGER primary key autoincrement,
    "fromEntity" INTEGER,
    "fromId" INTEGER,
    "toId" INTEGER,
    "toEntity" INTEGER,
    "messageType" INTEGER,
    "content" TEXT,
    "affUserId" integer,
    "sendStatus" integer,
    "timestamp" INTEGER NOT null default 0
);
