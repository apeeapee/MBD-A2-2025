CREATE DATABASE BANKDB;

USE BANKDB;

CREATE TABLE customers (
    customer_id CHAR(36) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(50),
    phone_number VARCHAR(20),
    address varchar(255),
    created_at DATETIME DEFAULT GETDATE()
);

ALTER TABLE customers
ADD CONSTRAINT DF_customers_customer_id DEFAULT NEWID() FOR customer_id;

CREATE TABLE accounts (
    account_id CHAR(36) PRIMARY KEY DEFAULT NEWID(),
    customer_id CHAR(36) NOT NULL,
    account_number CHAR(10),
    account_type VARCHAR(50) NOT NULL, -- enum simulated
    balance DECIMAL(18,2),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_accounts_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT CK_accounts_account_type CHECK (account_type IN ('savings', 'current', 'credit'))
);

CREATE TABLE transaction_types (
    transaction_type_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE transactions (
    transaction_id CHAR(36) PRIMARY KEY DEFAULT NEWID(),
    account_id CHAR(36) NOT NULL,
    transaction_type_id INT NOT NULL,
    amount DECIMAL(18,2),
    transaction_date DATETIME DEFAULT GETDATE(),
    description varchar(50),
    reference_account CHAR(36), 
    CONSTRAINT FK_transactions_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT FK_transactions_transaction_types FOREIGN KEY (transaction_type_id) REFERENCES transaction_types(transaction_type_id)
);

CREATE TABLE cards (
    card_id CHAR(36) PRIMARY KEY DEFAULT NEWID(),
    account_id CHAR(36) NOT NULL,
    card_number VARCHAR(30),
    card_type VARCHAR(25) NOT NULL, -- enum simulated
    expiration_date DATE,
    CONSTRAINT FK_cards_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT CK_cards_card_type CHECK (card_type IN ('debit', 'credit'))
);

CREATE TABLE loans (
  loan_id CHAR(36) PRIMARY KEY DEFAULT NEWID(),
  customer_id CHAR(36) NOT NULL,
  loan_amount DECIMAL(18,2),
  interest_rate DECIMAL(5,2),
  loan_terms_months INT,
  start_date DATE,
  end_date DATE,
  status VARCHAR(30) NOT NULL, -- Simulate enum
  CONSTRAINT FK_loans_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT CK_loans_status CHECK (status IN ('active', 'closed', 'defaulted'))
);

INSERT INTO "customers" ("customer_id", "first_name", "last_name", "email", "phone_number", "address", "created_at") VALUES
('9d78736f-df51-4622-9cb1-c4db88dca2d0', 'Swen', 'Crowley', 'swen.crowley@gmail.com', '(203) 751-2379', '9102 McKay Avenue, Waterbury, Connecticut, United States, 06721', '2024-04-25 15:51:30'),
('357e3969-87b3-48e9-bd0b-4a658de0dd38', 'Meggi', 'MacDermott', 'meggi.macdermott@yahoo.com', '(702) 378-5984', '8016 Mayberry Court, North Las Vegas, Nevada, United States, 89087', '2024-04-25 15:52:54'),
('57829c08-247e-4dec-b528-cd1099fc1e81', 'Meade', 'McSkin', 'meade.mcskin@hotmail.com', '(858) 654-8175', '11810 Rose Croft Terrace, San Diego, California, United States, 92121', '2024-04-25 16:00:25'),
('5d8912f2-8074-4f41-b002-e0c789e7f718', 'Hillie', 'Wyrall', 'hillie.wyrall@gmail.com', '(702) 506-6469', '7449 Montbrook Place, Las Vegas, Nevada, United States, 89140', '2024-04-25 16:04:50'),
('870ae237-d669-42dd-b283-99c1219bf349', 'Normie', 'McNabb', 'normie.mcnabb@hotmail.com', '(225) 812-2851', '3569 Norwood Street, Baton Rouge, Louisiana, United States, 70810', '2024-04-25 16:11:26'),
('fd29af21-54cd-42a1-a4d7-40890f6dd658', 'Yardley', 'Gillingwater', 'yardley.gillingwater@hotmail.com', '(901) 844-1964', '11286 Makoski Place, Memphis, Tennessee, United States, 38114', '2024-04-25 16:15:43'),
('f832a165-6ce7-4d54-9cf4-2b58ad4b4cf5', 'Hilliard', 'Milmoe', 'hilliard.milmoe@gmail.com', '(339) 079-5111', '8969 Tranquility Lane, Boston, Massachusetts, United States, 02163', '2024-04-25 16:23:03'),
('6b612ed4-f731-4963-85f3-780a438e0fad', 'Kendricks', 'Casper', 'kendricks.casper@hotmail.com', '(559) 010-2031', '11145 Becky Court, Fresno, California, United States, 93726', '2024-04-25 16:31:00'),
('6daa0a7c-3ca5-4ace-9d6c-b119d9067a6a', 'Rachael', 'Giacopetti', 'rachael.giacopetti@gmail.com', '(859) 459-1708', '3788 Shelburne Lane, Lexington, Kentucky, United States, 40546', '2024-04-25 16:32:27'),
('6f6a46c1-26ae-47c8-82aa-34027c84af78', 'Feodora', 'Muress', 'feodora.muress@hotmail.com', '(405) 031-2886', '8978 Seymour Avenue, Oklahoma City, Oklahoma, United States, 73129', '2024-04-25 16:40:02'),
('7ab376ee-2fca-4f08-98aa-9b93cc0fc972', 'Shalne', 'Lowers', 'shalne.lowers@gmail.com', '(614) 967-0772', '5682 Hopewell Street, Columbus, Ohio, United States, 43240', '2024-04-25 16:49:32'),
('20b542e7-3b96-4059-b30a-6d09832e17de', 'Sandro', 'Alten', 'sandro.alten@yahoo.com.br', '(719) 485-8050', '11759 Panigoni Avenue, Colorado Springs, Colorado, United States, 80920', '2024-04-25 16:58:10'),
('79dcf8ce-329d-48a8-ac2c-9fa869b4ac42', 'Daisie', 'Gabala', 'daisie.gabala@gmail.com', '(919) 158-9579', '8101 Maynard Path, Raleigh, North Carolina, United States, 27610', '2024-04-25 17:00:11'),
('3f5ab011-f526-4bbd-8ab8-8a67ad95c5bf', 'Olivia', 'Speedin', 'olivia.speedin@gmail.com', '(202) 594-9821', '12264 Quincy Court, Washington, District of Columbia, United States, 20566', '2024-04-25 17:06:08'),
('61ac2df4-4e87-4f00-af98-a9c55edbdd80', 'Chanda', 'Brunnstein', 'chanda.brunnstein@hotmail.com', '(831) 141-9049', '9822 Leisure Street, Santa Cruz, California, United States, 95064', '2024-04-25 17:14:48'),
('dc0f5f48-84ef-4f9b-bd05-ef9217f050fe', 'Sherill', 'Downham', 'sherill.downham@gmail.com', '(361) 135-4497', '9484 Callaway Drive, Corpus Christi, Texas, United States, 78470', '2024-04-25 17:19:01'),
('3a57a285-56e7-4900-bc63-d044f2247ff1', 'Boy', 'Rowesby', 'boy.rowesby@rediffmail.com', '(540) 195-3085', '3062 Butler Court, Roanoke, Virginia, United States, 24024', '2024-04-25 17:20:28'),
('462d21d0-7672-428a-abf7-04c18a1efde8', 'Zebedee', 'Goley', 'zebedee.goley@gmail.com', '(757) 816-0102', '9705 Madero Drive, Hampton, Virginia, United States, 23668', '2024-04-25 17:29:05'),
('7f18c59c-3e61-43f6-946f-d0b81fbd3cc7', 'Hobie', 'Skirving', 'hobie.skirving@yahoo.com', '(510) 572-8801', '7611 Wax Berry Court, Richmond, California, United States, 94807', '2024-04-25 17:35:30'),
('abd49d49-237d-4d28-b3ea-9d19661fcf9b', 'Miller', 'Ipplett', 'miller.ipplett@hotmail.com', '(309) 402-0367', '9991 Delfin Road, Peoria, Illinois, United States, 61651', '2024-04-25 17:39:35'),
('f023ea3c-6500-4297-868e-abd3043b97c1', 'Gale', 'Creaven', 'gale.creaven@sympatico.ca', '(210) 440-2198', '11290 Nackman Place, San Antonio, Texas, United States, 78265', '2024-04-25 17:43:24'),
('f40f3b32-6b03-4f88-896a-949bb777a247', 'Padget', 'Waything', 'padget.waything@gmail.com', '(704) 864-4502', '5929 Turtle Street, Charlotte, North Carolina, United States, 28242', '2024-04-25 17:52:22'),
('9e5061d8-a27f-44cc-a390-5f9ab4d00178', 'Elbert', 'Gogie', 'elbert.gogie@hotmail.co.uk', '(603) 734-3683', '4278 Inner Circle, Manchester, New Hampshire, United States, 03105', '2024-04-25 17:58:30'),
('9f2f61c6-ee32-4494-85a3-2425d533a5b8', 'Kimble', 'McConaghy', 'kimble.mcconaghy@yahoo.com', '(419) 566-8488', '12197 Cumberland Court, Toledo, Ohio, United States, 43666', '2024-04-25 18:01:01'),
('86f4ec23-7064-4bb5-9aaf-b8e98e8d95ec', 'Mirelle', 'Nolan', 'mirelle.nolan@comcast.net', '(520) 573-1239', '8635 Rieger Road, Tucson, Arizona, United States, 85715', '2024-04-25 18:08:03'),
('db0df896-914e-491f-9e31-454b9f1d3c7f', 'Glenna', 'Lehrian', 'glenna.lehrian@hotmail.com', '(314) 201-5509', '2753 Carrollton Court, Saint Louis, Missouri, United States, 63169', '2024-04-25 18:13:23'),
('6e360958-11c9-41fc-a89f-4238b8a0ae24', 'Bendite', 'Godsafe', 'bendite.godsafe@gmail.com', '(808) 649-2746', '2948 Pleasant View Place, Honolulu, Hawaii, United States, 96845', '2024-04-25 18:22:00'),
('a9de1fc5-3ba9-4088-8ee6-5a75104f2c7d', 'Emmye', 'Chappelow', 'emmye.chappelow@hotmail.com', '(814) 619-2939', '12683 San Clemente Court, Erie, Pennsylvania, United States, 16550', '2024-04-25 18:25:26'),
('6a9b75fb-c1c5-4e1a-a94e-07cbb5c41837', 'Gustie', 'Ravillas', 'gustie.ravillas@gmail.com', '(786) 358-6037', '13515 Kauska Way, Miami, Florida, United States, 33111', '2024-04-25 18:28:29'),
('6ae55628-7994-4e93-b964-f75e00363d72', 'Philippe', 'Bartolomeazzi', 'philippe.bartolomeazzi@hotmail.com', '(402) 735-5396', '3763 Impala Place, Lincoln, Nebraska, United States, 68524', '2024-04-25 18:36:32'),
('1833e0d4-fd6c-4474-b416-3ce9e539b363', 'Devon', 'McQuode', 'devon.mcquode@laposte.net', '(415) 371-6505', '7668 Rainbow Blvd., San Francisco, California, United States, 94147', '2024-04-25 18:42:16'),
('8e07d624-a56d-4734-a552-2b3985adedbd', 'Lionel', 'McCudden', 'lionel.mccudden@hotmail.com', '(415) 086-0354', '1199 Santana Way, San Francisco, California, United States, 94159', '2024-04-25 18:49:07'),
('ed4658f1-c11e-484a-b761-c911885548c2', 'Ellie', 'Rablin', 'ellie.rablin@libero.it', '(407) 937-5072', '1236 Merida Circle, Orlando, Florida, United States, 32891', '2024-04-25 18:56:26'),
('53a68a7b-f69c-4a25-8846-0f06497a3b6d', 'Anjanette', 'Callf', 'anjanette.callf@hotmail.com', '(212) 976-3463', '644 Berwyn Way, New York City, New York, United States, 10039', '2024-04-25 19:01:32'),
('ba054855-8fa2-4f85-965a-6ba3b5fc13d3', 'Karl', 'Rowlatt', 'karl.rowlatt@yahoo.com', '(646) 521-3208', '3047 Kerry Place, New York City, New York, United States, 10060', '2024-04-25 19:07:36'),
('5b3fb023-fd43-4cae-8783-ef1c98d11b38', 'Estrella', 'Glentworth', 'estrella.glentworth@aol.com', '(941) 337-2078', '163 Olar Court, Port Charlotte, Florida, United States, 33954', '2024-04-25 19:08:53'),
('14f35ff7-5574-4e12-ad89-7e7704a02e62', 'Corette', 'Vicent', 'corette.vicent@hotmail.com', '(860) 119-3127', '12466 Usher Place, Hartford, Connecticut, United States, 06145', '2024-04-25 19:18:36'),
('585b6bfa-e33a-4e75-8d2e-5cf1e4a42197', 'Antonetta', 'Cavey', 'antonetta.cavey@yahoo.com', '(304) 333-9094', '173 Kingfisher Court, Charleston, West Virginia, United States, 25305', '2024-04-25 19:28:31'),
('0bedb8d0-0c5a-48a9-bae1-5b1fbecf4a10', 'Shaine', 'Matic', 'shaine.matic@hotmail.com', '(904) 114-8620', '2563 Bladewood Court, Jacksonville, Florida, United States, 32230', '2024-04-25 19:31:13'),
('43803350-bfb2-46b7-8949-24dc4b72fbf3', 'Anabella', 'Vaulkhard', 'anabella.vaulkhard@hotmail.com', '(770) 565-3195', '6897 Indale Place, Lawrenceville, Georgia, United States, 30045', '2024-04-25 19:40:57'),
('5c41586b-f7bf-41fa-883a-7b9cb1c4c849', 'Giordano', 'Schutter', 'giordano.schutter@yahoo.com', '(717) 057-6564', '12401 Shubrick Court, Harrisburg, Pennsylvania, United States, 17140', '2024-04-25 19:47:14'),
('7f42152e-6a93-4d03-a9c9-ee0830c5096f', 'Hortense', 'Munsey', 'hortense.munsey@bol.com.br', '(626) 472-3657', '5264 Wyatt Avenue, Pasadena, California, United States, 91117', '2024-04-25 19:56:43'),
('ee6cebc9-6876-4561-9355-b84013639e66', 'Mackenzie', 'Calverley', 'mackenzie.calverley@yahoo.com', '(405) 815-3548', '4330 Clio Lane, Oklahoma City, Oklahoma, United States, 73142', '2024-04-25 20:00:41'),
('b5c6a70e-f40c-43ac-9291-418539d54ae7', 'Sean', 'Palffrey', 'sean.palffrey@gmail.com', '(916) 802-0917', '469 Champion Avenue, Sacramento, California, United States, 95828', '2024-04-25 20:07:26'),
('daf898aa-13cd-465a-b2ed-ce3605ff9cc2', 'Byrom', 'Copnell', 'byrom.copnell@uol.com.br', '(205) 409-8341', '6488 Gable Place, Birmingham, Alabama, United States, 35263', '2024-04-25 20:10:16'),
('23fd617f-9912-4a67-b5cb-60147b25930c', 'Nester', 'Niccolls', 'nester.niccolls@hotmail.com', '(864) 745-5159', '294 Parrish Place, Spartanburg, South Carolina, United States, 29305', '2024-04-25 20:18:28'),
('50acac78-1c19-491e-8e95-2787664d9090', 'Ikey', 'Le Fevre', 'ikey.lefevre@hotmail.com', '(330) 883-4358', '1160 Teakwood Lane, Akron, Ohio, United States, 44315', '2024-04-25 20:20:35'),
('623e0b78-6b7c-4e98-a46a-c96d1c607817', 'Kellia', 'Bowller', 'kellia.bowller@neuf.fr', '(202) 770-5130', '14520 Marlin Place, Washington, District of Columbia, United States, 20508', '2024-04-25 20:26:34'),
('cd125a77-15a1-4c04-aaed-41a05195225b', 'Bessy', 'Exley', 'bessy.exley@yahoo.com', '(850) 279-1291', '10527 Gabriele Place, Tallahassee, Florida, United States, 32399', '2024-04-25 20:35:51'),
('1f2aa50e-b682-43da-b36e-f33d041691dc', 'Donnajean', 'Amerighi', 'donnajean.amerighi@yahoo.de', '(559) 566-8407', '10301 Viking Place, Fresno, California, United States, 93773', '2024-04-25 20:37:09'),
('9da1cc29-9c8b-498c-bbbd-c412a8115cc8', 'Lillian', 'Micheu', 'lillian.micheu@terra.com.br', '(215) 019-1137', '8911 Keeley Court, Philadelphia, Pennsylvania, United States, 19160', '2024-04-25 20:42:05'),
('e19d7be6-0155-4cb3-86ee-ba31a6ff5de1', 'Alon', 'Francomb', 'alon.francomb@t-online.de', '(425) 423-1489', '6862 Carvello Drive, Seattle, Washington, United States, 98133', '2024-04-25 20:43:12'),
('d01d990c-8cbd-4b0f-87b3-4c31fafbf3d5', 'Ethyl', 'Ditchburn', 'ethyl.ditchburn@yahoo.com', '(718) 643-5806', '12077 Cherry Vale Place, Jamaica, New York, United States, 11447', '2024-04-25 20:44:55'),
('ef255303-e28b-4229-aa6f-99eb4f67a81c', 'Marv', 'Husset', 'marv.husset@yahoo.com', '(407) 501-1223', '7296 Gatehouse Terrace, Orlando, Florida, United States, 32868', '2024-04-25 20:50:13'),
('27693ec7-45c9-4230-89d2-d0c98654cde7', 'Sidonnie', 'Marks', 'sidonnie.marks@gmail.com', '(806) 099-5783', '8993 Gaitanos Place, Amarillo, Texas, United States, 79165', '2024-04-25 20:57:32'),
('c7a3c75f-3b79-4fdb-a4ab-52a54401b875', 'Cleavland', 'Yurkevich', 'cleavland.yurkevich@mac.com', '(217) 117-2926', '13531 Tripp Terrace, Springfield, Illinois, United States, 62718', '2024-04-25 21:00:13'),
('287bf982-89ce-44b5-bfdd-49407600309a', 'Niel', 'Yuryatin', 'niel.yuryatin@mail.ru', '(615) 770-5635', '11203 Wentworth Lane, Nashville, Tennessee, United States, 37235', '2024-04-25 21:08:51'),
('37abd855-71e9-4ded-87fe-901c4ccb3d3c', 'Jyoti', 'Treanor', 'jyoti.treanor@yahoo.com', '(253) 948-7342', '633 Kilarny Place, Tacoma, Washington, United States, 98481', '2024-04-25 21:10:29'),
('3eec958e-8cd8-426e-8603-eac1c9b2c004', 'Galen', 'Biddy', 'galen.biddy@orange.fr', '(859) 016-8839', '14370 Ludlow Place, Lexington, Kentucky, United States, 40586', '2024-04-25 21:12:54'),
('f8628b73-c900-4973-849e-22aa8e42fc33', 'Luca', 'Courtney', 'luca.courtney@hotmail.com', '(971) 493-3208', '2377 Enrique Drive, Portland, Oregon, United States, 97240', '2024-04-25 21:21:20'),
('079cd6ce-04a8-4c55-8c2b-b93189e9050a', 'Sergeant', 'Maith', 'sergeant.maith@aol.com', '(512) 551-9311', '11221 Bentwood Lane, Austin, Texas, United States, 78778', '2024-04-25 21:26:38'),
('6ca0328f-1be0-4205-9a57-59cef27a1067', 'Wilden', 'De Paoli', 'wilden.depaoli@wanadoo.fr', '(915) 400-2489', '3582 Bassinger Court, El Paso, Texas, United States, 88546', '2024-04-25 21:29:24'),
('a34887df-cb28-4cab-a2ab-0f7de63719b9', 'Jeniece', 'Mangeon', 'jeniece.mangeon@voila.fr', '(804) 953-0789', '14733 Overstreet Place, Richmond, Virginia, United States, 23220', '2024-04-25 21:37:19'),
('4837eb17-36bb-4c4b-bb49-bc368edb173a', 'Rafe', 'Cornwell', 'rafe.cornwell@hotmail.com', '(806) 635-2657', '8919 Mcnair Terrace, Lubbock, Texas, United States, 79410', '2024-04-25 21:42:21'),
('0ca06e8d-a7a2-40c4-893b-128336ffdf54', 'Buddie', 'Sandison', 'buddie.sandison@yahoo.co.uk', '(205) 075-5889', '8159 Peterson Place, Birmingham, Alabama, United States, 35231', '2024-04-25 21:49:02'),
('4a150c66-0c2b-4626-8e66-4035a87c1ab0', 'Arlina', 'Tofts', 'arlina.tofts@aol.com', '(202) 150-2339', '12561 Rhett Road, Washington, District of Columbia, United States, 20436', '2024-04-25 21:56:23'),
('f1082db9-8d80-4f63-9af8-db2ed4c41080', 'Salomo', 'Saer', 'salomo.saer@bigpond.com', '(862) 854-8184', '12857 Brighton Drive, Paterson, New Jersey, United States, 07505', '2024-04-25 22:02:39'),
('9253d6d7-b356-4e9e-8fa4-e60c1d0327cc', 'Benjie', 'Moore', 'benjie.moore@orange.fr', '(915) 271-1447', '2497 Captiva Court, El Paso, Texas, United States, 88519', '2024-04-25 22:11:41'),
('bb09df35-4fb6-42be-a106-f0f1f1a74012', 'Gerianna', 'Bagworth', 'gerianna.bagworth@gmail.com', '(520) 898-2462', '13575 Hook Hollow Terrace, Tucson, Arizona, United States, 85725', '2024-04-25 22:18:09'),
('93718b0c-9337-4efa-bd48-51713fb1523c', 'Emmy', 'Votier', 'emmy.votier@hotmail.com', '(315) 152-4192', '2129 Ridgeville Road, Syracuse, New York, United States, 13251', '2024-04-25 22:23:11'),
('b980c9fc-c205-4042-81ef-17a613787208', 'Armando', 'Dearl', 'armando.dearl@hotmail.com', '(574) 812-3117', '2268 Glencoe Court, South Bend, Indiana, United States, 46614', '2024-04-25 22:29:42'),
('29f948c1-0d27-4e13-9126-498a6e51a079', 'Spike', 'Sill', 'spike.sill@hotmail.com', '(914) 513-6574', '3253 Cedar Ridge Place, Mount Vernon, New York, United States, 10557', '2024-04-25 22:35:52'),
('1ea5ec60-3f36-4896-af24-13ee03bf06d9', 'Bobette', 'Shambrooke', 'bobette.shambrooke@hotmail.fr', '(269) 629-9553', '6747 Orgovan Avenue, Kalamazoo, Michigan, United States, 49048', '2024-04-25 22:38:27'),
('1b056bda-e6c8-46bb-a706-8db8c2e53061', 'Jacquenette', 'Hilldrup', 'jacquenette.hilldrup@gmail.com', '(504) 592-9957', '2042 Jonquil Place, New Orleans, Louisiana, United States, 70160', '2024-04-25 22:40:40'),
('a424f2b5-0890-4fc1-a71e-9ea7547a5a25', 'Whitby', 'Oldroyde', 'whitby.oldroyde@gmail.com', '(608) 132-1122', '2180 Germakian Lane, Madison, Wisconsin, United States, 53705', '2024-04-25 22:50:33'),
('6b7b3dfa-9959-401f-9b8c-fce6948abc45', 'Seka', 'Rabbe', 'seka.rabbe@aol.com', '(913) 425-9090', '7184 Williamson Drive, Shawnee Mission, Kansas, United States, 66286', '2024-04-25 23:00:22'),
('d933fcc1-a91f-4051-9cc1-58e1bf6be236', 'Broderick', 'Coolbear', 'broderick.coolbear@gmail.com', '(202) 906-1474', '4629 Penno Place, Washington, District of Columbia, United States, 20430', '2024-04-25 23:03:43'),
('a99c66ac-ae2a-4375-b15c-9b1694200e6d', 'Horacio', 'Baxill', 'horacio.baxill@centurytel.net', '(510) 201-3623', '2928 Berwyn Way, Oakland, California, United States, 94611', '2024-04-25 23:05:40'),
('b4a5aa8b-b1f2-478d-b60c-7efd3b198ee5', 'Nathanael', 'Nuzzetti', 'nathanael.nuzzetti@hotmail.com', '(209) 251-9348', '8595 Carriage Hill Way, Fresno, California, United States, 93721', '2024-04-25 23:13:56'),
('3701903e-265f-402d-b8f9-5e46a67a89a6', 'Horst', 'Morecomb', 'horst.morecomb@mail.ru', '(412) 835-1593', '3520 Beacon Hill Court, Pittsburgh, Pennsylvania, United States, 15261', '2024-04-25 23:23:46'),
('b3e475f6-203f-474f-a30c-243fe885b3e1', 'Mikol', 'De Maria', 'mikol.demaria@gmail.com', '(720) 796-5480', '155 Trellis Lane, Littleton, Colorado, United States, 80126', '2024-04-25 23:28:07'),
('a23ae674-314f-4a4b-845a-ae0ff78d3512', 'Glory', 'McCarter', 'glory.mccarter@gmail.com', '(339) 541-4189', '12259 Armondo Drive, Woburn, Massachusetts, United States, 01813', '2024-04-25 23:31:31'),
('33716558-b6fb-43ec-91a8-59207fe42376', 'Billye', 'Lyfe', 'billye.lyfe@gmail.com', '(727) 018-6475', '14303 Morton Lane, Tampa, Florida, United States, 33625', '2024-04-25 23:32:50'),
('13aac759-5c49-42dc-9693-0f46cb1337bb', 'Stephanus', 'Frear', 'stephanus.frear@hotmail.com', '(228) 427-9642', '5521 Lancaster Lane, Gulfport, Mississippi, United States, 39505', '2024-04-25 23:38:56'),
('c7bb143b-430d-4bbc-9ab1-031826291851', 'Antonietta', 'Guswell', 'antonietta.guswell@hotmail.com', '(208) 529-9852', '13204 Laurel Run, Boise, Idaho, United States, 83757', '2024-04-25 23:45:51'),
('e8a917b4-9641-4271-91a2-2a0ef3477c76', 'Auberta', 'Whal', 'auberta.whal@hotmail.com', '(540) 387-9947', '8599 Ridley Terrace, Roanoke, Virginia, United States, 24004', '2024-04-25 23:49:55'),
('ed5f70a9-36e5-433b-abbc-fed08b27bb16', 'Gardy', 'Fritschel', 'gardy.fritschel@ymail.com', '(972) 977-7822', '3780 Berrington Loop, Denton, Texas, United States, 76210', '2024-04-25 23:52:17'),
('82cac284-ec70-4be8-a43e-b002fc419e26', 'Noellyn', 'Crinage', 'noellyn.crinage@rediffmail.com', '(770) 368-6780', '3894 Cruz Court, Marietta, Georgia, United States, 30061', '2024-04-26 00:00:47'),
('fa5b05d5-cd6d-4e43-840d-4e368a1dac48', 'Shanna', 'Oaten', 'shanna.oaten@rediffmail.com', '(717) 310-2552', '552 Eastmont Court, Harrisburg, Pennsylvania, United States, 17121', '2024-04-26 00:05:01'),
('85916c42-22cb-4462-9fa2-9c45feea827e', 'Jodi', 'McIlwreath', 'jodi.mcilwreath@hotmail.com', '(574) 013-3213', '6048 Impala Place, South Bend, Indiana, United States, 46634', '2024-04-26 00:10:41'),
('43776145-9002-47aa-a868-c0ca95951f5b', 'Jamie', 'Beirne', 'jamie.beirne@rediffmail.com', '(602) 646-0995', '9686 Brunell Street, Glendale, Arizona, United States, 85311', '2024-04-26 00:14:59'),
('ef998517-9d3b-429c-be1b-5b164ba2afe2', 'Marcelle', 'Berrie', 'marcelle.berrie@hotmail.com', '(407) 515-1258', '9020 Wresh Way, Orlando, Florida, United States, 32859', '2024-04-26 00:16:57'),
('d46ba1b1-9ff9-42e1-b7ad-7138cee43bf2', 'Roseann', 'Bonfield', 'roseann.bonfield@hotmail.com', '(434) 309-0314', '8795 Sylewood Avenue, Manassas, Virginia, United States, 22111', '2024-04-26 00:18:16'),
('719c88a7-ba09-4109-a4f8-ba659d01ebf6', 'Dorella', 'Clavey', 'dorella.clavey@yahoo.com', '(707) 624-4058', '14554 Maxwell Terrace, Petaluma, California, United States, 94975', '2024-04-26 00:25:10'),
('52d177ad-467a-400c-9f5e-a51bfffce616', 'Donny', 'Bamsey', 'donny.bamsey@aliceadsl.fr', '(805) 328-1517', '6314 Goldenrod Court, San Luis Obispo, California, United States, 93407', '2024-04-26 00:30:15'),
('ea53056c-33eb-49f9-b00d-71b8b74f5829', 'Carlye', 'Clouter', 'carlye.clouter@gmail.com', '(626) 337-4202', '3299 Butler Court, Burbank, California, United States, 91520', '2024-04-26 00:38:13'),
('26ae893b-6b51-41b9-9b07-a8d07e8a2979', 'Rebekah', 'Conkie', 'rebekah.conkie@yahoo.co.jp', '(407) 279-4605', '6619 Nueva Place, Kissimmee, Florida, United States, 34745', '2024-04-26 00:45:35'),
('69514bb4-0f65-4e74-b29e-92b1febb7933', 'Ogdon', 'Ferrand', 'ogdon.ferrand@gmail.com', '(713) 537-3924', '13687 Randolph Loop, Houston, Texas, United States, 77299', '2024-04-26 00:52:34'),
('b9779359-2984-4b3a-83cd-0e0eab80293c', 'Stanislaus', 'Morecombe', 'stanislaus.morecombe@yahoo.com', '(812) 022-1764', '295 Fort Mill Court, Evansville, Indiana, United States, 47737', '2024-04-26 00:59:36'),
('1f72084e-90f3-4334-9b8f-a3b350c2beb0', 'Barbabra', 'Swires', 'barbabra.swires@hotmail.com', '(570) 979-3301', '6755 Incorvaia Way, Wilkes Barre, Pennsylvania, United States, 18768', '2024-04-26 01:02:12');

INSERT INTO "accounts" ("account_id", "customer_id", "account_number", "account_type", "balance", "created_at") VALUES
('9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7', '1ea5ec60-3f36-4896-af24-13ee03bf06d9', '9885390599', 'savings', '9038.34', '2024-04-25 15:51:30'),
('905660c8-d6a7-40e9-9be3-e6711d22efb6', 'f8628b73-c900-4973-849e-22aa8e42fc33', '5421050024', 'current', '8818.69', '2024-04-25 15:54:41'),
('4fae08d1-3301-4031-a7d5-1b6eac9a2bdd', '3f5ab011-f526-4bbd-8ab8-8a67ad95c5bf', '1685828176', 'credit', '9635.80', '2024-04-25 16:04:13'),
('5ccb459e-6c87-432b-a742-c6c7cbf0dae3', 'ed4658f1-c11e-484a-b761-c911885548c2', '8493110781', 'credit', '11681.49', '2024-04-25 16:06:08'),
('8a54f7b6-3ac0-4aee-88c4-ff386444e673', '29f948c1-0d27-4e13-9126-498a6e51a079', '2655293508', 'savings', '7557.60', '2024-04-25 16:12:40'),
('e0c672fd-8182-42b1-8a70-2138f223c47c', '623e0b78-6b7c-4e98-a46a-c96d1c607817', '0500742994', 'current', '11273.06', '2024-04-25 16:16:29'),
('8c46fae1-9789-4427-8440-7cf48a0272cd', '5b3fb023-fd43-4cae-8783-ef1c98d11b38', '9936621019', 'credit', '9768.42', '2024-04-25 16:20:15'),
('fe716f26-3b0e-4fe5-bc40-4663f4fa66c0', 'f40f3b32-6b03-4f88-896a-949bb777a247', '7644255747', 'savings', '9900.74', '2024-04-25 16:29:20'),
('2229fe26-cc7f-4a58-9caf-d79a7f45b93e', 'b980c9fc-c205-4042-81ef-17a613787208', '0531000214', 'current', '9413.20', '2024-04-25 16:39:18'),
('0937445f-d5eb-4ef9-887f-4173fe662dd4', 'b5c6a70e-f40c-43ac-9291-418539d54ae7', '0925361770', 'credit', '7739.25', '2024-04-25 16:46:18'),
('d6a1328a-055b-40f3-9c71-da27fec396d2', 'ed5f70a9-36e5-433b-abbc-fed08b27bb16', '0062060878', 'savings', '10699.44', '2024-04-25 16:48:48'),
('916673e7-fd52-47ed-bece-efb700890f1f', '79dcf8ce-329d-48a8-ac2c-9fa869b4ac42', '2529864614', 'current', '11890.48', '2024-04-25 16:50:00'),
('748ace76-6b8a-4fd4-9de1-b6154ce22189', '9e5061d8-a27f-44cc-a390-5f9ab4d00178', '3556624060', 'current', '9763.55', '2024-04-25 16:56:45'),
('71c0f7ab-b701-45f0-9c94-802383b3cc36', '3a57a285-56e7-4900-bc63-d044f2247ff1', '4439138749', 'credit', '12301.00', '2024-04-25 17:06:17'),
('da3b43bc-55d1-4f0b-80d1-494ccfc9acc5', 'd01d990c-8cbd-4b0f-87b3-4c31fafbf3d5', '0587333038', 'savings', '10257.16', '2024-04-25 17:07:39'),
('f75c87e7-70a8-4fbd-8ad6-9d5e9cefc314', '079cd6ce-04a8-4c55-8c2b-b93189e9050a', '3849055069', 'current', '12498.44', '2024-04-25 17:12:29'),
('48eef121-050c-4362-b2b1-96a32f5fe6a9', '4a150c66-0c2b-4626-8e66-4035a87c1ab0', '8992271456', 'credit', '7548.97', '2024-04-25 17:22:01'),
('58e3e8fa-7549-4390-821e-d643a13d9c36', 'ea53056c-33eb-49f9-b00d-71b8b74f5829', '9726970308', 'savings', '10054.09', '2024-04-25 17:23:40'),
('8d8d1450-995a-4db8-84d1-47779bd7d233', '82cac284-ec70-4be8-a43e-b002fc419e26', '8375062940', 'savings', '8034.65', '2024-04-25 17:28:48'),
('f9341b55-2686-40af-9e1b-2986672efd92', '6ae55628-7994-4e93-b964-f75e00363d72', '3493783953', 'current', '9418.54', '2024-04-25 17:37:38'),
('65b4514d-4bbb-4aed-b0e0-859e1bef135e', '0bedb8d0-0c5a-48a9-bae1-5b1fbecf4a10', '0851676096', 'credit', '9900.74', '2024-04-25 17:43:38'),
('14f24b1b-6e86-4cb3-bbc4-0293bc90f756', '23fd617f-9912-4a67-b5cb-60147b25930c', '6037525484', 'credit', '11555.86', '2024-04-25 17:48:49'),
('c4dd8020-5b57-4739-9d49-0f7172ffaf3f', 'db0df896-914e-491f-9e31-454b9f1d3c7f', '8771754618', 'savings', '8145.11', '2024-04-25 17:57:04'),
('b28eca06-abd3-43b5-b602-37bca09a6116', '57829c08-247e-4dec-b528-cd1099fc1e81', '7240585472', 'current', '9471.21', '2024-04-25 18:05:02'),
('535ff8ea-7b01-48a3-93a3-27288067830c', 'a9de1fc5-3ba9-4088-8ee6-5a75104f2c7d', '5502821697', 'current', '10851.95', '2024-04-25 18:10:33'),
('45ff6d75-3e4b-43ab-9343-ba2e0de1069a', '1f2aa50e-b682-43da-b36e-f33d041691dc', '8125017439', 'credit', '9791.44', '2024-04-25 18:18:15'),
('07a36a4b-7943-4634-b17a-7c7eb4407cd3', '287bf982-89ce-44b5-bfdd-49407600309a', '8346813622', 'savings', '8573.55', '2024-04-25 18:26:33'),
('6edc13ce-6ed2-48a7-b73d-ef6ed8b73e38', 'ef255303-e28b-4229-aa6f-99eb4f67a81c', '5227798778', 'credit', '9827.91', '2024-04-25 18:27:37'),
('ce49f4c7-302b-4d63-b068-8f01fd6e28a7', '6daa0a7c-3ca5-4ace-9d6c-b119d9067a6a', '9293350610', 'savings', '11102.62', '2024-04-25 18:31:30'),
('73b13073-025d-45c9-bed2-6b6760e7e10d', '93718b0c-9337-4efa-bd48-51713fb1523c', '1656200086', 'current', '8837.70', '2024-04-25 18:37:30'),
('d094e634-9744-478d-b73b-1a73149b198b', '9da1cc29-9c8b-498c-bbbd-c412a8115cc8', '9454584737', 'current', '11920.21', '2024-04-25 18:42:53'),
('441aa9d2-bdf2-4b65-a79f-c18e66de0e17', 'f1082db9-8d80-4f63-9af8-db2ed4c41080', '2552991115', 'credit', '8548.32', '2024-04-25 18:51:48'),
('36f3d280-2886-4e51-adcd-dfc644e59d80', '1b056bda-e6c8-46bb-a706-8db8c2e53061', '9387902534', 'savings', '8374.51', '2024-04-25 18:58:59'),
('ed508747-a9a1-432c-980f-388a4be8398d', 'dc0f5f48-84ef-4f9b-bd05-ef9217f050fe', '9861896539', 'credit', '11060.36', '2024-04-25 19:04:24'),
('3f494e04-a406-4692-a584-19db622e48ac', '5c41586b-f7bf-41fa-883a-7b9cb1c4c849', '4295222278', 'savings', '11266.23', '2024-04-25 19:13:28'),
('4aab87c4-eb74-4e4e-ab8f-c13638276de1', 'ba054855-8fa2-4f85-965a-6ba3b5fc13d3', '0829651833', 'current', '12152.62', '2024-04-25 19:22:24'),
('c8a710b1-6302-4189-8149-da76be7fdfc1', 'e8a917b4-9641-4271-91a2-2a0ef3477c76', '0327410016', 'savings', '9149.16', '2024-04-25 19:32:06'),
('80c28cdf-f2fb-4232-bbd5-39404d8199c2', 'a99c66ac-ae2a-4375-b15c-9b1694200e6d', '9060219682', 'current', '11425.85', '2024-04-25 19:40:47'),
('ca19992d-7bc5-4903-8fba-699825411b95', '719c88a7-ba09-4109-a4f8-ba659d01ebf6', '6182594105', 'credit', '11883.99', '2024-04-25 19:41:57'),
('a6d46634-1645-4107-8594-983d4a4c90ce', '8e07d624-a56d-4734-a552-2b3985adedbd', '7474814784', 'credit', '10225.06', '2024-04-25 19:49:04'),
('418a133e-5e1f-4377-8d48-63de24b5b08e', '50acac78-1c19-491e-8e95-2787664d9090', '2015740367', 'savings', '8166.30', '2024-04-25 19:54:47'),
('789de9f0-5ef0-46cc-bb19-fbe4928474e6', 'abd49d49-237d-4d28-b3ea-9d19661fcf9b', '7404474193', 'current', '10950.41', '2024-04-25 20:03:18'),
('2b4fc68b-f926-4889-910b-634ad923efea', 'c7bb143b-430d-4bbc-9ab1-031826291851', '3303452230', 'credit', '11356.47', '2024-04-25 20:06:12'),
('5b98a4b0-ee51-4b17-9584-d5ae35ce9e6b', 'fd29af21-54cd-42a1-a4d7-40890f6dd658', '5252342645', 'savings', '12491.78', '2024-04-25 20:10:22'),
('68c0a815-9332-4453-8a91-5ce066bb07e2', '9f2f61c6-ee32-4494-85a3-2425d533a5b8', '9084279295', 'current', '11201.80', '2024-04-25 20:13:32'),
('15b082e5-92e7-4375-a7d9-f7224d35ba13', 'a34887df-cb28-4cab-a2ab-0f7de63719b9', '2504168116', 'savings', '9419.50', '2024-04-25 20:21:00'),
('309d1066-7bcf-4772-9c5f-16aff605512e', 'f832a165-6ce7-4d54-9cf4-2b58ad4b4cf5', '9913196358', 'current', '9189.11', '2024-04-25 20:29:00'),
('2fdf706a-7187-470c-a1c3-f3e747b72f20', '6b7b3dfa-9959-401f-9b8c-fce6948abc45', '8378959584', 'credit', '7550.53', '2024-04-25 20:35:43'),
('b2b1797e-b848-4af5-8a52-2e4d66a5af90', '1833e0d4-fd6c-4474-b416-3ce9e539b363', '6958155556', 'current', '10283.46', '2024-04-25 20:42:17'),
('7b1fccd6-d4ab-4f58-9ae1-b45947264b33', '61ac2df4-4e87-4f00-af98-a9c55edbdd80', '0690581077', 'credit', '11177.27', '2024-04-25 20:49:34'),
('bf4afaa6-c52c-4b4e-b7f8-543eeb1ec49c', '7f18c59c-3e61-43f6-946f-d0b81fbd3cc7', '6417382807', 'savings', '10455.22', '2024-04-25 20:55:32'),
('dfd76a72-6dbc-4b94-a856-b77dd59d3b4a', '357e3969-87b3-48e9-bd0b-4a658de0dd38', '5823994373', 'credit', '9504.70', '2024-04-25 20:59:27'),
('ac35eddd-0fb1-4711-9bb8-1985fc566b52', '27693ec7-45c9-4230-89d2-d0c98654cde7', '1582257006', 'savings', '11847.59', '2024-04-25 21:08:26'),
('bff8f8bd-3931-4f3f-b0c1-636597f97db5', '585b6bfa-e33a-4e75-8d2e-5cf1e4a42197', '4448148587', 'current', '8568.36', '2024-04-25 21:11:02'),
('d7461fd9-005f-47c5-aed6-98c6b03f378b', 'f023ea3c-6500-4297-868e-abd3043b97c1', '1204062801', 'credit', '8127.95', '2024-04-25 21:17:02'),
('40ede99d-89ee-49c9-b1f9-de9b0e61ff33', 'e19d7be6-0155-4cb3-86ee-ba31a6ff5de1', '2679408260', 'savings', '10366.65', '2024-04-25 21:24:28'),
('1d97bce1-5c94-49e4-8e2a-6ad56b99afb0', '69514bb4-0f65-4e74-b29e-92b1febb7933', '9533820584', 'current', '8003.75', '2024-04-25 21:34:26'),
('def2f626-6db4-4fea-baa2-33fafd90c494', 'd933fcc1-a91f-4051-9cc1-58e1bf6be236', '8786190425', 'credit', '12405.09', '2024-04-25 21:41:24'),
('57620a31-a1ee-4dbc-9a72-09bc5bb72b7d', '3eec958e-8cd8-426e-8603-eac1c9b2c004', '5606148528', 'savings', '9089.69', '2024-04-25 21:47:17'),
('a448f319-9dc4-4c02-b016-e1eab2b49629', 'ef998517-9d3b-429c-be1b-5b164ba2afe2', '6580443064', 'current', '11362.38', '2024-04-25 21:52:50'),
('3a6e7b4a-c8db-4750-bbbc-a337ef92efe4', '7f42152e-6a93-4d03-a9c9-ee0830c5096f', '0080929534', 'savings', '9364.19', '2024-04-25 21:57:50'),
('70b25eda-9b65-489a-b3b5-1b7650795fbd', '870ae237-d669-42dd-b283-99c1219bf349', '4123981372', 'current', '10811.93', '2024-04-25 22:02:18'),
('418fedb1-da8f-4c67-8073-4a147e2f5ded', '5d8912f2-8074-4f41-b002-e0c789e7f718', '9504378931', 'credit', '7908.72', '2024-04-25 22:11:45'),
('17a9ed0a-5ed3-41d6-9e20-df434296c83d', 'ee6cebc9-6876-4561-9355-b84013639e66', '1861310439', 'current', '11644.05', '2024-04-25 22:18:31'),
('89a22c8c-57ba-4baa-8b71-13d1210a62d6', 'cd125a77-15a1-4c04-aaed-41a05195225b', '1826894165', 'credit', '10483.59', '2024-04-25 22:20:08'),
('a9eb22fe-d2a1-4f58-b903-ba06bfab92c4', 'bb09df35-4fb6-42be-a106-f0f1f1a74012', '0732497685', 'savings', '7966.49', '2024-04-25 22:25:41'),
('be1f9370-375a-4d20-bf0d-284e833ff113', '6b612ed4-f731-4963-85f3-780a438e0fad', '8526139668', 'current', '11213.28', '2024-04-25 22:35:13'),
('5ea6c838-111c-484c-9b2b-bc4b5776f48f', '6f6a46c1-26ae-47c8-82aa-34027c84af78', '5771758571', 'credit', '11976.35', '2024-04-25 22:37:23'),
('4d499ecc-5bee-4104-a1b0-32ceff979305', 'a424f2b5-0890-4fc1-a71e-9ea7547a5a25', '2978718771', 'savings', '9948.52', '2024-04-25 22:43:49'),
('318c43bf-9511-4030-bd13-81a47a4b8cac', '37abd855-71e9-4ded-87fe-901c4ccb3d3c', '2528373607', 'credit', '7854.32', '2024-04-25 22:53:45'),
('eae2bb46-3bd9-4bd6-a6b7-1b2efdc1911a', '4837eb17-36bb-4c4b-bb49-bc368edb173a', '8822070016', 'savings', '11333.82', '2024-04-25 22:56:01'),
('54c49a0b-5dc6-46f8-abf2-ed2d1e56da8c', '1f72084e-90f3-4334-9b8f-a3b350c2beb0', '4885167114', 'current', '9788.96', '2024-04-25 23:03:15'),
('71de6c84-d689-4792-b730-7711deb2a408', 'b3e475f6-203f-474f-a30c-243fe885b3e1', '6496171469', 'current', '9467.68', '2024-04-25 23:09:43'),
('1afc36b6-ae72-48ff-9d51-5f57fac653bc', 'd46ba1b1-9ff9-42e1-b7ad-7138cee43bf2', '9736407913', 'credit', '10013.89', '2024-04-25 23:12:26'),
('a2ab1bd6-0020-4555-ba43-5c1f69332851', '86f4ec23-7064-4bb5-9aaf-b8e98e8d95ec', '9760233499', 'savings', '10416.31', '2024-04-25 23:16:50'),
('2156bbb2-c082-45e5-a5d6-f66752c37690', '6ca0328f-1be0-4205-9a57-59cef27a1067', '9400361433', 'savings', '9479.91', '2024-04-25 23:24:37'),
('c044b4de-6caf-4d33-91d3-50c621e194b0', 'fa5b05d5-cd6d-4e43-840d-4e368a1dac48', '2273497539', 'current', '8225.68', '2024-04-25 23:29:49'),
('8d7d7e4b-11a9-47e3-bca0-8f3aa0bada73', '53a68a7b-f69c-4a25-8846-0f06497a3b6d', '8952674354', 'credit', '9702.38', '2024-04-25 23:35:49'),
('72acc609-0cc6-4fcd-bad7-5d7e6c58ae3d', 'b4a5aa8b-b1f2-478d-b60c-7efd3b198ee5', '2944854389', 'credit', '10805.82', '2024-04-25 23:44:10'),
('bc45041a-05a7-4c9e-a2c0-324829aaca62', '6a9b75fb-c1c5-4e1a-a94e-07cbb5c41837', '8102086547', 'savings', '9980.78', '2024-04-25 23:48:39'),
('d29c5b3d-6bb3-4248-bf1a-4339bc80b6b0', '9d78736f-df51-4622-9cb1-c4db88dca2d0', '2075461919', 'current', '10838.30', '2024-04-25 23:51:31'),
('6d17ee21-72d5-4fb5-a638-ef220307dcd9', '6e360958-11c9-41fc-a89f-4238b8a0ae24', '1588301119', 'savings', '8549.18', '2024-04-25 23:57:37'),
('85202b58-ec17-4407-ae0b-fab4ae861dac', '52d177ad-467a-400c-9f5e-a51bfffce616', '1474276485', 'current', '9143.14', '2024-04-26 00:03:15'),
('11d9d6f7-35d3-4ba3-bcca-a6b1e8f68519', '33716558-b6fb-43ec-91a8-59207fe42376', '4643651470', 'credit', '9879.43', '2024-04-26 00:08:20'),
('80d384e7-9b48-4806-9897-32969e337683', '7ab376ee-2fca-4f08-98aa-9b93cc0fc972', '0130433753', 'savings', '11086.68', '2024-04-26 00:14:48'),
('96da7988-0695-4780-a7c3-6c935daccc59', '462d21d0-7672-428a-abf7-04c18a1efde8', '4896256429', 'current', '11370.14', '2024-04-26 00:19:28'),
('92ffabae-dab4-4737-8b26-ee60ed598cea', 'daf898aa-13cd-465a-b2ed-ce3605ff9cc2', '4154417169', 'credit', '10871.11', '2024-04-26 00:25:34'),
('1118a259-aa7d-402b-9f1f-72555ed15180', '14f35ff7-5574-4e12-ad89-7e7704a02e62', '7713339428', 'savings', '11518.16', '2024-04-26 00:34:27'),
('c73f146f-aef6-415f-bc17-8bf06ba9819e', 'b9779359-2984-4b3a-83cd-0e0eab80293c', '2769479719', 'current', '9708.94', '2024-04-26 00:36:55'),
('5d8f91d2-881d-46c9-9d1f-19d33516897f', '26ae893b-6b51-41b9-9b07-a8d07e8a2979', '3578650352', 'credit', '9901.20', '2024-04-26 00:42:54'),
('c50f01a9-441b-4a71-81c8-9f2a78288a92', '0ca06e8d-a7a2-40c4-893b-128336ffdf54', '8530330039', 'current', '10980.79', '2024-04-26 00:49:49'),
('802b2efe-e1d1-465b-940f-5cf573a2c985', '3701903e-265f-402d-b8f9-5e46a67a89a6', '1704735459', 'credit', '11396.93', '2024-04-26 00:51:57'),
('c49c54f1-1926-4cbb-b3f2-2299152dce3a', '20b542e7-3b96-4059-b30a-6d09832e17de', '2537086085', 'savings', '11935.55', '2024-04-26 01:00:52'),
('4adb1b7b-163e-4a1b-956f-9a3fa65d8b70', '43803350-bfb2-46b7-8949-24dc4b72fbf3', '6990994811', 'credit', '12170.02', '2024-04-26 01:02:59'),
('c098f0dd-6434-4f69-afdd-d756849fe1fd', '13aac759-5c49-42dc-9693-0f46cb1337bb', '8421559542', 'savings', '7757.62', '2024-04-26 01:12:55'),
('980c1a90-3d66-4010-81c8-32cde239d423', 'c7a3c75f-3b79-4fdb-a4ab-52a54401b875', '3853720021', 'current', '11987.17', '2024-04-26 01:22:26'),
('15c1de08-94a5-482d-9db5-682a1581ed84', '43776145-9002-47aa-a868-c0ca95951f5b', '6264480743', 'current', '11309.22', '2024-04-26 01:31:27'),
('34e9be76-4674-4d0f-b7c0-a39e43548747', '85916c42-22cb-4462-9fa2-9c45feea827e', '2187973070', 'credit', '8590.58', '2024-04-26 01:37:44'),
('39e495d4-8be7-45fa-aab6-1ee6312cdd04', '9253d6d7-b356-4e9e-8fa4-e60c1d0327cc', '1555272741', 'savings', '9563.96', '2024-04-26 01:47:34'),
('45d4aa3e-cee4-431f-ac63-f83e4c56e862', 'a23ae674-314f-4a4b-845a-ae0ff78d3512', '2457207788', 'current', '9583.76', '2024-04-26 01:50:45');

INSERT INTO "cards" ("card_id", "account_id", "card_number", "card_type", "expiration_date") VALUES
('53aa254b-1c5d-473d-a5b8-c8db623a9e87', 'c044b4de-6caf-4d33-91d3-50c621e194b0', '4253532082189968', 'debit', '2025-03-26'),
('30da5816-fbe5-44fc-8e2a-c2f6f0ea3be2', '5ccb459e-6c87-432b-a742-c6c7cbf0dae3', '4751653597240', 'credit', '2024-12-30'),
('7f6d2495-9221-4531-bd8f-00590beede5c', 'a9eb22fe-d2a1-4f58-b903-ba06bfab92c4', '617975596867923293', 'debit', '2025-02-27'),
('6b4056b7-2154-4f7a-9fc0-45beb63c5611', 'ac35eddd-0fb1-4711-9bb8-1985fc566b52', '5192945646404106', 'credit', '2024-10-29'),
('7770caab-3418-43ed-bec6-b8963092dbb8', '80d384e7-9b48-4806-9897-32969e337683', '5366716010905675', 'debit', '2024-06-12'),
('59e11ab2-8545-4004-aa8c-193c149495f2', 'def2f626-6db4-4fea-baa2-33fafd90c494', '613084037991179368', 'credit', '2024-06-06'),
('5d97e252-ab32-4f18-a763-b3b0332d3bfa', '57620a31-a1ee-4dbc-9a72-09bc5bb72b7d', '608459762865241328', 'credit', '2024-11-15'),
('85a01d94-85dc-4e23-9f6a-d39cc1b702da', '45d4aa3e-cee4-431f-ac63-f83e4c56e862', '5278752967165796', 'debit', '2024-05-02'),
('e98e8a7c-dfaa-46d9-934f-f0dd090c18fd', '418a133e-5e1f-4377-8d48-63de24b5b08e', '611343983846791629', 'credit', '2024-04-30'),
('dd723f42-f1a3-476b-ba1d-1eba67eaccf2', '07a36a4b-7943-4634-b17a-7c7eb4407cd3', '615184939633015120', 'debit', '2025-02-04'),
('33237613-3a17-4101-b24e-b73fa2245c21', '58e3e8fa-7549-4390-821e-d643a13d9c36', '4196693533459515', 'credit', '2024-12-14'),
('160e32ee-db6f-4605-a947-897ca22bbc20', '6d17ee21-72d5-4fb5-a638-ef220307dcd9', '348411742003251', 'debit', '2024-06-08'),
('f5a3cbeb-0977-4b62-b917-f8b94a3b47bb', 'c4dd8020-5b57-4739-9d49-0f7172ffaf3f', '373517598275455', 'credit', '2024-07-09'),
('9ad19f3e-d586-41df-9ed9-ae5ed8abe1c2', '15c1de08-94a5-482d-9db5-682a1581ed84', '4010250561404', 'debit', '2024-08-06'),
('99d95af1-b076-4856-a097-c65d187aaa49', '535ff8ea-7b01-48a3-93a3-27288067830c', '5372926409487829', 'credit', '2024-06-14'),
('f19c2f88-8f1c-4b08-8613-a9f8e5db4d01', '8d7d7e4b-11a9-47e3-bca0-8f3aa0bada73', '614962358423715800', 'debit', '2024-06-14'),
('bbc627dc-8df0-4554-b947-c42dda198e80', '71c0f7ab-b701-45f0-9c94-802383b3cc36', '377724444087940', 'credit', '2024-07-24'),
('3d268772-9e67-431e-9c22-e57ef6eef9da', 'b28eca06-abd3-43b5-b602-37bca09a6116', '5495193987832569', 'debit', '2025-02-19'),
('fe9f8279-255f-4d0e-a7c3-18eac663f1c6', '17a9ed0a-5ed3-41d6-9e20-df434296c83d', '613495382506603871', 'credit', '2025-03-24'),
('6cae210f-0ad9-4f6d-9453-36eaeb99d8d9', '70b25eda-9b65-489a-b3b5-1b7650795fbd', '370953767850143', 'debit', '2024-06-11'),
('bb85940c-7b7b-4564-8bd9-4ebfeaa6efd3', '71de6c84-d689-4792-b730-7711deb2a408', '375439313837441', 'credit', '2025-02-12'),
('74a8f0ba-ebb9-4a69-a721-9f09fc78e339', '6edc13ce-6ed2-48a7-b73d-ef6ed8b73e38', '5398657954290850', 'debit', '2024-08-05'),
('a0221c84-54ae-4fba-b3c1-9198878ba950', '8c46fae1-9789-4427-8440-7cf48a0272cd', '349563186046762', 'debit', '2024-12-11'),
('cdaf34fc-faff-42c7-acec-4da4ee7ba758', '5b98a4b0-ee51-4b17-9584-d5ae35ce9e6b', '600363176843694650', 'credit', '2024-11-26'),
('c58239ed-0f10-46f8-8f04-6be6b46ab738', 'c50f01a9-441b-4a71-81c8-9f2a78288a92', '5521135302233302', 'credit', '2024-09-08'),
('08414549-8847-4682-8589-0b7ad5dccba8', '2156bbb2-c082-45e5-a5d6-f66752c37690', '377145743442232', 'debit', '2025-02-07'),
('3c77d4e2-98a3-406d-96d1-6f6edbf56dc3', '39e495d4-8be7-45fa-aab6-1ee6312cdd04', '4779591067125', 'debit', '2025-03-11'),
('2ff41b50-b145-498e-8cd9-9407505d170c', '3f494e04-a406-4692-a584-19db622e48ac', '349838650679207', 'credit', '2024-11-26'),
('12f61a47-ed35-4064-9b34-76d3b9a1350e', '11d9d6f7-35d3-4ba3-bcca-a6b1e8f68519', '610258712558331588', 'debit', '2024-10-27'),
('fc77cc15-6ecd-4536-93c3-88d9826c56a9', '905660c8-d6a7-40e9-9be3-e6711d22efb6', '601951306789429060', 'credit', '2024-10-03'),
('c9db9e10-b33f-4b4c-bd52-7d858865e3a0', '65b4514d-4bbb-4aed-b0e0-859e1bef135e', '619687707710162121', 'credit', '2025-02-10'),
('26f77805-db60-4c27-b10f-b3297deb4d9e', '1afc36b6-ae72-48ff-9d51-5f57fac653bc', '5359336569985918', 'debit', '2024-08-26'),
('eed6b346-1810-439c-a698-67c3045fed41', '85202b58-ec17-4407-ae0b-fab4ae861dac', '5133628803898953', 'credit', '2024-05-31'),
('0277daeb-c77d-43b0-b049-33bc7d024744', '802b2efe-e1d1-465b-940f-5cf573a2c985', '4830343622653949', 'debit', '2024-07-17'),
('fff0ab15-2876-4858-8420-dc43de17f3ce', '5ea6c838-111c-484c-9b2b-bc4b5776f48f', '617107804877836567', 'debit', '2024-07-17'),
('1c7e9cc4-eec0-442b-9e47-8a85333f6c42', 'd29c5b3d-6bb3-4248-bf1a-4339bc80b6b0', '345018917841588', 'credit', '2024-06-14'),
('50b69b55-9cb7-4563-a2d3-ba39042c84b1', 'bc45041a-05a7-4c9e-a2c0-324829aaca62', '4816715287749351', 'debit', '2024-08-28'),
('239cb94e-64ed-4313-884b-e6171884f571', '7b1fccd6-d4ab-4f58-9ae1-b45947264b33', '371028167021611', 'credit', '2024-09-09'),
('02e348c7-a8ff-43bc-861c-a54b2ed3febc', '980c1a90-3d66-4010-81c8-32cde239d423', '617416399548004592', 'credit', '2024-08-19'),
('469e9231-a6a0-4acf-b769-b3887d5956f8', '40ede99d-89ee-49c9-b1f9-de9b0e61ff33', '349733003251728', 'debit', '2025-01-02'),
('07fa4f57-a214-4e56-8076-40a380ce2335', '8a54f7b6-3ac0-4aee-88c4-ff386444e673', '377042735626230', 'debit', '2024-05-13'),
('3b51f117-1adf-4c68-83ed-0542eaf787ce', 'da3b43bc-55d1-4f0b-80d1-494ccfc9acc5', '342828062307774', 'credit', '2025-02-23'),
('8b420a1b-186a-4ecf-ac94-06dbe721e7b0', 'a2ab1bd6-0020-4555-ba43-5c1f69332851', '5435231708290932', 'debit', '2025-02-01'),
('062241fe-b20b-4507-8037-5cc2f55159be', '3a6e7b4a-c8db-4750-bbbc-a337ef92efe4', '345181959052601', 'credit', '2024-08-23'),
('06267414-602e-4364-829d-74718b3b42d8', '418fedb1-da8f-4c67-8073-4a147e2f5ded', '374808404066892', 'debit', '2024-12-07'),
('9aae5de0-948f-4afb-82c2-614b11764e93', 'ed508747-a9a1-432c-980f-388a4be8398d', '5238920802734873', 'credit', '2025-02-15'),
('75a14e25-794a-458d-a9f7-f2fc9fde5f3f', '96da7988-0695-4780-a7c3-6c935daccc59', '608674252647852112', 'debit', '2024-05-01'),
('7ba1d153-ec28-42fb-bd39-830deb48582b', '4fae08d1-3301-4031-a7d5-1b6eac9a2bdd', '616720099071012755', 'credit', '2024-11-13'),
('7bdc64a7-52b1-4de9-b781-7019aaebafc3', 'c73f146f-aef6-415f-bc17-8bf06ba9819e', '612475276939830752', 'debit', '2024-09-26'),
('afd79f74-1632-4615-b29e-b588f91a3c6b', '2229fe26-cc7f-4a58-9caf-d79a7f45b93e', '5291855267769598', 'credit', '2024-05-28'),
('9d116062-58ae-42a9-aaab-ea3619c1f3a4', '68c0a815-9332-4453-8a91-5ce066bb07e2', '609261895801879342', 'debit', '2024-07-30'),
('63690f6b-534c-4622-aae3-0ee7c6b6c650', '89a22c8c-57ba-4baa-8b71-13d1210a62d6', '4383963440809', 'credit', '2025-02-05'),
('fdde1b9c-a3da-409e-9f0f-0b47a76eca8a', '309d1066-7bcf-4772-9c5f-16aff605512e', '4726759869796926', 'debit', '2024-05-13'),
('fa7fde94-f537-4cb0-8942-d8f9adb6cbbb', 'dfd76a72-6dbc-4b94-a856-b77dd59d3b4a', '345881261929900', 'credit', '2025-03-25'),
('f38abe62-15f8-4f4a-a720-ac5c1dd4889a', 'bf4afaa6-c52c-4b4e-b7f8-543eeb1ec49c', '4725116332578129', 'debit', '2024-05-19'),
('45ad4a5c-fc29-4ef3-9f04-ebaf927b9e9e', '36f3d280-2886-4e51-adcd-dfc644e59d80', '5247195743755274', 'credit', '2025-04-16'),
('5449db2a-73d8-45d3-b555-774e789374d0', '5d8f91d2-881d-46c9-9d1f-19d33516897f', '600013816243877587', 'credit', '2025-04-22'),
('5324a2af-f332-4d42-9581-3e9212ce902b', 'c8a710b1-6302-4189-8149-da76be7fdfc1', '5427163849475421', 'debit', '2024-11-27'),
('bd802465-1ceb-4a78-b614-3665f9e43f5d', 'a448f319-9dc4-4c02-b016-e1eab2b49629', '4756229042584', 'debit', '2024-06-05'),
('fa5f5af7-93fc-4fcf-b579-556f21c23c42', '4aab87c4-eb74-4e4e-ab8f-c13638276de1', '4413265879297', 'credit', '2024-04-30'),
('14db8f87-67bb-4a67-b0cb-9bcd7209960e', '441aa9d2-bdf2-4b65-a79f-c18e66de0e17', '372763304326682', 'debit', '2025-02-10'),
('2d50984d-8c80-4d31-b838-3ef6ed47059b', 'f75c87e7-70a8-4fbd-8ad6-9d5e9cefc314', '346265634959371', 'credit', '2025-01-12'),
('5f9a6528-b435-4625-8878-f0244607c005', 'c49c54f1-1926-4cbb-b3f2-2299152dce3a', '5476348265610219', 'debit', '2024-12-07'),
('79dc06b0-9924-4c42-b4ad-3731104a2ea5', 'ce49f4c7-302b-4d63-b068-8f01fd6e28a7', '375505919407603', 'credit', '2024-05-30'),
('6dd443f6-76fd-4ebc-a158-ea8ffa06c695', 'b2b1797e-b848-4af5-8a52-2e4d66a5af90', '610409547084913527', 'debit', '2025-01-02'),
('f24ceacf-1ff4-46c1-a0b2-dcf676ce244b', '92ffabae-dab4-4737-8b26-ee60ed598cea', '5208907834449147', 'credit', '2025-03-29'),
('70d99330-4658-4e5a-8272-8cdc0f81df48', '748ace76-6b8a-4fd4-9de1-b6154ce22189', '5455430022628083', 'debit', '2025-04-08'),
('5cae8bc9-2cba-49df-82f8-6c9851d3f00f', '80c28cdf-f2fb-4232-bbd5-39404d8199c2', '603198736992399776', 'credit', '2024-09-20'),
('17e2d5a8-5b0f-4bc5-88f1-a27a16345066', 'a6d46634-1645-4107-8594-983d4a4c90ce', '4112003708395083', 'debit', '2024-06-03'),
('04e5672b-6b20-4cb4-85c9-93a7f2ed7d28', '72acc609-0cc6-4fcd-bad7-5d7e6c58ae3d', '341081612406547', 'credit', '2025-01-23'),
('e4390634-3a87-46dd-94d2-30072526877c', '1118a259-aa7d-402b-9f1f-72555ed15180', '374649129046768', 'debit', '2024-05-07'),
('d1b0328a-df83-4591-a80a-b738fc7c3942', 'c098f0dd-6434-4f69-afdd-d756849fe1fd', '607850051406805644', 'credit', '2024-05-16'),
('def643b2-3d6a-4537-82d5-e7f1c55a3928', '9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7', '603148603529228244', 'debit', '2025-01-09'),
('5b856b8c-79b3-4c62-8657-c2a20512c2e7', '45ff6d75-3e4b-43ab-9343-ba2e0de1069a', '609841610428309592', 'credit', '2025-02-05'),
('af8a43bb-6cde-4a84-b1b3-f02e4b60c802', '789de9f0-5ef0-46cc-bb19-fbe4928474e6', '4892922136696182', 'debit', '2025-04-05'),
('8be0670c-ce06-4913-a20f-1b6fc0c6b838', '73b13073-025d-45c9-bed2-6b6760e7e10d', '611240813877102178', 'credit', '2025-04-26'),
('50d93376-a313-40dd-af52-91842a96f8b8', '34e9be76-4674-4d0f-b7c0-a39e43548747', '375638079726753', 'credit', '2025-04-23'),
('4d86e2b7-7f8d-4d4a-9622-84d695073a1c', '4d499ecc-5bee-4104-a1b0-32ceff979305', '612903224143401111', 'debit', '2024-07-29'),
('d1694652-37d3-429b-860b-6cef77a4085a', 'e0c672fd-8182-42b1-8a70-2138f223c47c', '617944472523412766', 'debit', '2024-12-27'),
('8292fe26-3515-46b7-8be0-bd355acd5af2', '15b082e5-92e7-4375-a7d9-f7224d35ba13', '379063365347635', 'credit', '2024-12-04'),
('7a134652-1491-4fbd-adee-4500a2b57bfa', 'd7461fd9-005f-47c5-aed6-98c6b03f378b', '616851652320789903', 'debit', '2025-04-08'),
('913da6c2-3a88-4a9e-810b-2fb3810563d7', '4adb1b7b-163e-4a1b-956f-9a3fa65d8b70', '4609562070650672', 'credit', '2024-07-21'),
('476c59b3-64b7-422e-a9fc-5e216a77160f', 'd094e634-9744-478d-b73b-1a73149b198b', '610998337426400244', 'debit', '2024-12-31'),
('fd43dd7e-fb80-4eff-9018-2feefab10d55', 'eae2bb46-3bd9-4bd6-a6b7-1b2efdc1911a', '348046611982764', 'credit', '2025-02-10'),
('39985b54-0c1d-482a-8c27-dbc0c930ca4f', 'd6a1328a-055b-40f3-9c71-da27fec396d2', '4680988449029284', 'credit', '2024-05-03'),
('4d6e3545-7a8d-4853-acad-57995e2e9a05', 'f9341b55-2686-40af-9e1b-2986672efd92', '4710923681866741', 'debit', '2024-05-12'),
('bc790da8-8344-45d8-81e0-cec855f426df', '1d97bce1-5c94-49e4-8e2a-6ad56b99afb0', '613800975980634856', 'credit', '2024-05-04'),
('76d7dd79-f2a1-4285-9048-5bddcf8c51b7', '2b4fc68b-f926-4889-910b-634ad923efea', '4955583745547', 'debit', '2024-10-17'),
('88e41144-3082-457c-8370-ba5f7199af70', '8d8d1450-995a-4db8-84d1-47779bd7d233', '348216935143384', 'debit', '2024-09-07'),
('f36a20ae-e574-452a-94b4-528c5cfc4eb9', 'ca19992d-7bc5-4903-8fba-699825411b95', '4458294071407850', 'credit', '2024-08-23'),
('24c2254c-8569-474f-bdb6-f2238c7cf4a3', 'bff8f8bd-3931-4f3f-b0c1-636597f97db5', '5490977694077285', 'credit', '2024-10-25'),
('425afc90-2fcc-4040-bbaf-db4ea5176a5f', 'fe716f26-3b0e-4fe5-bc40-4663f4fa66c0', '602569807950146963', 'debit', '2024-09-14'),
('3d32a92a-c899-42b1-9567-39b4ace56c31', '916673e7-fd52-47ed-bece-efb700890f1f', '4179411186310500', 'debit', '2025-02-11'),
('147d1847-cb22-4b98-ba2c-fb47249ffaaf', '2fdf706a-7187-470c-a1c3-f3e747b72f20', '602147091328309303', 'credit', '2025-01-28'),
('6b80bef7-3696-44af-85c4-3e3b7de915d6', '0937445f-d5eb-4ef9-887f-4173fe662dd4', '611096215899557980', 'debit', '2025-03-02'),
('abb4682b-2180-48fc-9e7f-d554ba19fb96', '54c49a0b-5dc6-46f8-abf2-ed2d1e56da8c', '5220054254149545', 'credit', '2024-06-09'),
('1450f131-4b66-45ac-a676-580b9a9d7dba', '48eef121-050c-4362-b2b1-96a32f5fe6a9', '5265655805574571', 'debit', '2024-05-25'),
('5955a1b7-52d2-49be-b344-1b9faaf24c1a', '14f24b1b-6e86-4cb3-bbc4-0293bc90f756', '610055020487163113', 'credit', '2024-11-28'),
('9b279402-7912-40a7-8d7d-34d4bb9290ad', 'be1f9370-375a-4d20-bf0d-284e833ff113', '373584511303960', 'debit', '2024-11-17'),
('da687eb9-0534-45db-a0a6-ad3c3b382aba', '318c43bf-9511-4030-bd13-81a47a4b8cac', '341077032205020', 'credit', '2025-01-24');

INSERT INTO "transaction_types" ("transaction_type_id", "name") VALUES
(1, 'Deposit'),
(2, 'Transfer'),
(3, 'Withdrawal');

INSERT INTO "transactions" ("transaction_id", "account_id", "transaction_type_id", "amount", "transaction_date", "description", "reference_account") VALUES
('049519be-3725-44ee-bf7e-f71ea192625e', 'f9341b55-2686-40af-9e1b-2986672efd92', '1', '89.76', '2025-02-06 03:42:17', 'Beateque vivendo a Platone disputata sunt haec', 'd4f9b85e-4f3f-446a-a556-5d4a4ed5a665'),
('c13f3200-d883-4db0-bb95-015570c879ce', '6d17ee21-72d5-4fb5-a638-ef220307dcd9', '2', '110.60', '2024-07-09 17:14:18', 'Modo docui cognitionis regula et iudicio ab eadem ', '75b2ae36-7349-429e-9fc8-24769001b67f'),
('f49e2d66-5fcc-45fb-ac4c-6c51b826f78d', '905660c8-d6a7-40e9-9be3-e6711d22efb6', '3', '118.44', '2025-03-21 05:47:34', 'Affectus et firmitatem animi nec mortem nec dolore', 'cbbddf5e-529c-4f85-a28f-240f2538e4ab'),
('cd0f3ec1-1c71-4e5e-b46c-f6b646bbe584', 'c4dd8020-5b57-4739-9d49-0f7172ffaf3f', '2', '115.31', '2025-01-10 12:45:04', 'Spe pariendarum voluptatum seiungi non potest Atqu', 'bcb2d47b-6700-4d5f-a306-b19221a31fbf'),
('f8bbc3ae-793a-4592-949c-20934594b7e1', 'a2ab1bd6-0020-4555-ba43-5c1f69332851', '3', '92.48', '2024-09-03 03:03:12', 'Est non expeteretur si nihil tale metuamus Iam ill', '4bf5e5e2-cd9d-4927-9b82-473bba7e1191'),
('c4623a1d-1edd-48af-b31d-420c2d6204a8', '916673e7-fd52-47ed-bece-efb700890f1f', '1', '78.95', '2024-11-02 14:01:39', 'Homero Ennius Afranius a Menandro solet Nec vero u', '02955846-2a35-4fb9-b0ed-ec3a793dd4da'),
('241b055f-5955-4fb1-9ed8-ce96860e941a', '8d7d7e4b-11a9-47e3-bca0-8f3aa0bada73', '1', '103.46', '2024-11-03 08:57:00', 'Quae quasi saxum Tantalo semper impendet tum super', '27959c77-5568-4495-935a-5be18c6e46cb'),
('a18aac72-4877-42a2-a6d7-5a82d063758d', 'b28eca06-abd3-43b5-b602-37bca09a6116', '2', '102.54', '2024-08-25 11:46:18', 'Tranquillat animos', '3ddf6b1f-0792-47fb-87b8-b3f21611dd73'),
('25b8e31e-a320-4a32-b2a5-08920b77f3ad', '4adb1b7b-163e-4a1b-956f-9a3fa65d8b70', '3', '87.81', '2024-08-09 23:13:21', 'Animo', 'e0972767-3ae3-41ee-b8e5-cf3e42f852e2'),
('ed1ffc6b-26b2-47a3-8fbc-f51ff7c37459', 'a6d46634-1645-4107-8594-983d4a4c90ce', '1', '98.37', '2025-03-07 12:53:57', 'Molestiae gaudemus omne autem id quo gaudemus volu', '0006ebfb-b2ce-4acc-b511-4dbf14d92c1f'),
('9d76822f-4714-4d47-86c7-4b5041dcc239', '8c46fae1-9789-4427-8440-7cf48a0272cd', '2', '120.54', '2025-03-31 17:45:05', 'Posse iucunde vivi nisi sapienter honeste iusteque', '85911484-8995-448b-8bc3-16443c5264b8'),
('a793a091-aa5f-41a6-b817-ee7b776ff995', '4d499ecc-5bee-4104-a1b0-32ceff979305', '3', '104.44', '2024-05-23 21:53:17', 'Consectetur adipisci velit sed quia non numquam ei', '2119aead-e31b-439d-ab73-845beeda0093'),
('dc1bb493-0915-458c-90d9-ecff268fdda3', '11d9d6f7-35d3-4ba3-bcca-a6b1e8f68519', '3', '106.92', '2024-11-05 16:47:24', 'Quam interrogare aut interrogari Ut placet inquam ', '11113f52-2f36-4336-ab6e-c4104e169f74'),
('6cf419fa-5d63-418a-83b7-346df8331ca6', '80c28cdf-f2fb-4232-bbd5-39404d8199c2', '1', '110.56', '2024-07-23 22:00:22', 'Quamquam autem et praeterita grate meminit et prae', 'ee35ec4b-7f2e-43d5-b132-9569ad5632ae'),
('97133932-d8e3-4f5d-9151-0fd5d52caa1a', '4aab87c4-eb74-4e4e-ab8f-c13638276de1', '2', '75.47', '2025-02-15 20:13:20', 'Pecuniae studuisse aut imperiis aut opibus aut glo', '2d7ea096-ab93-48fb-a30a-6be3963e2944'),
('92cf1981-8c89-452a-8112-7759fe8e895e', '70b25eda-9b65-489a-b3b5-1b7650795fbd', '3', '86.25', '2024-05-04 11:48:29', 'In nobis ut et adversa quasi perpetua oblivione ob', '8935d817-99dc-440a-9ef0-27b13711c02d'),
('423a25c8-aeb3-4823-95be-99f6a213d9bc', '418fedb1-da8f-4c67-8073-4a147e2f5ded', '1', '111.13', '2024-05-23 13:36:37', 'Dicant foedus esse quoddam sapientium ut ne minus ', 'ff7ba42c-7781-46f1-a0bb-006afaf25a82'),
('9a14b28f-e0ae-413f-bda7-1aaca6d8ede2', '2156bbb2-c082-45e5-a5d6-f66752c37690', '2', '79.94', '2024-10-15 11:45:09', 'Philosophis compluribus permulta dicantur cur nec ', '2442976d-bf76-4e22-a2ec-35019a21dd01'),
('9050e88e-0079-43f1-9b81-e032727d8307', 'be1f9370-375a-4d20-bf0d-284e833ff113', '1', '116.13', '2024-05-23 18:12:34', 'Sabinum municipem Ponti Tritani centurionum praecl', '5d7d9e57-7ada-49fb-ab21-d3215031f2d0'),
('583ebd92-6330-47e2-9115-c590b51238c9', '92ffabae-dab4-4737-8b26-ee60ed598cea', '2', '81.82', '2025-03-08 05:03:38', 'Obruamus et secunda iucunde', 'c3168283-82ab-469d-86d1-e063d2269091'),
('e12db48f-44aa-4560-a297-e9149f868616', 'c044b4de-6caf-4d33-91d3-50c621e194b0', '3', '96.51', '2024-09-03 20:50:20', 'Praeclaram beate vivendi et apertam et simplicem e', '4cc784c2-f1f8-4964-b968-0c7488738bd7'),
('54efc385-e6b7-4ce4-9be8-f2cc29398d38', 'bff8f8bd-3931-4f3f-b0c1-636597f97db5', '2', '118.34', '2025-01-22 11:55:29', 'Iustitiam quidem recte quis dixerit per se ipsa al', '2e0108f3-3f11-43ae-8a27-2d9f558a64de'),
('8d8b7260-6fb6-427e-89df-b6ec53ab0eb8', 'bc45041a-05a7-4c9e-a2c0-324829aaca62', '3', '87.23', '2024-05-12 05:03:34', 'In amicitia et amicitia cum voluptate vivatur Quon', '7cd31994-73e0-44b6-acc3-455185580d97'),
('4c67ca98-65ab-486d-a48a-1dadd2bc365b', '96da7988-0695-4780-a7c3-6c935daccc59', '1', '121.47', '2025-01-03 07:55:40', 'Se nobis ducem praebeat ad voluptatem', '5ce44576-c210-452e-a365-d73b316f16c5'),
('1d7d4fab-9ae3-47a5-a276-c85e413e7791', '40ede99d-89ee-49c9-b1f9-de9b0e61ff33', '3', '112.80', '2024-09-27 00:38:09', 'Se oratio tua praesertim qui studiose antiqua pers', 'afa23ea5-304f-4610-872b-a62bc0c8dd0c'),
('415591cc-b2b2-412a-8798-20b0269bfb20', 'd6a1328a-055b-40f3-9c71-da27fec396d2', '1', '122.17', '2024-06-19 14:28:05', 'Contemnit qua qui utuntur benivolentiam sibi conci', 'a1ee34c9-df2a-4b19-b04f-2e0dc65cf59d'),
('1bc0bec8-97de-4720-8278-a18d7538c308', 'a448f319-9dc4-4c02-b016-e1eab2b49629', '2', '91.54', '2024-08-16 04:51:30', 'Bonorum quod omnium philosophorum sententia tale d', '087b2392-fb5b-45e5-af4a-f83cc4b0c7f5'),
('daf27919-e34c-45cc-bd77-3201733aa2c6', '15c1de08-94a5-482d-9db5-682a1581ed84', '1', '124.13', '2024-07-11 13:05:13', 'Quam ob rem tandem inquit non satisfacit Te enim i', '65c4183f-555b-47f3-a5a7-3e8a41ea3c89'),
('01e6c965-00a0-41c8-8fc6-320a25e171e2', 'f75c87e7-70a8-4fbd-8ad6-9d5e9cefc314', '2', '112.54', '2025-01-21 12:01:19', 'Integris testibus si infantes pueri mutae etiam be', 'cc09553d-5115-4aaf-a38e-e18274ea3f1a'),
('9143af85-5ffc-4704-bab4-61e9817ee2cc', '14f24b1b-6e86-4cb3-bbc4-0293bc90f756', '3', '115.39', '2024-07-17 08:38:39', 'Aut venandi consuetudine adamare solemus quanto id', 'ece0c0c4-66a9-4fcc-b2b0-f07d3414dbf4'),
('f27b482c-cc6c-4e97-a535-297a76cbb76b', '72acc609-0cc6-4fcd-bad7-5d7e6c58ae3d', '2', '103.42', '2024-07-13 03:41:49', 'Liberatione et vacuitate omnis molestiae gaudemus ', '1c8246cb-95fa-427a-b013-5a5abd1fe800'),
('693b5625-5527-43c2-9645-0e172faea12f', '34e9be76-4674-4d0f-b7c0-a39e43548747', '3', '77.12', '2025-01-26 00:17:49', 'Ipsa quae qualisque sit ut tollatur error omnis im', 'f979d2d7-863e-448b-a0e8-3ea8d7bc7f9b'),
('e94ec941-e240-4fa9-8a6f-a1360c17669a', '5b98a4b0-ee51-4b17-9584-d5ae35ce9e6b', '1', '102.25', '2025-01-26 16:45:37', 'Ulla pars vacuitate doloris sine iucundo motu volu', '13ebdaaa-d7b3-4f7f-9db9-0a3fe4fe127f'),
('0db669d2-610c-44cd-b5fa-2e3f58051d09', 'c098f0dd-6434-4f69-afdd-d756849fe1fd', '1', '124.05', '2024-08-28 00:48:45', 'Praeterea neque praesenti nec', 'cf127e3a-a5b1-46fa-8b76-e631d2c37d84'),
('5b01a515-b320-4411-bc4d-03057bc38c7d', '17a9ed0a-5ed3-41d6-9e20-df434296c83d', '2', '79.90', '2025-03-10 08:51:11', 'Postea variari voluptas distinguique possit augeri', '19616385-58e1-4cc5-963f-b39316d7359f'),
('117e659a-c474-4cab-87a4-a5f902fc6453', '2fdf706a-7187-470c-a1c3-f3e747b72f20', '3', '110.02', '2024-09-17 22:54:11', 'Dolores eos qui ratione voluptatem sequi nesciunt ', '20b7e7f8-4bb9-4efa-b6bf-c25b7bd921e2'),
('ab0ac1a6-c84b-4606-ad92-00d7cae98ce7', 'dfd76a72-6dbc-4b94-a856-b77dd59d3b4a', '3', '93.45', '2024-05-31 16:49:27', 'Ea solum incommoda quae eveniunt', 'd4f72e06-e6ca-47ac-894f-613a57c18425'),
('4f6655d6-789d-477f-b61b-63acb94a1604', 'c8a710b1-6302-4189-8149-da76be7fdfc1', '1', '79.94', '2024-09-20 22:52:04', 'Sit numeranda nec in discordia dominorum domus quo', '67fb4789-9b28-4083-87e0-18f6fae076ef'),
('82353c8f-c4ec-4e51-97d5-60101464a8fe', '58e3e8fa-7549-4390-821e-d643a13d9c36', '2', '121.39', '2024-11-30 05:45:24', 'Loco videtur quibusdam stabilitas amicitiae vacill', '0ecdcaf6-5dff-43c3-a8d5-bf0a894cba68'),
('39ee7d32-a3ca-455c-9aa2-8e6fedde2f39', 'ce49f4c7-302b-4d63-b068-8f01fd6e28a7', '3', '99.29', '2024-11-08 01:15:22', 'Qua etiam carere possent sine dolore tum in dedeco', 'e4f2afd7-cd26-4325-a253-7aed34920158'),
('027c8cc4-d92d-46cd-8256-d46f395f3e0c', 'd29c5b3d-6bb3-4248-bf1a-4339bc80b6b0', '1', '112.34', '2024-07-18 13:04:35', 'Ficta pueriliter tum ne efficit quidem quod vult N', '5f1d7d6e-3ad5-4f94-a1de-ce3b56812ecb'),
('5ca3ef09-7b18-4782-a38a-9a621f898b19', '65b4514d-4bbb-4aed-b0e0-859e1bef135e', '2', '118.80', '2024-05-20 17:39:54', '-- Filium morte multavit ', '61b18b18-b899-44c7-9be3-d2b1817e7efe'),
('12d27a78-cec9-4eba-b6b2-691e9291d977', '45d4aa3e-cee4-431f-ac63-f83e4c56e862', '3', '120.66', '2025-02-16 15:16:49', 'Frustra se aut pecuniae studuisse aut imperiis aut', 'e837a350-66bc-4169-91b3-687ffc3e150e'),
('f60e2ff4-d09d-4749-adbf-d2825617050e', '8d8d1450-995a-4db8-84d1-47779bd7d233', '1', '109.79', '2024-07-26 01:53:46', 'Videntur leviora veniamus Quid tibi Torquate quid ', '531a4dbf-c165-4257-b302-186047ebb2b7'),
('a8852322-eff1-4275-beb9-4c503043ddc0', '71de6c84-d689-4792-b730-7711deb2a408', '2', '77.20', '2025-01-30 23:15:26', 'Gaudemus omne autem id quo gaudemus voluptas est u', '9007e6e5-a0fa-4273-b4dc-06bfa4f39a59'),
('189574d3-bf80-449b-a8e6-e0ef42d0a096', '3f494e04-a406-4692-a584-19db622e48ac', '2', '123.90', '2025-03-13 07:48:13', 'Id ne ferae quidem faciunt ut ita dicam et ad corp', '5f8fc16e-575b-435f-a853-fbf612d584f5'),
('a71ab662-caf1-43a6-ad8e-77831fcc73d4', '4fae08d1-3301-4031-a7d5-1b6eac9a2bdd', '3', '86.12', '2024-10-05 22:33:31', 'Maxime hoc placeat moderatius tamen id volunt fier', 'e64868fa-d343-44c8-a2db-b67719b44f2f'),
('87d27da1-f363-47d2-a2f6-f30b097e8c39', '39e495d4-8be7-45fa-aab6-1ee6312cdd04', '1', '102.76', '2024-10-18 05:39:14', 'Vacillare tuentur tamen eum locum seque facile ut ', '6e4651ce-80b6-47cb-af45-9c5cee6d7d61'),
('82aeeaef-d879-49bf-8e37-8f41702623f5', '1d97bce1-5c94-49e4-8e2a-6ad56b99afb0', '1', '88.98', '2025-02-04 05:18:22', 'Sibi quibus non solum praesentibus fruuntur sed et', '6706a806-b50d-41a8-865d-c2c300ff6bb6'),
('9aad011b-96d4-497c-85f8-2f26c14e897a', '309d1066-7bcf-4772-9c5f-16aff605512e', '2', '111.11', '2025-03-27 18:45:28', 'Nostris et scribentur fortasse plura si vita suppe', '7a59fe64-0754-4e58-9886-47abb0bde9bb'),
('af0f7112-c35c-4147-8180-b1b02cb87866', 'ca19992d-7bc5-4903-8fba-699825411b95', '3', '87.40', '2024-12-04 20:52:34', 'Omnia dixi hausta e fonte naturae si tota oratio n', 'd1affaf8-ae93-4465-b104-01d53600abfd'),
('df4db5e5-0987-48df-b954-6ba77c7bdf7e', '07a36a4b-7943-4634-b17a-7c7eb4407cd3', '1', '79.10', '2024-08-11 19:46:41', 'Quae dicat ille bene noris Nisi mihi Phaedrum inqu', '61a21200-7eb2-4c47-98be-218963f7e2b0'),
('c15c756d-4ab5-4a51-be2a-771cb9ed484c', 'def2f626-6db4-4fea-baa2-33fafd90c494', '2', '95.81', '2024-06-19 02:42:30', 'Corporis suscipit laboriosam nisi ut', 'f4050449-bb58-4be6-9255-2ccae85c58cf'),
('9213c9fb-b67b-447d-a6ab-a078c6f0aa9b', 'b2b1797e-b848-4af5-8a52-2e4d66a5af90', '3', '117.92', '2024-06-11 12:04:03', 'Non satisfacit Te enim iudicem aequum puto modo qu', 'a560b9df-14e8-4084-86c8-34d12b25e2f6'),
('541f3e47-8c96-48d0-a61c-32e238e3ab14', '318c43bf-9511-4030-bd13-81a47a4b8cac', '3', '79.45', '2024-06-20 18:02:31', 'Nihil nisi praesens et quod quaeritur saepe cur ta', '1f60f3f4-81b4-4f88-9f8e-e352e30351e9'),
('3322a905-6f9a-4460-8c68-d8ce45feffaa', '748ace76-6b8a-4fd4-9de1-b6154ce22189', '1', '102.26', '2024-09-21 08:52:41', 'Everti si ita melius sit migrare de vita His rebus', 'bfcdfa32-ada0-441d-9f8b-2d6ab5e734e8'),
('bf2385e5-d757-4532-a3f2-c8d15bb82ea5', 'd7461fd9-005f-47c5-aed6-98c6b03f378b', '2', '116.38', '2024-07-09 23:39:01', 'Sic sapientia quae ars vivendi putanda est non sat', '19c47ae2-870c-4a0b-9719-55f1a60afa11'),
('67648c15-25f2-4bb7-b7ed-9fb60f3b2d08', '89a22c8c-57ba-4baa-8b71-13d1210a62d6', '3', '110.92', '2024-12-25 22:44:11', 'Quod semel admissum coerceri reprimique non potest', '3b525f55-42f1-400a-aeea-8d4422f096ca'),
('2b3b1663-f993-4e82-9dbe-7a7779e4648d', 'fe716f26-3b0e-4fe5-bc40-4663f4fa66c0', '1', '124.22', '2024-12-29 22:49:39', 'Intemperantes et ignavi numquam in sententia perma', '35bbf3a5-ded6-43a5-9b5f-9f8436523d04'),
('dd3d47a9-307b-47d3-b3df-dfd5b10a2935', '85202b58-ec17-4407-ae0b-fab4ae861dac', '2', '112.49', '2024-11-29 17:48:29', 'Vivere Huic certae stabilique', 'ce4426ed-ffe6-44f4-9813-389af517fde6'),
('fb75bb86-0809-475d-831c-d565d459156f', '80d384e7-9b48-4806-9897-32969e337683', '1', '94.92', '2024-12-30 19:52:31', 'Nam si ea sola voluptas esset quae quasi delapsa d', '3361416a-7e3b-4e5a-a706-2be8f738f7c0'),
('0e5ccf7d-0803-476b-8405-23e0b5091c08', 'd094e634-9744-478d-b73b-1a73149b198b', '2', '98.25', '2024-06-29 15:41:58', 'Fidem sensibus confirmat id est in eo quod semel a', 'a182d57c-fddd-4641-a408-edd65f79779a'),
('14d252e4-30ea-473f-87cd-16d00e4e7415', '1afc36b6-ae72-48ff-9d51-5f57fac653bc', '3', '121.22', '2025-03-25 15:05:42', 'Qua intellegebat contineri suam Atque haec ratio l', 'd494f351-9ecd-4c50-a7b0-57586ba55764'),
('cb903db5-4abc-4f1e-be63-28942a0b60bf', '5ea6c838-111c-484c-9b2b-bc4b5776f48f', '1', '119.04', '2024-09-18 14:52:43', 'Summumque malum dolorem idque instituit docere sic', '9ff24df3-7da5-4ec0-b6e8-4b42275b274b'),
('eefcf327-64d3-4df3-a0da-cbb3f90e0948', '2229fe26-cc7f-4a58-9caf-d79a7f45b93e', '2', '75.13', '2025-03-08 22:17:42', 'Bonas verbis electis graviter ornateque dictas qui', '27717e90-c655-41f9-a582-a77995272816'),
('1229a502-c09e-478b-9939-4f7599344d37', 'eae2bb46-3bd9-4bd6-a6b7-1b2efdc1911a', '3', '111.00', '2025-02-11 21:11:29', 'Spe proposita fore levius aliquando nulla praetere', '1679f7d5-3d24-45eb-a146-72c35e80dbe3'),
('7c819ea2-da8d-4590-932e-de0037e89802', '1118a259-aa7d-402b-9f1f-72555ed15180', '2', '93.12', '2024-12-01 20:04:29', 'Nos amice et benivole collegisti nec me tamen laud', '417af136-8813-4376-8d0f-5ece425cc14b'),
('9ac8ef96-6df7-43c6-8438-af7b90bb2fef', 'c49c54f1-1926-4cbb-b3f2-2299152dce3a', '3', '124.08', '2024-12-10 04:51:59', 'Certe non probes eum quem ego arbitror unum vidiss', '16c6d4bc-4442-4e86-bd7c-45fc422cbccd'),
('96b3156b-f834-486c-86df-76dd333a9e8c', '980c1a90-3d66-4010-81c8-32cde239d423', '1', '107.24', '2024-09-12 05:37:52', 'Se aut pecuniae studuisse aut imperiis aut opibus ', '3d545419-d78a-40b0-b8cc-7f660ef0f704'),
('730f46e7-0a12-4bae-a34d-2c1893ece2ce', 'bf4afaa6-c52c-4b4e-b7f8-543eeb1ec49c', '2', '109.34', '2024-10-20 04:34:34', 'Quis dixerit per se laetitiam id est', '6ef7ff16-8d96-4f2d-8bae-3c604887a952'),
('80e62bc1-cb02-4c9d-bada-9dd4aa0cae3f', 'c50f01a9-441b-4a71-81c8-9f2a78288a92', '3', '104.78', '2024-08-05 16:26:55', 'Repudiandae sint et molestiae non recusandae Itaqu', 'b6bba53f-da2c-4770-bb3b-ed63c51bf5bf'),
('8c805bd7-7ed0-4af0-818c-459cebd8fd7d', '45ff6d75-3e4b-43ab-9343-ba2e0de1069a', '1', '100.01', '2024-08-11 04:00:55', 'Eiusmod tempor incididunt ut labore et dolore disp', 'e83102f4-5e21-4e3f-a63f-ea68495774e1'),
('2bc5a3aa-b92a-4384-a83d-e6f6c8ba182a', '54c49a0b-5dc6-46f8-abf2-ed2d1e56da8c', '3', '120.37', '2024-07-17 02:33:59', 'Celeritas diuturnitatem allevatio consoletur Ad ea', '88689d1f-ceda-4e0d-b601-915af09fb32a'),
('f0de775e-d24a-4ede-b55f-4c1e2ca9783c', '8a54f7b6-3ac0-4aee-88c4-ff386444e673', '1', '106.17', '2024-10-24 14:41:22', 'Desiderat'' -- Nihil sane -- ''At si voluptas esset ', 'ad893890-12be-4839-a5fe-ab88703d12c0'),
('6d77ba74-b395-42c0-8e1a-0678bc4ca127', 'a9eb22fe-d2a1-4f58-b903-ba06bfab92c4', '2', '79.35', '2024-10-30 13:18:45', 'Magna aliqua Ut enim ad minima veniam quis nostrud', 'e8e3ea02-5cf0-42ee-9184-3aa9ceb2d57b'),
('adfa8723-3735-4ff2-8428-90bdd84413c7', '7b1fccd6-d4ab-4f58-9ae1-b45947264b33', '3', '104.21', '2024-10-06 11:15:58', 'Ut concursionibus inter se reprehensiones non sunt', '22688731-1c74-40c6-a32d-b1fc7826b0ad'),
('8bbc7aa9-8321-4adc-bb71-c2a088cf766d', '535ff8ea-7b01-48a3-93a3-27288067830c', '1', '122.97', '2024-09-03 00:44:10', 'Investigandi veri nisi inveneris et quaerendi defa', '142cd0fb-96d2-4014-9c1c-4a468ac3d1db'),
('0096cba5-4e9c-49f4-b1df-4955a76275e4', '802b2efe-e1d1-465b-940f-5cf573a2c985', '2', '80.72', '2024-10-17 00:06:59', 'Potest fieri quanta ad augendas cum conscientia fa', 'a44e4ac1-bb08-4acb-b880-2187f4402636'),
('488f3a0c-a01c-4e6d-a46a-c9d4b04620f0', '441aa9d2-bdf2-4b65-a79f-c18e66de0e17', '2', '116.77', '2024-06-19 00:28:51', 'Latinam linguam non modo quid nobis probaretur sed', '1c00ecb4-95e5-4f08-b22a-4d52cb5e8f97'),
('82f54048-1086-4a91-b397-22a982e13fc2', 'ed508747-a9a1-432c-980f-388a4be8398d', '3', '115.56', '2025-04-10 01:52:55', 'Quodsi qui satis sibi contra hominum conscientiam ', '6497ea37-1f6d-4d19-bf8b-8f0ff63bba73'),
('063e014a-839b-4ed2-b3a3-510e528f961c', '0937445f-d5eb-4ef9-887f-4173fe662dd4', '1', '122.10', '2025-03-05 00:22:17', 'Et quidem locis pluribus', '3a4c6626-3ec2-4f94-b2f5-d8d2febe79d5'),
('97eec2d8-5c98-4962-b94b-0687e120668c', '68c0a815-9332-4453-8a91-5ce066bb07e2', '3', '94.46', '2024-10-06 15:44:25', 'Praeterea et appetendi et refugiendi et omnino rer', 'b9dbd5ee-1f02-42d2-9b40-56c07ea71ef5'),
('94e1cb50-85ae-4534-b217-f5f8b4c768c7', '3a6e7b4a-c8db-4750-bbbc-a337ef92efe4', '1', '105.05', '2024-11-07 15:41:37', 'Desistunt', '5c7ea11e-0ae3-4bf2-848f-66e9f6326f28'),
('c9c9d00d-3179-4cf5-99de-49f412c3493b', '48eef121-050c-4362-b2b1-96a32f5fe6a9', '2', '77.68', '2024-08-22 00:37:33', 'Est vel summum bonorum vel ultimum vel extremum --', '8b23fb67-2574-4287-9895-193fc10ce853'),
('11baa8a7-a180-47b0-9fed-583129ee66a0', '15b082e5-92e7-4375-a7d9-f7224d35ba13', '3', '101.20', '2024-06-28 01:14:58', 'Sit voluptatem accusantium doloremque laudantium t', 'd5d0aabf-62b8-416f-88dc-3546b47a13de'),
('2a9f2378-3ac8-4eb3-b801-5656cd2bf91f', '36f3d280-2886-4e51-adcd-dfc644e59d80', '1', '119.26', '2024-12-08 18:06:48', 'Loco videtur quibusdam stabilitas amicitiae vacill', '4dff6f9d-e568-4c6d-980d-ceb6e56a85c0'),
('50c0a6f3-faba-4031-bb3b-e30a1bab1c5c', 'da3b43bc-55d1-4f0b-80d1-494ccfc9acc5', '2', '102.44', '2025-03-22 10:19:47', 'Cum ita esset affecta secundum non recte si volupt', 'a0db7350-8578-44bb-b266-1d89b605b775'),
('3f30d441-419d-4b4c-ae6a-8528cba6862c', '5d8f91d2-881d-46c9-9d1f-19d33516897f', '2', '112.03', '2025-01-17 11:08:16', 'Doloribus quanti in hominem maximi cadere possunt ', '2538c2de-8c95-4a79-9dc2-93473474cbe8'),
('21b5a0dc-c54e-47f7-b465-0e4ab4797405', 'e0c672fd-8182-42b1-8a70-2138f223c47c', '3', '114.17', '2024-09-20 20:20:26', 'Quo voluptas nulla pariatur At vero eos et accusam', 'dbd9bc1c-90b0-44b7-b612-b16d0e1f96f7'),
('06ae34b6-1723-4b44-baf9-a885f489f723', '71c0f7ab-b701-45f0-9c94-802383b3cc36', '1', '87.25', '2025-01-09 09:05:38', 'Quales eius maiores fuissent et in conspectum suum', 'b60df67d-a99b-4d14-81d0-e81965562e94'),
('13706eb5-aabb-467b-86ca-b1c9999dc7dc', '57620a31-a1ee-4dbc-9a72-09bc5bb72b7d', '2', '96.05', '2024-11-23 23:08:47', 'Non offendit nam et laetamur amicorum laetitia', '59819d94-6695-46dd-9e31-e8c422118531'),
('7d332d97-04e9-4737-8676-7b78dc39c96a', '789de9f0-5ef0-46cc-bb19-fbe4928474e6', '3', '102.24', '2024-11-17 16:47:48', 'Ostendit iudicia rerum dirigentur numquam ullius o', '8a392a96-c559-469b-835e-4a45c4ba85b8'),
('dfdb6f48-5540-4835-8596-c6f67f168628', '9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7', '1', '88.26', '2024-07-06 00:24:11', 'Pro suis suscipit ut non modo fautrices fidelissim', '06cc31ae-ea13-4b47-b5f0-63ec92f90b29'),
('8d379ad0-9f64-4e6c-b197-b4aa107d8a47', '5ccb459e-6c87-432b-a742-c6c7cbf0dae3', '1', '113.36', '2024-12-02 05:14:20', 'Ipsius honestatis', 'bf39e43a-a169-4c7a-afc6-3762ce351037'),
('34608f20-08ad-42b2-8ac9-6a450b4788b9', 'c73f146f-aef6-415f-bc17-8bf06ba9819e', '2', '86.91', '2024-11-15 04:57:54', 'Nisi nescio quam illam umbram quod appellant hones', '23372490-5ed9-4bfa-82ab-d870d0d50ecf'),
('d7e72657-f5f8-46a4-afc2-d369a09bb80c', '2b4fc68b-f926-4889-910b-634ad923efea', '3', '87.82', '2024-04-27 16:34:29', 'Esse deterritum Quae cum dixisset Explicavi inquit', '871bbb2a-2528-4586-a1a6-e7ecd561e57e'),
('d5d6a84e-c67f-46e6-89ac-0e07504f7c08', '418a133e-5e1f-4377-8d48-63de24b5b08e', '2', '122.28', '2025-03-25 12:34:30', 'Mutae etiam bestiae paene loquuntur magistra ac du', '70e17e82-5d0a-4722-bee6-aa419ed1fef1'),
('04e45e65-b269-4c95-9362-74e17a8319bf', '6edc13ce-6ed2-48a7-b73d-ef6ed8b73e38', '3', '76.99', '2024-08-04 12:28:58', 'Accedis saluto ''chaere'' inquam ''Tite'' lictores tur', '4734b927-4bba-4591-a8fc-caf19a15faed'),
('1ddf4572-0fe2-4535-9314-e968921dd07d', '73b13073-025d-45c9-bed2-6b6760e7e10d', '1', '79.39', '2024-07-06 17:41:05', 'Solemus quanto id in hominum consuetudine facilius', '5f44fa2f-53f3-4121-980f-4d26800ea306'),
('2ae8fb1c-1844-4602-aa0a-5a13a6507874', 'ac35eddd-0fb1-4711-9bb8-1985fc566b52', '2', '79.15', '2024-06-24 10:22:24', 'Nisi te quoquo modo loqueretur intellegere', 'dd9daadd-3426-4ca4-a158-380e6485c6e5');

INSERT INTO "loans" ("loan_id", "customer_id", "loan_amount", "interest_rate", "loan_terms_months", "start_date", "end_date", "status") VALUES
('e89e4746-a369-4daa-bb68-2c395b052b81', '0bedb8d0-0c5a-48a9-bae1-5b1fbecf4a10', 49337.83, 13, 6, '2024-12-10', '2024-11-16', 'active'),
('c3b4c3b8-0511-481d-bf7f-5da93c8014df', '6b7b3dfa-9959-401f-9b8c-fce6948abc45', 47811.49, 15, 5, '2024-06-02', '2025-04-01', 'closed'),
('28d65366-4fa3-44eb-895d-9343fd626052', '37abd855-71e9-4ded-87fe-901c4ccb3d3c', 60259.49, 22, 4, '2024-10-14', '2025-02-02', 'defaulted'),
('845baeaa-ec87-463a-8e5e-7281c5c6082d', '623e0b78-6b7c-4e98-a46a-c96d1c607817', 57515.62, 1, 3, '2024-08-06', '2025-04-04', 'active'),
('fab66d90-8053-4709-bf4d-dfc18ddee625', '5b3fb023-fd43-4cae-8783-ef1c98d11b38', 49001.01, 13, 8, '2024-11-20', '2025-01-03', 'closed'),
('fdfae8c8-41a9-4eb8-88fd-8d23ed96c85e', '43776145-9002-47aa-a868-c0ca95951f5b', 44057.78, 24, 2, '2024-07-14', '2024-10-07', 'defaulted'),
('1d8a9786-f995-4e76-9e72-18956814ab04', '1b056bda-e6c8-46bb-a706-8db8c2e53061', 60627.80, 10, 6, '2024-08-10', '2024-11-02', 'defaulted'),
('96d114bf-ef1c-483c-b3b1-b05b81debe30', 'a9de1fc5-3ba9-4088-8ee6-5a75104f2c7d', 39573.93, 5, 8, '2024-10-31', '2024-12-20', 'active'),
('f92cf2be-1c0e-4a5c-80f2-34f69c051450', 'a424f2b5-0890-4fc1-a71e-9ea7547a5a25', 54974.14, 2, 10, '2024-05-14', '2025-03-25', 'closed'),
('7bb906f8-d2e0-44cd-a567-a153218e4ecf', '5d8912f2-8074-4f41-b002-e0c789e7f718', 45439.89, 23, 2, '2025-04-07', '2024-11-07', 'closed'),
('e88e3cad-b274-474b-96a0-fa7f9e5effa1', '6f6a46c1-26ae-47c8-82aa-34027c84af78', 43111.80, 3, 3, '2024-11-04', '2024-08-04', 'defaulted'),
('2b3f78ce-27bd-4317-a213-4eb0264d98a4', 'dc0f5f48-84ef-4f9b-bd05-ef9217f050fe', 55892.32, 15, 5, '2024-11-26', '2024-12-29', 'active'),
('540d065d-8c09-477f-a8a9-a24b67b37711', 'd46ba1b1-9ff9-42e1-b7ad-7138cee43bf2', 43210.72, 2, 7, '2024-10-26', '2025-01-18', 'closed'),
('17d17992-ebb5-42e4-9253-325e463e2f94', '29f948c1-0d27-4e13-9126-498a6e51a079', 43771.07, 3, 1, '2025-01-10', '2024-09-12', 'defaulted'),
('c3151876-a408-427e-bb81-4ff51ced5156', '5c41586b-f7bf-41fa-883a-7b9cb1c4c849', 53267.88, 14, 9, '2025-03-26', '2024-12-26', 'active'),
('b03c3409-5172-4dde-80a0-cc37cf999f56', 'b4a5aa8b-b1f2-478d-b60c-7efd3b198ee5', 51625.68, 22, 2, '2024-08-21', '2024-06-26', 'defaulted'),
('3353ed1e-9bab-4bc5-99e6-259dfb48c1de', 'ef998517-9d3b-429c-be1b-5b164ba2afe2', 54457.39, 2, 9, '2024-05-06', '2024-07-24', 'active'),
('e23f6da4-f038-48b0-9fe7-798662be1d4a', '50acac78-1c19-491e-8e95-2787664d9090', 45429.97, 6, 4, '2024-11-01', '2024-10-06', 'closed'),
('67604701-5bda-4cd8-be5e-53b5ef6050b7', 'ea53056c-33eb-49f9-b00d-71b8b74f5829', 42808.38, 14, 5, '2024-04-30', '2025-03-24', 'closed'),
('dc97911c-01e9-4034-8abb-61e497e97123', '3a57a285-56e7-4900-bc63-d044f2247ff1', 51620.33, 11, 11, '2024-08-25', '2024-10-12', 'defaulted'),
('2b3501ae-f9f2-484b-9503-6a103135898b', '1833e0d4-fd6c-4474-b416-3ce9e539b363', 57922.30, 21, 10, '2024-06-30', '2024-07-29', 'active'),
('b18802e8-45c0-496e-9311-cc74d19d64ca', '93718b0c-9337-4efa-bd48-51713fb1523c', 37898.70, 9, 10, '2024-09-01', '2024-07-10', 'closed'),
('81565b2e-2913-4553-a450-9af6b63e44fd', '14f35ff7-5574-4e12-ad89-7e7704a02e62', 62005.93, 20, 4, '2024-08-29', '2024-09-30', 'defaulted'),
('475f0739-0ae3-4697-bc84-f631e6f7c375', 'bb09df35-4fb6-42be-a106-f0f1f1a74012', 55128.96, 1, 3, '2025-01-21', '2024-06-12', 'active'),
('3d0f3146-c92e-4c37-80e8-f87cc134047c', 'f023ea3c-6500-4297-868e-abd3043b97c1', 55210.20, 20, 6, '2024-05-30', '2025-02-07', 'defaulted'),
('57e507a6-7ef9-4f63-b893-ce6deda96192', '3eec958e-8cd8-426e-8603-eac1c9b2c004', 42700.14, 23, 3, '2024-12-27', '2025-03-04', 'active'),
('205ce30d-eebe-45bd-b564-9edd917a3426', 'f832a165-6ce7-4d54-9cf4-2b58ad4b4cf5', 55209.06, 8, 2, '2024-12-19', '2025-01-09', 'closed'),
('fac5069a-d2f1-4613-b0e6-542fd42a941f', 'abd49d49-237d-4d28-b3ea-9d19661fcf9b', 56930.24, 8, 8, '2025-04-04', '2024-08-31', 'active'),
('b200a1fc-8010-426d-aa9c-ee6765979eae', '86f4ec23-7064-4bb5-9aaf-b8e98e8d95ec', 42420.67, 6, 2, '2024-11-21', '2025-04-01', 'closed'),
('69a28e51-b8f6-4235-9761-8708889c055d', '7f42152e-6a93-4d03-a9c9-ee0830c5096f', 39471.44, 5, 9, '2024-09-13', '2025-02-20', 'defaulted'),
('83f7b4ce-7bb9-4f0b-92ff-abae672eff07', '13aac759-5c49-42dc-9693-0f46cb1337bb', 57013.89, 2, 5, '2024-09-26', '2025-01-29', 'closed'),
('2c2af935-222d-4c58-aa20-6340033addcc', 'ed5f70a9-36e5-433b-abbc-fed08b27bb16', 48630.85, 10, 8, '2024-11-21', '2024-09-29', 'defaulted'),
('832582ec-dde3-42a8-8ef4-2c327e9bec70', 'd933fcc1-a91f-4051-9cc1-58e1bf6be236', 49489.72, 18, 8, '2025-04-14', '2025-03-28', 'active'),
('998bd488-1f59-4950-bd8c-02a5efcef5f9', 'a34887df-cb28-4cab-a2ab-0f7de63719b9', 42297.38, 22, 9, '2024-05-25', '2024-08-29', 'defaulted'),
('7a15a920-83d5-4aa4-a583-066e0c16fff1', '6e360958-11c9-41fc-a89f-4238b8a0ae24', 49434.10, 14, 6, '2025-02-01', '2025-03-11', 'active'),
('6c20ef5c-77ac-4611-841e-e88f9a7efbc3', 'f1082db9-8d80-4f63-9af8-db2ed4c41080', 44553.93, 7, 4, '2024-05-24', '2024-04-30', 'closed'),
('81f9f1e4-dcbe-436d-93d8-1e2735415e8d', '85916c42-22cb-4462-9fa2-9c45feea827e', 49040.35, 18, 3, '2024-05-05', '2024-04-29', 'active'),
('00d66b19-0e2f-4bb1-8f27-dc06280f283a', '287bf982-89ce-44b5-bfdd-49407600309a', 39958.46, 17, 5, '2025-04-27', '2024-05-19', 'closed'),
('1ad861bb-05cf-41e0-9c6b-4ddca09021f8', '719c88a7-ba09-4109-a4f8-ba659d01ebf6', 50677.26, 8, 5, '2025-04-16', '2024-12-10', 'defaulted'),
('26136eb1-aded-470d-baa4-15e607e5db06', 'ef255303-e28b-4229-aa6f-99eb4f67a81c', 56021.00, 22, 11, '2024-08-08', '2025-04-21', 'active'),
('c3c5f705-4968-433b-8ee6-5223d34db242', 'f40f3b32-6b03-4f88-896a-949bb777a247', 44959.63, 22, 8, '2024-12-04', '2024-07-18', 'closed'),
('b539f60d-b4f0-496d-8489-f0d2adefdfdb', 'f8628b73-c900-4973-849e-22aa8e42fc33', 47222.64, 23, 9, '2024-11-08', '2024-07-05', 'defaulted'),
('78e63c69-f0fa-4bac-87fb-82da72841780', 'a23ae674-314f-4a4b-845a-ae0ff78d3512', 57686.50, 6, 5, '2024-12-26', '2024-09-12', 'closed'),
('8c9c396c-7918-4e4f-b0a6-15a2b7315d7d', '585b6bfa-e33a-4e75-8d2e-5cf1e4a42197', 56792.76, 24, 1, '2024-07-30', '2024-04-29', 'defaulted'),
('ed24ba66-305a-437f-aa86-efb51bb39402', 'daf898aa-13cd-465a-b2ed-ce3605ff9cc2', 49946.08, 2, 2, '2024-12-22', '2024-12-03', 'active'),
('e4134aea-92ef-4bc2-b75d-73acd760fd18', 'a99c66ac-ae2a-4375-b15c-9b1694200e6d', 49258.79, 10, 6, '2024-09-09', '2024-07-05', 'active'),
('4f33fb1b-d9c8-4fe3-80c8-f0283541bcfa', '079cd6ce-04a8-4c55-8c2b-b93189e9050a', 38243.63, 16, 10, '2024-06-23', '2025-04-22', 'closed'),
('2424a4c1-6c58-4202-a1f0-b21226a05dad', '1ea5ec60-3f36-4896-af24-13ee03bf06d9', 43166.51, 10, 7, '2024-12-05', '2024-04-30', 'defaulted'),
('bf22a5f0-efd7-4b45-aa7b-f7dcc5820029', '9d78736f-df51-4622-9cb1-c4db88dca2d0', 52464.68, 19, 7, '2024-09-01', '2024-10-17', 'defaulted'),
('7b2fb1af-2e95-4fbb-82dc-4bc8b895198f', '43803350-bfb2-46b7-8949-24dc4b72fbf3', 43625.99, 2, 6, '2024-10-07', '2024-10-18', 'active'),
('59293892-28d5-4cf9-a08c-6b78d5eb6015', '7ab376ee-2fca-4f08-98aa-9b93cc0fc972', 60862.44, 15, 1, '2024-09-01', '2025-03-15', 'closed'),
('a1778f5e-d18c-4c98-a63e-49f4e56ee11f', 'fa5b05d5-cd6d-4e43-840d-4e368a1dac48', 61818.54, 13, 4, '2025-04-10', '2024-10-22', 'active'),
('7a1f9203-2b06-43c6-b126-c4be0af1654b', '79dcf8ce-329d-48a8-ac2c-9fa869b4ac42', 45512.95, 9, 9, '2024-08-07', '2024-12-16', 'closed'),
('861ce501-cb65-468b-81e8-5e80af214c9e', 'ba054855-8fa2-4f85-965a-6ba3b5fc13d3', 47956.68, 2, 10, '2024-10-23', '2024-07-30', 'defaulted'),
('4e87bf47-4f56-4b1b-8f20-6aac69315e62', '462d21d0-7672-428a-abf7-04c18a1efde8', 52802.73, 11, 8, '2024-08-09', '2025-02-25', 'closed'),
('f1750929-37d5-40f5-a9bd-6bd2c20aff8c', '6b612ed4-f731-4963-85f3-780a438e0fad', 40841.94, 4, 10, '2024-12-20', '2024-06-05', 'defaulted'),
('bd705e81-a813-4efd-b0b4-6f170a45a630', 'd01d990c-8cbd-4b0f-87b3-4c31fafbf3d5', 59122.45, 0, 2, '2024-07-15', '2024-10-24', 'active'),
('b4c184b2-9da1-41ff-96a5-de7f8c27f376', '7f18c59c-3e61-43f6-946f-d0b81fbd3cc7', 41749.75, 19, 8, '2024-10-26', '2024-09-20', 'closed'),
('cf7dc393-b7f1-4bb7-8178-d5336f3759af', '357e3969-87b3-48e9-bd0b-4a658de0dd38', 57046.44, 16, 7, '2024-12-01', '2024-05-17', 'defaulted'),
('aa1e5774-b153-4f7e-a325-b3c9f6918f34', 'e8a917b4-9641-4271-91a2-2a0ef3477c76', 54828.95, 12, 1, '2024-08-03', '2025-03-08', 'active'),
('2588b70b-d89b-4e4a-b4ac-b4eac55e9fe7', '26ae893b-6b51-41b9-9b07-a8d07e8a2979', 58610.63, 10, 7, '2024-04-28', '2025-04-01', 'closed'),
('15c936d8-9cfc-4671-903c-bd64c717a957', 'b980c9fc-c205-4042-81ef-17a613787208', 54893.77, 13, 4, '2024-07-04', '2024-05-30', 'defaulted'),
('62a82461-71e3-4172-8577-0aad1ca82be4', '33716558-b6fb-43ec-91a8-59207fe42376', 50394.51, 14, 11, '2024-12-23', '2024-12-23', 'active'),
('8b7a6cf4-e84a-44b5-9df3-a93efe7bc629', '6ca0328f-1be0-4205-9a57-59cef27a1067', 39558.32, 22, 2, '2025-01-20', '2025-02-10', 'defaulted'),
('185a419c-476d-450d-9f7d-ba89c22db819', '870ae237-d669-42dd-b283-99c1219bf349', 51288.19, 14, 5, '2024-05-03', '2024-06-09', 'active'),
('39b7d0f0-d0d7-4b79-b09b-34af80424868', '8e07d624-a56d-4734-a552-2b3985adedbd', 52649.61, 4, 4, '2024-05-23', '2024-06-22', 'closed'),
('6e903d6f-41f2-4464-99eb-be983b6a8f22', '4a150c66-0c2b-4626-8e66-4035a87c1ab0', 58004.83, 1, 3, '2024-08-12', '2024-05-18', 'defaulted'),
('aae20568-6f83-4d82-b88f-92d12e9aef78', '6daa0a7c-3ca5-4ace-9d6c-b119d9067a6a', 50183.96, 8, 2, '2024-07-25', '2024-07-04', 'active'),
('6e22338f-f27d-4d78-974c-e427d70d726e', '52d177ad-467a-400c-9f5e-a51bfffce616', 37898.81, 1, 10, '2024-08-12', '2024-11-08', 'closed'),
('208b5b89-cbc2-4e18-93f2-0fb6d837500a', '20b542e7-3b96-4059-b30a-6d09832e17de', 48265.03, 15, 7, '2024-10-16', '2025-02-08', 'closed'),
('5c5e6a1f-8cb2-4108-8b86-33fab6995240', '9f2f61c6-ee32-4494-85a3-2425d533a5b8', 44026.28, 20, 6, '2024-10-28', '2024-09-26', 'defaulted'),
('c6709969-de1b-4d20-972e-ee492ba2d639', '1f72084e-90f3-4334-9b8f-a3b350c2beb0', 50908.28, 5, 2, '2024-11-07', '2024-05-30', 'active'),
('c3cee2e0-f41e-4b74-a093-d2aaae9b9125', 'cd125a77-15a1-4c04-aaed-41a05195225b', 39437.29, 8, 5, '2025-02-24', '2024-12-23', 'closed'),
('e99783ae-b59e-48e8-826e-56fbd31b9a10', '61ac2df4-4e87-4f00-af98-a9c55edbdd80', 47256.40, 14, 6, '2025-04-16', '2024-07-01', 'defaulted'),
('5a3eed61-5aa9-4a49-ab64-8cbcc6b16e4f', 'e19d7be6-0155-4cb3-86ee-ba31a6ff5de1', 57490.46, 15, 2, '2024-05-14', '2025-02-01', 'active'),
('1a410579-e174-4b63-8813-39a9e135a1e9', 'c7a3c75f-3b79-4fdb-a4ab-52a54401b875', 42069.91, 5, 7, '2025-02-02', '2024-05-01', 'closed'),
('9224cfe9-efaf-42b9-9195-1e0fa8d0d530', '9253d6d7-b356-4e9e-8fa4-e60c1d0327cc', 39563.92, 9, 9, '2025-04-23', '2024-09-20', 'defaulted'),
('9648a2dc-58b8-4ad1-bb79-eb985d554cd7', 'ed4658f1-c11e-484a-b761-c911885548c2', 50665.53, 23, 4, '2024-09-08', '2025-01-08', 'active'),
('d4fc550f-438a-4d1c-9e77-cd42f6d56b00', '6a9b75fb-c1c5-4e1a-a94e-07cbb5c41837', 56166.06, 20, 5, '2024-09-03', '2025-01-09', 'closed'),
('52919168-20b2-4c86-95e8-fc9af60229cd', '82cac284-ec70-4be8-a43e-b002fc419e26', 59943.95, 21, 9, '2025-04-14', '2025-01-13', 'defaulted'),
('ca3651a5-a4e3-41d9-b104-14a2fef95624', 'b9779359-2984-4b3a-83cd-0e0eab80293c', 40994.85, 14, 7, '2024-10-03', '2025-01-17', 'active'),
('4322003d-199e-48b4-af5f-d37689c8c71d', 'c7bb143b-430d-4bbc-9ab1-031826291851', 40482.07, 15, 4, '2025-04-07', '2025-01-01', 'defaulted'),
('87956e86-0adc-4333-843a-3265297d3a2d', '4837eb17-36bb-4c4b-bb49-bc368edb173a', 44872.34, 5, 1, '2024-08-04', '2024-08-12', 'active'),
('0edcbb3d-5140-442d-9f48-674612922e8e', 'b3e475f6-203f-474f-a30c-243fe885b3e1', 58881.74, 13, 6, '2024-11-16', '2024-06-10', 'closed'),
('71b30fa9-a5ed-4c82-8ffe-9dbeee1c8fd2', 'db0df896-914e-491f-9e31-454b9f1d3c7f', 57309.59, 7, 5, '2024-10-17', '2025-02-13', 'defaulted'),
('85c81a58-c3a8-4746-83dd-da8b38017524', '3f5ab011-f526-4bbd-8ab8-8a67ad95c5bf', 40906.87, 18, 10, '2025-04-20', '2025-02-10', 'active'),
('7dedfaa4-4f9f-4156-8433-22354b6a797e', '23fd617f-9912-4a67-b5cb-60147b25930c', 44964.94, 9, 10, '2024-09-10', '2024-12-01', 'closed'),
('8c0dca6a-41dd-4f6c-94b7-bedfe446dac3', '1f2aa50e-b682-43da-b36e-f33d041691dc', 47298.73, 13, 1, '2024-11-02', '2024-06-29', 'closed'),
('a3790b99-7016-4e62-84ec-e7b2d4c29120', '57829c08-247e-4dec-b528-cd1099fc1e81', 52222.18, 11, 10, '2024-09-01', '2025-03-11', 'defaulted'),
('3c062dca-281c-4658-b34b-ef710b3f75d8', 'b5c6a70e-f40c-43ac-9291-418539d54ae7', 47202.95, 18, 6, '2024-06-15', '2025-02-12', 'active'),
('d2528160-fa7c-4d82-9b3c-d8423b8fd849', '9e5061d8-a27f-44cc-a390-5f9ab4d00178', 42521.13, 19, 1, '2024-06-11', '2025-04-23', 'defaulted'),
('957ae0b7-77a8-4c13-ae35-71679a57f31b', '9da1cc29-9c8b-498c-bbbd-c412a8115cc8', 42860.95, 15, 8, '2025-01-06', '2024-10-25', 'active'),
('ecbb25c9-6d69-4f0b-a65a-ec0cb8cbe705', '3701903e-265f-402d-b8f9-5e46a67a89a6', 42893.18, 0, 10, '2024-08-18', '2025-01-03', 'closed'),
('ea666568-ab56-4b00-a0e4-c2f89a858df3', 'fd29af21-54cd-42a1-a4d7-40890f6dd658', 51878.06, 13, 3, '2025-04-21', '2024-10-19', 'closed'),
('9c7970c7-2bb0-4156-ae2a-e6a7a826b150', 'ee6cebc9-6876-4561-9355-b84013639e66', 49174.06, 23, 9, '2024-06-08', '2024-06-07', 'defaulted'),
('79b95262-c1ff-47ce-808f-5899b48f1557', '27693ec7-45c9-4230-89d2-d0c98654cde7', 54152.91, 19, 2, '2024-12-11', '2024-07-30', 'active'),
('065b85a1-eafd-4486-84ce-72928fcbe70b', '0ca06e8d-a7a2-40c4-893b-128336ffdf54', 60014.10, 14, 8, '2024-11-22', '2025-03-05', 'active'),
('7daa4fe8-5771-4d3b-836e-e0ef0335e41b', '6ae55628-7994-4e93-b964-f75e00363d72', 42701.62, 9, 7, '2025-04-11', '2024-07-10', 'closed'),
('a9ae76f3-8548-4e44-9e13-fe8e21f6db0e', '69514bb4-0f65-4e74-b29e-92b1febb7933', 48132.41, 12, 10, '2024-10-16', '2024-05-26', 'defaulted'),
('1ed01141-0b39-4699-87f6-486d2bb56183', '53a68a7b-f69c-4a25-8846-0f06497a3b6d', 43376.53, 18, 9, '2024-10-08', '2024-06-26', 'closed');

UPDATE transactions
SET reference_account = NULL
WHERE transaction_type_id != 3;

-- TOPIK 1 VIEWS

CREATE VIEW v_loans_all AS
SELECT * FROM loans;

ALTER VIEW v_loans_all AS
SELECT * FROM loans
WHERE status = 'active';

DROP VIEW v_loans_all;


-- Tugas Views

-- 1. view v_customer_all menampilkan semua isi tabel customers.

CREATE VIEW v_customer_all AS
SELECT * FROM customers;

ALTER VIEW v_customer_all AS
SELECT customer_id, first_name, last_name, email, phone_number, address, created_at
FROM customers;

DROP VIEW v_customer_all;


-- 2. view v_deposit_transaction menampilkan semua transaksi deposit.

CREATE VIEW v_deposit_transaction AS
SELECT t.*
FROM transactions t
JOIN transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.name = 'deposit';

ALTER VIEW v_deposit_transaction AS
SELECT t.transaction_id, t.account_id, t.amount, t.transaction_date, t.description
FROM transactions t
JOIN transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.name = 'deposit';

DROP VIEW v_deposit_transaction;


-- 3. view v_transfer_transaction menampilkan semua transaksi transfer.

CREATE VIEW v_transfer_transaction AS
SELECT t.*
FROM transactions t
JOIN transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.name = 'transfer';

ALTER VIEW v_transfer_transaction AS
SELECT t.transaction_id, t.account_id, t.amount, t.transaction_date, t.reference_account
FROM transactions t
JOIN transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
WHERE tt.name = 'transfer';

DROP VIEW v_transfer_transaction;


-- TOPIK 2 PROCEDURES

CREATE PROCEDURE sp_get_account_balance
    @account_id VARCHAR(50),
    @balance_out DECIMAL(18,2) OUTPUT
AS
BEGIN
    SELECT @balance_out = balance
    FROM accounts
    WHERE account_id = @account_id;
END;
GO

DECLARE @account_id VARCHAR(50);
DECLARE @balance DECIMAL(18,2);

SET @account_id = '9cd97ecb-58c9-4610-b4b1-d9f72bcae7f7';
EXEC dbo.sp_get_account_balance @account_id, @balance OUTPUT;
SELECT @balance, @account_id;

SELECT @account_id AS AccountID, @balance AS Balance;

DROP PROCEDURE sp_get_account_balance;

-- Tugas Procedures

-- 1. Procedure sp_CreateCustomer untuk menambahkan customer baru ke dalam tabel customers: input first_name, last_name, email, phone_number, address.

CREATE PROCEDURE sp_CreateCustomer
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @email VARCHAR(50),
    @phone_number VARCHAR(20),
    @address VARCHAR(255)
AS
BEGIN
    INSERT INTO customers (customer_id, first_name, last_name, email, phone_number, address, created_at)
    VALUES (NEWID(), @first_name, @last_name, @email, @phone_number, @address, GETDATE());
END;
GO

DECLARE @fn VARCHAR(50), @ln VARCHAR(50), @em VARCHAR(50), @ph VARCHAR(20), @ad VARCHAR(255);
SET @fn = 'Sinta';
SET @ln = 'Putri';
SET @em = 'sinta@example.com';
SET @ph = '08123456789';
SET @ad = 'Jl. Merdeka 123';

EXEC sp_CreateCustomer @fn, @ln, @em, @ph, @ad;
SELECT * FROM customers WHERE email = @em;

DROP PROCEDURE sp_CreateCustomer;


-- 2. Procedure sp_CreateAccount untuk membuat akun baru untuk customer yang sudah ada: input customer_id, account_number, account_type, balance. Notes: Tambahkan validasi untuk memastikan bahwa customer_id benar benar ada pada table customers.

-- ===========================================
-- LANGKAH 1: Tambahkan 1 Customer Dummy
-- ===========================================

DECLARE @new_customer_id CHAR(36) = NEWID();

INSERT INTO customers (
    customer_id, first_name, last_name, email, phone_number, address, created_at
)
VALUES (
    @new_customer_id,
    'Adi',
    'Saputra',
    'adi.saputra@example.com',
    '081212121212',
    'Jl. Mawar No. 88',
    GETDATE()
);

-- Tampilkan ID untuk verifikasi
SELECT @new_customer_id AS customer_id;

-- ===========================================
-- LANGKAH 2: Buat Prosedur sp_CreateAccount
-- ===========================================

CREATE PROCEDURE sp_CreateAccount
    @customer_id CHAR(36),
    @account_number CHAR(10),
    @account_type VARCHAR(50),
    @balance DECIMAL(18,2)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM customers WHERE customer_id = @customer_id)
    BEGIN
        INSERT INTO accounts (
            account_id, customer_id, account_number, account_type, balance, created_at
        )
        VALUES (
            NEWID(), @customer_id, @account_number, @account_type, @balance, GETDATE()
        );
    END
    ELSE
    BEGIN
        RAISERROR('Customer ID tidak ditemukan.', 16, 1);
    END
END;

-- ===========================================
-- LANGKAH 3: Eksekusi sp_CreateAccount
-- (menggunakan ID customer yang barusan dibuat)
-- ===========================================

-- List customer ID
SELECT customer_id, first_name FROM customers WHERE email = 'adi.saputra@example.com';

-- Menjalankan prosedur sp_CreateAccount
DECLARE @cid CHAR(36), @accnum CHAR(10), @acctype VARCHAR(50), @bal DECIMAL(18,2);

-- Gunakan ID hasil dari langkah sebelumnya
SET @cid = 'C773D28F-21AD-4D4C-83E7-ED7456953E5D';
SET @accnum = 'ACC100001';
SET @acctype = 'savings';
SET @bal = 500000;

EXEC sp_CreateAccount @cid, @accnum, @acctype, @bal;

-- ===========================================
-- LANGKAH 4: Verifikasi akun berhasil dibuat
-- ===========================================

DECLARE @accnum CHAR(10);
SET @accnum = 'ACC100001';

SELECT * FROM accounts WHERE account_number = @accnum;

-- ===========================================
-- LANGKAH 5 (Opsional): Hapus prosedur
-- ===========================================

DROP PROCEDURE sp_CreateAccount;


-- 3. Procedure sp_MakeTransaction untuk menambahkan transaksi baru: input account_id, transaction_type_id, amount, description, reference_account (opsional). Notes: Tambahkan validasi untuk transfer, jika jumlah transfer melebihi balance maka transaksi dihentikan.

-- ============================================
-- LANGKAH 1: Membuat prosedur sp_MakeTransaction
-- Termasuk validasi: jika transfer melebihi saldo, maka transaksi dibatalkan
-- ============================================

CREATE PROCEDURE sp_MakeTransaction
    @account_id CHAR(36),
    @transaction_type_id INT,
    @amount DECIMAL(18,2),
    @description VARCHAR(100),
    @reference_account CHAR(36) = NULL
AS
BEGIN
    DECLARE @transaction_type_name VARCHAR(50);
    DECLARE @current_balance DECIMAL(18,2);

    -- Ambil nama tipe transaksi berdasarkan ID
    SELECT @transaction_type_name = name
    FROM transaction_types
    WHERE transaction_type_id = @transaction_type_id;

    -- Ambil saldo akun
    SELECT @current_balance = balance
    FROM accounts
    WHERE account_id = @account_id;

    -- Validasi: jika transfer dan saldo tidak mencukupi
    IF @transaction_type_name = 'transfer' AND @amount > @current_balance
    BEGIN
        RAISERROR('Saldo tidak mencukupi untuk transfer.', 16, 1);
        RETURN;
    END

    -- Tambahkan transaksi
    INSERT INTO transactions (
        transaction_id, account_id, transaction_type_id, amount,
        transaction_date, description, reference_account
    )
    VALUES (
        NEWID(), @account_id, @transaction_type_id, @amount,
        GETDATE(), @description, @reference_account
    );

    -- Update saldo
    UPDATE accounts
    SET balance = balance - @amount
    WHERE account_id = @account_id;
END;

-- ============================================
-- LANGKAH 2: Menjalankan prosedur sp_MakeTransaction
-- Gunakan ID akun dan jenis transaksi yang valid
-- ============================================

-- List account ID
SELECT account_id, account_number, balance FROM accounts;

-- Deklarasi variabel
DECLARE @accid CHAR(36), @ttid INT, @amt DECIMAL(18,2), @desc VARCHAR(100), @ref CHAR(36);

-- Ganti nilai berikut dengan data valid dari tabel Anda
SET @accid = '0937445f-d5eb-4ef9-887f-4173fe662dd4';	-- isi dengan ID
SET @ttid = 2;											-- 2 = transfer
SET @amt = 999999;										-- nominal transfer
SET @desc = 'Transfer ke teman';
SET @ref = NULL;										-- bisa diisi akun tujuan jika ingin

-- Jalankan prosedur
EXEC sp_MakeTransaction @accid, @ttid, @amt, @desc, @ref;

-- ============================================
-- LANGKAH 3: Verifikasi hasil transaksi
-- ============================================

DECLARE @accid CHAR(36);
SET @accid = '0937445f-d5eb-4ef9-887f-4173fe662dd4';

-- Cek transaksi terakhir untuk akun tersebut
SELECT TOP 5 * FROM transactions WHERE account_id = @accid ORDER BY transaction_date DESC;

-- Cek saldo terkini setelah transaksi
SELECT balance FROM accounts WHERE account_id = @accid;

-- ============================================
-- LANGKAH 4 (Opsional): Hapus prosedur latihan
-- ============================================

DROP PROCEDURE sp_MakeTransaction;


-- 4. Procedure sp_GetCustomerSummary untuk menampilkan ringkasan data customer berdasarkan customer_id: 1. Nama lengkap customer, 2. Jumlah akun yang dimiliki, 3. Jumlah total saldo semua akun, 4. Jumlah pinjaman aktif, 5. Total pinjaman amount aktif

-- ============================================================
-- LANGKAH 1: Buat prosedur sp_GetCustomerSummary
-- Menampilkan ringkasan customer berdasarkan customer_id
-- ============================================================

CREATE PROCEDURE sp_GetCustomerSummary
    @customer_id CHAR(36)
AS
BEGIN
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        COUNT(DISTINCT a.account_id) AS total_accounts,
        SUM(a.balance) AS total_balance,
        COUNT(DISTINCT CASE WHEN l.status = 'active' THEN l.loan_id END) AS active_loans_count,
        SUM(CASE WHEN l.status = 'active' THEN l.loan_amount ELSE 0 END) AS active_loan_amount
    FROM customers c
    LEFT JOIN accounts a ON c.customer_id = a.customer_id
    LEFT JOIN loans l ON c.customer_id = l.customer_id
    WHERE c.customer_id = @customer_id
    GROUP BY c.first_name, c.last_name;
END;

-- ============================================================
-- LANGKAH 2: Menjalankan prosedur sp_GetCustomerSummary
-- Gunakan ID customer yang valid dari tabel customers
-- ============================================================

-- List customer ID
SELECT customer_id, first_name FROM customers;

-- Deklarasi variabel
DECLARE @cust CHAR(36);

-- Ganti dengan customer_id yang valid (misalnya dari Sinta)
SET @cust = '00F54BDD-ECDD-4441-99A6-76F01B89D4DC';

-- Eksekusi prosedur
EXEC sp_GetCustomerSummary @cust;

-- ============================================================
-- LANGKAH 3 (Opsional): Hapus prosedur latihan
-- ============================================================

DROP PROCEDURE sp_GetCustomerSummary;
