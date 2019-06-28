CREATE USER 'xwiki' IDENTIFIED BY 'xwiki';
CREATE DATABASE xwiki;
GRANT ALL ON xwiki.* to 'xwiki'@'%';
