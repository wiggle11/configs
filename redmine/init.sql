CREATE USER 'redmine' IDENTIFIED BY 'redmine';
CREATE DATABASE redmine;
GRANT ALL ON redmine.* to 'redmine'@'%';
