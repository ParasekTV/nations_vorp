-- Infinity Nations SQL Installation
-- Für RedM VORP Framework mit oxmysql

-- Erstelle Nations Tabelle
CREATE TABLE IF NOT EXISTS `infinity_nations` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `governor_id` VARCHAR(50) NULL DEFAULT NULL,
    `bank` DOUBLE NOT NULL DEFAULT 0,
    `tax_rate` INT(11) NOT NULL DEFAULT 5,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Erstelle Towns Tabelle
CREATE TABLE IF NOT EXISTS `infinity_towns` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `nation_id` INT(11) NOT NULL,
    `mayor_id` VARCHAR(50) NULL DEFAULT NULL,
    `bank` DOUBLE NOT NULL DEFAULT 0,
    `bank_tax` INT(11) NOT NULL DEFAULT 5,
    `city_tax` DOUBLE NOT NULL DEFAULT 10,
    `entry_fee` DOUBLE NOT NULL DEFAULT 50,
    `max_population` INT(11) NOT NULL DEFAULT 100,
    `reward_money` DOUBLE NOT NULL DEFAULT 25,
    `reward_xp` INT(11) NOT NULL DEFAULT 10,
    `motd` TEXT NULL DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `name` (`name`),
    INDEX `nation_id` (`nation_id`),
    CONSTRAINT `fk_towns_nation` FOREIGN KEY (`nation_id`) REFERENCES `infinity_nations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Erstelle Citizens Tabelle
CREATE TABLE IF NOT EXISTS `infinity_citizens` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `character_id` VARCHAR(50) NOT NULL,
    `town_id` INT(11) NOT NULL,
    `has_passport` TINYINT(1) NOT NULL DEFAULT 0,
    `join_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_reward` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `character_id` (`character_id`),
    INDEX `town_id` (`town_id`),
    CONSTRAINT `fk_citizens_town` FOREIGN KEY (`town_id`) REFERENCES `infinity_towns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Erstelle Indexes für Performance
CREATE INDEX idx_nation_bank ON infinity_nations(bank);
CREATE INDEX idx_town_bank ON infinity_towns(bank);
CREATE INDEX idx_citizen_last_reward ON infinity_citizens(last_reward);

-- Optional: Füge Beispieldaten hinzu (auskommentiert)
-- INSERT INTO infinity_nations (name, bank) VALUES 
-- ('New Hanover', 10000),
-- ('West Elizabeth', 15000),
-- ('Lemoyne', 12000);

-- INSERT INTO infinity_towns (name, nation_id, bank, entry_fee) VALUES
-- ('Valentine', 1, 5000, 50),
-- ('Blackwater', 2, 8000, 75),
-- ('Saint Denis', 3, 10000, 100);

SELECT 'Infinity Nations Datenbank erfolgreich installiert!' as message;
