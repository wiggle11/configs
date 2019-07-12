CREATE USER 'mattermost' IDENTIFIED BY 'mattermost';
CREATE DATABASE mattermost;
GRANT ALL ON mattermost.* to 'mattermost'@'%';
