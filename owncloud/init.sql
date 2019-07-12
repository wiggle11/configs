CREATE USER 'owncloud' IDENTIFIED BY 'owncloud';
CREATE DATABASE owncloud;
GRANT ALL ON owncloud.* to 'owncloud'@'%';
