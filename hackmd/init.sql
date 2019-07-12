CREATE USER 'hackmd' IDENTIFIED BY 'hackmd';
CREATE DATABASE hackmd;
GRANT ALL ON hackmd.* to 'hackmd'@'%';
