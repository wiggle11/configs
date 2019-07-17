CREATE USER 'cloud' IDENTIFIED BY 'cloud';
CREATE DATABASE cloud;
GRANT ALL ON cloud.* to 'cloud'@'%';
