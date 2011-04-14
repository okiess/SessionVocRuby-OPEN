CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8;

CREATE TABLE `passwords` (
  `id` int(11) NOT NULL,
  `password` varchar(255),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8;

CREATE TABLE `user_data` (
  `id` int(11) NOT NULL,
  `name` varchar(255),
  `surname` varchar(255),
  `mobile` varchar(255),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8;

CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL,
  `font_size` int(11),
  `sort_order` varchar(255),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8;

INSERT INTO users (username) VALUES("testuser");
INSERT INTO passwords (id, password) VALUES(1, "2cee3c63210829f3e9d3768dbe4c4d12ad784b31");
INSERT INTO user_data (id, name, surname, mobile) VALUES(1, "Tes", "Testmann", "0111-11111111");
INSERT INTO user_data (id, font_size, sort_order) VALUES(1, 14, "DESC");
INSERT INTO user_preferences (id, font_size, sort_order) VALUES(1, 14, "DESC");
