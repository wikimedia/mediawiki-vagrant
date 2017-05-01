-- Striker initial schema - 2016-08-16 r6c16187/*{{{*//*}}}*/
-- Generated with mysqldump and hand edited by bd808
--
-- NOTE: requires a server with innodb_large_prefix enabled to support UNIQUE
-- indexes on varchar(255) columns with a utf8mb4. If innodb_large_prefix is
-- not enabled you will receive errors mentioning "Specified key was too long;
-- max key length is 767 bytes"

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_157f301e7b80cb55_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type`
VALUES
(1,'admin','logentry'),
(3,'auth','group'),
(2,'auth','permission'),
(4,'contenttypes','contenttype'),
(10,'goals','milestone'),
(6,'labsauth','labsuser'),
(5,'sessions','session'),
(9,'tools','diffusionrepo'),
(7,'tools','maintainer'),
(8,'tools','tool');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `content_type_id` (`content_type_id`,`codename`),
  CONSTRAINT `auth__content_type_id_7c434beae60a3577_fk_django_content_type_id` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission`
VALUES
(1,'Can add log entry',1,'add_logentry'),
(2,'Can change log entry',1,'change_logentry'),
(3,'Can delete log entry',1,'delete_logentry'),
(4,'Can add permission',2,'add_permission'),
(5,'Can change permission',2,'change_permission'),
(6,'Can delete permission',2,'delete_permission'),
(7,'Can add group',3,'add_group'),
(8,'Can change group',3,'change_group'),
(9,'Can delete group',3,'delete_group'),
(10,'Can add content type',4,'add_contenttype'),
(11,'Can change content type',4,'change_contenttype'),
(12,'Can delete content type',4,'delete_contenttype'),
(13,'Can add session',5,'add_session'),
(14,'Can change session',5,'change_session'),
(15,'Can delete session',5,'delete_session'),
(16,'Can add user',6,'add_labsuser'),
(17,'Can change user',6,'change_labsuser'),
(18,'Can delete user',6,'delete_labsuser'),
(19,'Can add maintainer',7,'add_maintainer'),
(20,'Can change maintainer',7,'change_maintainer'),
(21,'Can delete maintainer',7,'delete_maintainer'),
(22,'Can add tool',8,'add_tool'),
(23,'Can change tool',8,'change_tool'),
(24,'Can delete tool',8,'delete_tool'),
(25,'Can add diffusion repo',9,'add_diffusionrepo'),
(26,'Can change diffusion repo',9,'change_diffusionrepo'),
(27,'Can delete diffusion repo',9,'delete_diffusionrepo'),
(28,'Can add milestone',10,'add_milestone'),
(29,'Can change milestone',10,'change_milestone'),
(30,'Can delete milestone',10,'delete_milestone');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_id` (`group_id`,`permission_id`),
  KEY `auth_group__permission_id_14f7024687451495_fk_auth_permission_id` (`permission_id`),
  CONSTRAINT `auth_group_permission_group_id_39a52294ac930446_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_group__permission_id_14f7024687451495_fk_auth_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

CREATE TABLE `django_migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations`
VALUES
(1,'contenttypes','0001_initial',now()),
(2,'contenttypes','0002_remove_content_type_name',now()),
(3,'auth','0001_initial',now()),
(4,'auth','0002_alter_permission_name_max_length',now()),
(5,'auth','0003_alter_user_email_max_length',now()),
(6,'auth','0004_alter_user_username_opts',now()),
(7,'auth','0005_alter_user_last_login_null',now()),
(8,'auth','0006_require_contenttypes_0002',now()),
(9,'labsauth','0001_initial',now()),
(10,'labsauth','0002_auto_20160508_0419',now()),
(11,'admin','0001_initial',now()),
(12,'goals','0001_initial',now()),
(13,'goals','0002_auto_20160531_1721',now()),
(14,'sessions','0001_initial',now()),
(15,'tools','0001_initial',now()),
(16,'tools','0002_auto_20160531_1653',now()),
(17,'goals','0001_squashed',now()),
(18,'tools','0001_squashed',now()),
(19,'labsauth','0001_squashed',now()),
(20,'tools','0002_auto_20160719_0436',now());
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_de54fa62` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

CREATE TABLE `labsauth_labsuser` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `ldapname` varchar(255) NOT NULL,
  `ldapemail` varchar(254) NOT NULL,
  `shellname` varchar(32) DEFAULT NULL,
  `sulname` varchar(255) DEFAULT NULL,
  `sulemail` varchar(254) DEFAULT NULL,
  `realname` varchar(255) DEFAULT NULL,
  `oauthtoken` varchar(127) DEFAULT NULL,
  `oauthsecret` varchar(127) DEFAULT NULL,
  `authhash` varchar(128) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `phabimage` varchar(255) DEFAULT NULL,
  `phabname` varchar(255) DEFAULT NULL,
  `phabrealname` varchar(255) DEFAULT NULL,
  `phaburl` varchar(255) DEFAULT NULL,
  `phid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ldapname` (`ldapname`),
  UNIQUE KEY `shellname` (`shellname`),
  UNIQUE KEY `sulname` (`sulname`),
  UNIQUE KEY `phabname` (`phabname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;


CREATE TABLE `labsauth_labsuser_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `labsuser_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labsuser_id` (`labsuser_id`,`group_id`),
  KEY `labsauth_labsuser_gro_group_id_7239e9cc7c15b747_fk_auth_group_id` (`group_id`),
  CONSTRAINT `labsauth_labsuser_gro_group_id_7239e9cc7c15b747_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `labsauth_la_labsuser_id_3ba57f293f4ffd77_fk_labsauth_labsuser_id` FOREIGN KEY (`labsuser_id`) REFERENCES `labsauth_labsuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;


CREATE TABLE `labsauth_labsuser_user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `labsuser_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labsuser_id` (`labsuser_id`,`permission_id`),
  KEY `labsauth_lab_permission_id_c551f1908726a5e_fk_auth_permission_id` (`permission_id`),
  CONSTRAINT `labsauth_lab_permission_id_c551f1908726a5e_fk_auth_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `labsauth_la_labsuser_id_63762de9af9f4b05_fk_labsauth_labsuser_id` FOREIGN KEY (`labsuser_id`) REFERENCES `labsauth_labsuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

CREATE TABLE `goals_milestone` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `goal` smallint(6) NOT NULL,
  `completed_date` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `goals_milestone_user_id_626f33f2557cff15_uniq` (`user_id`,`goal`),
  CONSTRAINT `goals_milestone_user_id_1a56ad32987c6905_fk_labsauth_labsuser_id` FOREIGN KEY (`user_id`) REFERENCES `labsauth_labsuser` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

CREATE TABLE `tools_diffusionrepo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tool` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phid` varchar(64) NOT NULL,
  `created_by_id` int(11) NOT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tools_dif_created_by_id_2a080308b758ce67_fk_labsauth_labsuser_id` (`created_by_id`),
  CONSTRAINT `tools_dif_created_by_id_2a080308b758ce67_fk_labsauth_labsuser_id` FOREIGN KEY (`created_by_id`) REFERENCES `labsauth_labsuser` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;


CREATE TABLE `tools_maintainer` (
  `dn` varchar(200) NOT NULL,
  `uid` varchar(200) NOT NULL,
  `cn` varchar(200) NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;


CREATE TABLE `tools_tool` (
  `dn` varchar(200) NOT NULL,
  `cn` varchar(200) NOT NULL,
  `gidNumber` int(11) NOT NULL,
  PRIMARY KEY (`cn`),
  UNIQUE KEY `gidNumber` (`gidNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_content_type_id_b067cba4e41ad39_fk_django_content_type_id` (`content_type_id`),
  KEY `django_admin_lo_user_id_4d9e0025a3fcd868_fk_labsauth_labsuser_id` (`user_id`),
  CONSTRAINT `django_admin_lo_user_id_4d9e0025a3fcd868_fk_labsauth_labsuser_id` FOREIGN KEY (`user_id`) REFERENCES `labsauth_labsuser` (`id`),
  CONSTRAINT `django_content_type_id_b067cba4e41ad39_fk_django_content_type_id` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

