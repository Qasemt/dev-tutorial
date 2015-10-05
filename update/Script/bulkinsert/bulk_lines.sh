sqlite3 /usr/local/softwares/data/app.db3  <<EOS

DROP TABLE IF EXISTS "line";
-- Table: line
CREATE TABLE line ( 
    lineCode         INTEGER NOT NULL,
    startstationcode INTEGER NOT NULL,
    endstationcode   INTEGER NOT NULL,
    sdt              INTEGER NOT NULL
                             DEFAULT '3600',
    sv               BOOLEAN NOT NULL
                             DEFAULT '0',
    PRIMARY KEY ( lineCode ) 
);

INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (0, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (1, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (2, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (3, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (4, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (5, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (6, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (7, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (8, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (9, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (10, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (11, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (12, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (13, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (14, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (15, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (16, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (17, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (18, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (19, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (20, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (21, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (22, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (23, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (24, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (25, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (26, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (27, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (28, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (29, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (30, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (31, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (33, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (34, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (35, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (36, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (37, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (38, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (39, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (40, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (41, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (42, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (43, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (44, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (45, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (46, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (47, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (48, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (49, 1169, 1169, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (50, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (51, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (52, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (53, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (54, 1101, 1101, 90, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (55, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (56, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (57, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (58, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (59, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (60, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (61, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (62, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (63, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (64, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (65, 1169, 1169, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (66, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (67, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (68, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (69, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (70, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (71, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (72, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (73, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (74, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (75, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (76, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (77, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (78, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (79, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (80, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (81, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (82, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (83, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (84, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (85, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (86, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (88, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (89, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (90, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (91, 1101, 1101, 90, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (92, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (93, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (94, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (95, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (96, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (97, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (98, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (100, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (101, 4115, 4132, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (102, 2590, 2429, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (111, 4115, 4132, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (112, 2590, 2429, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (115, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (116, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (117, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (118, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (119, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (120, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (121, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (122, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (123, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (124, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (155, 1169, 1169, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (157, 1169, 1169, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (167, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (168, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (169, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (191, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (192, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (193, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (267, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (501, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (542, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (901, 1101, 1101, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (999, 1, 1, 75, 0);
INSERT INTO [line] ([lineCode], [startstationcode], [endstationcode], [sdt], [sv]) VALUES (1000, 1, 1, 75, 0);

EOS
echo ">>>[bulk lines] finished >>>>>>"
