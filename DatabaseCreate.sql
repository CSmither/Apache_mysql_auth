CREATE DATABASE `webAuth` /*!40100 DEFAULT CHARACTER SET latin1 */;

CREATE USER 'apache2'@'localhost' IDENTIFIED BY 'passwd';   /* Swap 'passwd' for an appropriate password for your apache process */
GRANT ALL ON webAuth.* TO 'apache2'@'localhost';

CREATE TABLE `User` (
  `userName` varchar(16) NOT NULL,
  `password` varchar(64) NOT NULL,
  `email` varchar(128) NOT NULL,
  PRIMARY KEY (`userName`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `Group` (
  `name` varchar(16) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `Location` (
  `Path` varchar(255) NOT NULL,
  PRIMARY KEY (`Path`),
  UNIQUE KEY `Path_UNIQUE` (`Path`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `UserGroup` (
  `user` varchar(16) NOT NULL,
  `group` varchar(16) NOT NULL,
  PRIMARY KEY (`user`,`group`),
  KEY `UserGroup -> Group_idx` (`group`),
  CONSTRAINT `UserGroup -> User` FOREIGN KEY (`user`) REFERENCES `User` (`userName`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `UserGroup -> Group` FOREIGN KEY (`group`) REFERENCES `Group` (`name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `UserAccess` (
  `user` varchar(16) NOT NULL DEFAULT '',
  `path` varchar(255) NOT NULL,
  `allowed` tinyint(1) NOT NULL DEFAULT '0',
  `priority` int(4) DEFAULT NULL,
  PRIMARY KEY (`user`,`path`),
  KEY `UserAccess -> Location_idx` (`path`),
  KEY `UserAccess.priority_idx` (`priority`) USING BTREE,
  CONSTRAINT `UserAccess -> Location` FOREIGN KEY (`path`) REFERENCES `Location` (`Path`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `UserAccess -> User` FOREIGN KEY (`user`) REFERENCES `User` (`userName`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `GroupAccess` (
  `group` varchar(16) NOT NULL DEFAULT '',
  `path` varchar(255) NOT NULL,
  `allowed` tinyint(1) NOT NULL DEFAULT '0',
  `priority` int(4) DEFAULT NULL,
  PRIMARY KEY (`path`,`group`),
  KEY `GroupAccess -> Group_idx` (`group`),
  KEY `GroupAccess.priority_idx` (`priority`) USING BTREE,
  CONSTRAINT `GroupAccess -> Group` FOREIGN KEY (`group`) REFERENCES `Group` (`name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `GroupAccess -> Location` FOREIGN KEY (`path`) REFERENCES `Location` (`Path`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TRIGGER `webAuth`.`GroupAccess_BEFORE_INSERT` BEFORE INSERT ON `GroupAccess` FOR EACH ROW
BEGIN
	SET NEW.priority=LENGTH(NEW.path);
END

CREATE TRIGGER `webAuth`.`GroupAccess_BEFORE_UPDATE` BEFORE UPDATE ON `GroupAccess` FOR EACH ROW
BEGIN
	SET NEW.priority=LENGTH(NEW.path);
END

CREATE TRIGGER `webAuth`.`UserAccess_BEFORE_INSERT` BEFORE INSERT ON `UserAccess` FOR EACH ROW
BEGIN
	SET NEW.priority=LENGTH(NEW.path)+1000;
END

CREATE TRIGGER `webAuth`.`UserAccess_BEFORE_UPDATE` BEFORE UPDATE ON `UserAccess` FOR EACH ROW
BEGIN
	SET NEW.priority=LENGTH(NEW.path)+1000;
END
