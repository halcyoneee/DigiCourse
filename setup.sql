-- This file will be executed each time the project is deployed to Heroku
DROP TABLE IF EXISTS StudentGroups CASCADE;
DROP TABLE IF EXISTS CourseGroups CASCADE;
DROP TABLE IF EXISTS Manages CASCADE;
DROP TABLE IF EXISTS Enrollments CASCADE;
DROP TABLE IF EXISTS Courses CASCADE;
DROP TABLE IF EXISTS Students CASCADE;
DROP TABLE IF EXISTS Professors CASCADE;
DROP TABLE IF EXISTS Accounts CASCADE;
DROP TABLE IF EXISTS student_info CASCADE;

CREATE TABLE Accounts (
	u_id  		varchar(9) PRIMARY KEY,
	passwd   	varchar(64) NOT NULL
);

CREATE TABLE Professors (
	p_id  		varchar(9) PRIMARY KEY REFERENCES Accounts (u_id),
	p_name   	varchar(100) NOT NULL
);

CREATE TABLE Courses (
	c_id  		varchar(9) PRIMARY KEY,
	c_name    	varchar(200) NOT NULL,
	c_capacity  integer NOT NULL,
	c_desc    	varchar(2000) NOT NULL
);

CREATE TABLE Students (
	s_id  		varchar(9) PRIMARY KEY REFERENCES Accounts (u_id),
	s_name   	varchar(100) NOT NULL,
	yr_study 	integer NOT NULL,
	major		varchar(100) NOT NULL
);

CREATE TABLE CourseGroups (
	c_id  		varchar(9),
	g_num  		integer,
	g_capacity 	integer NOT NULL,
	PRIMARY KEY (c_id, g_num),
	FOREIGN KEY (c_id) REFERENCES Courses (c_id) ON DELETE CASCADE
);

CREATE TABLE StudentGroups (
	c_id  		varchar(9) REFERENCES Courses (c_id),
	g_num  		integer,
	s_id  		varchar(9) REFERENCES Students (s_id),
	PRIMARY KEY (c_id, g_num, s_id)
);

CREATE TABLE Manages (
	p_id  		varchar(9) REFERENCES Professors (p_id),
	c_id  		varchar(9) REFERENCES Courses (c_id),
	PRIMARY KEY (p_id, c_id)
);

CREATE TABLE Enrollments (
	s_id		varchar(9) REFERENCES Students (s_id),
	c_id		varchar(9) REFERENCES Courses (c_id),
	req_type	integer NOT NULL,
	req_datetime timestamp NOT NULL,
	p_id		varchar(9) DEFAULT NULL,
	req_status	boolean DEFAULT FALSE,
	PRIMARY KEY (s_id, c_id, req_datetime),
	FOREIGN KEY (p_id) REFERENCES Professors (p_id)
);

CREATE OR REPLACE VIEW CourseEnrollments AS (
	SELECT c_id, c_name, s_id, s_name, req_type
	FROM Courses
	NATURAL JOIN Enrollments
	NATURAL JOIN Students
	WHERE req_status
); 

CREATE OR REPLACE VIEW CourseManages AS (
	SELECT c_id, c_name, p_id, p_name
	FROM Courses
	NATURAL JOIN Manages
	NATURAL JOIN Professors
); 

CREATE OR REPLACE VIEW CourseTeachingStaff AS (
	SELECT c_id, c_name, p_id as t_id, p_name as name, 'Professor' as role FROM CourseManages
	UNION
	SELECT c_id, c_name, s_id as t_id, s_name as name, 'Teaching Assistant' as role FROM CourseEnrollments 
	WHERE req_type = 0
); 

CREATE OR REPLACE VIEW CourseApplications AS (
	SELECT C.c_id, C.c_name, M.p_id, S.s_id, S.s_name, E.req_type, E.req_datetime, E.p_id AS approver, E.req_status 
	FROM Courses C NATURAL JOIN Manages M JOIN Enrollments E ON E.c_id = C.c_id NATURAL JOIN Students S
); 

CREATE TABLE student_info (
	matric  varchar(9) PRIMARY KEY,
	name    varchar(255) NOT NULL,
	faculty varchar(3) NOT NULL
);

-- Accounts(u_id, passwd) -> u_id
INSERT INTO Accounts VALUES ('A0000001A', '$2b$10$vS4KkX8uenTCNooir9vyUuAuX5gUhSGVql8yQdsDDD4TG8bSUjkt.');
INSERT INTO Accounts VALUES ('A0000002B', 'B');
INSERT INTO Accounts VALUES ('A0000003C', 'C');
INSERT INTO Accounts VALUES ('A0000004D', 'D');
INSERT INTO Accounts VALUES ('A0000005E', 'E');
INSERT INTO Accounts VALUES ('P0000001A', '$2b$10$vS4KkX8uenTCNooir9vyUuAuX5gUhSGVql8yQdsDDD4TG8bSUjkt.');
INSERT INTO Accounts VALUES ('P0000002B', 'B');

-- Professors(p_id, p_name) -> p_id
INSERT INTO Professors VALUES ('P0000001A', 'Adi');
INSERT INTO Professors VALUES ('P0000002B', 'John');

-- Courses(c_id, c_name, c_capacity, c_desc) -> c_id
INSERT INTO Courses VALUES ('CS2102', 'Database Systems I', 200, 'The aim of this module is to introduce the fundamental concepts and techniques necessary for the understanding and practice of design and implementation of database applications and of the management of data with relational database management systems. The module covers practical and theoretical aspects of design with entity-relationship model, theory of functional dependencies and normalisation by decomposition in second, third and Boyce-Codd normal forms. The module covers practical and theoretical aspects of programming with SQL data definition and manipulation sublanguages, relational tuple calculus, relational domain calculus and relational algebra.');
INSERT INTO Courses VALUES ('CS3102', 'Database Systems II', 200, 'This module provides an in-depth study of the concepts and implementation issues related to database management systems. It first covers the physical implementation of relational data model, which includes storage management, access methods, query processing, and optimisation. Then it covers issues and techniques dealing with multi-user application environments, namely, transactions, concurrency control and recovery. The third part covers object-database systems that are useful extension of relational databases to deal with complex data types. The last part covers database technologies required for modern decision support systems, including data warehousing, data mining and knowledge discovery and on-line analytical processing.');
INSERT INTO Courses VALUES ('CS4102', 'Database Systems III', 200, 'This module studies the management of data in a distributed environment. It covers the fundamental principles of distributed data management and includes distribution design, data integration, distributed query processing and optimization, distributed transaction management, and replication. It will also look at how these techniques can be adapted to support database management in emerging technologies (e.g., parallel systems, peer-to-peer systems, cloud computing).');
INSERT INTO Courses VALUES ('CS5102', 'Database Systems IV', 200, 'Database security has a great impact on the design of today information systems. This course will provide an overview of database security concepts and techniques and discuss new directions of database security in the context of Internet information management. Topics covered include: Access control models for DBMSs, Inference controls, XML database security, Encrypted databases, Digital credentials and PKIs, Trust in open systems, and Peer-to-peer system security.');
INSERT INTO Courses VALUES ('CS2105', 'Introduction to Computer Networks', 200, 'This module aims to provide a broad introduction to computer networks and network application programming. It covers the main concepts, the fundamental principles, and the high-level workings of important protocols in each of the Internet protocol layer. Topics include the Web and Web applications, DNS services, socket programming, reliable protocols, transport and network layer protocols, secure communication, LAN, and data communication. Practical assignments and handson exercises expose students to network application programming and various networking tools and utilities.');
INSERT INTO Courses VALUES ('CS3103', 'Computer Network Practises', 200, 'This module aims to provide an opportunity for the students to learn commonly-used network protocols in greater technical depth with their implementation details than a basic networking course. Students will perform hands-on experiments in configuring and interconnecting LANs using networking devices/technologies (e.g., routers, switches, SDN switches, and hubs), networking protocols (e.g., DHCP, DNS, RIP, OSPF, ICMP, TCP, UDP, wireless LAN, VLAN protocols, SIP, SSL, IPSec-VPN) and networking tools (e.g, tcpdump, netstat, ping, traceroute). Students will learn higher-layer network protocols and develop network applications (client/server, P2P) via socket programming.');
INSERT INTO Courses VALUES ('CS4226', 'Wireless Networking', 200, 'This module aims to provide solid foundation for students in the area of wireless networks and introduces students to the emerging area of cyber-physical-system/Internet-of-Things. The module will cover wireless networking across all layers of the networking stack including physical, link, MAC, routing and application layers. Different network technologies with different characteristic will also be covered, including cellular networks, Wi-Fi, Bluetooth and ZigBee. Some key concepts that cut across all layers and network types are mobility management, energy efficiency, and integration of sensing and communications. The module emphasizes on exposing students to practical network system issues through building software prototypes.');
INSERT INTO Courses VALUES ('BM5125', 'Managing Business Network', 200, '	This is an MBA elective course in the management of networks. It will utilize articles in the business press, case studies, discussion, exercises, and guest speakers in examining a variety of networks that managers and entrepreneurs must design, access, mobilize, and otherwise lead. These include entrepreneurial networks of resource providers and alliance partners; networks of communication and coordination within established organizations; supply chain and marketing channel networks; informal networks in and outside organizations that confer influence and advance careers; cross-border networks for doing business globally. The management of networks requires a distinct and critical set of capabilities, among them: powers of persuasion and trust-building; charisma and vision; spontaneity and flexibility; and tolerance for change and uncertainty.');
INSERT INTO Courses VALUES ('CS5104', 'Network Security', 200, 'The objective of this module is to introduce students to the various issues that arise in securing the networks, and study the state-of-the-art techniques for addressing these challenges. A number of most damaging attacks on computer systems involve the exploitation of network infrastructure. This module provides an in-depth study of network attack techniques and methods to defend against them. Topics include basic concepts in network security; firewalls and virtual private networks; network intrusion detection; denial of service (DoS); traffic analysis; secure routing protocols; protocol scrubbing; and advanced topics such as wireless network security.');
INSERT INTO Courses VALUES ('CS1010', 'Programming Methodology I', 200, 'This module introduces the fundamental concepts of problem solving by computing and programming using an imperative programming language. It is the first and foremost introductory course to computing. Topics covered include computational thinking and computational problem solving, designing and specifying an algorithm, basic problem formulation and problem solving approaches, program development, coding, testing and debugging, fundamental programming constructs (variables, types, expressions, assignments, functions, control structures, etc.), fundamental data structures (arrays, strings, composite data types), basic sorting, and recursion.');
INSERT INTO Courses VALUES ('CS2030', 'Programming Methodology II', 200, 'This module is a follow up to CS1010. It explores two modern programming paradigms, object-oriented programming and functional programming. Through a series of integrated assignments, students will learn to develop medium-scale software programs in the order of thousands of lines of code and tens of classes using objectoriented design principles and advanced programming constructs available in the two paradigms. Topics include objects and classes, composition, association, inheritance, interface, polymorphism, abstract classes, dynamic binding, lambda expression, effect-free programming, first class functions, closures, continuations, monad, etc.');
INSERT INTO Courses VALUES ('CS4215', 'Programming Language implementation', 200, 'This module provides the students with theoretical knowledge and practical skill in the implementation of programming languages. It discusses implementation aspects of fundamental programming paradigms (imperative, functional and object-oriented), and of basic programming language concepts such as binding, scope, parameter-passing mechanisms and types. It introduces the language processing techniques of interpretation and compilation and virtual machines. The lectures are accompanied by lab sessions which will focus on language processing tools, and take the student through a sequence of programming language implementations. This modules also covers automatic memory management, dynamic linking and just-in-time compilation, as features of modern execution systems.');
INSERT INTO Courses VALUES ('CS2100', 'Computer Organizations', 200, 'The objective of this module is to familiarise students with the fundamentals of computing devices. Through this module students will understand the basics of data representation, and how the various parts of a computer work, separately and with each other. This allows students to understand the issues in computing devices, and how these issues affect the implementation of solutions. Topics covered include data representation systems, combinational and sequential circuit design techniques, assembly language, processor execution cycles, pipelining, memory hierarchy and input/output systems.');

-- Manages(p_id, c_id) -> p_id, c_id
INSERT INTO Manages VALUES ('P0000001A','CS2102');
INSERT INTO Manages VALUES ('P0000001A','CS2100');
INSERT INTO Manages VALUES ('P0000001A','CS2030');
INSERT INTO Manages VALUES ('P0000001A','CS4102');
INSERT INTO Manages VALUES ('P0000001A','CS4215');
INSERT INTO Manages VALUES ('P0000002B','BM5125');

-- Students(s_id, s_name, yr_study, major) -> s_id
INSERT INTO Students VALUES ('A0000001A', 'Leslie Cole', 1, 'SOC');
INSERT INTO Students VALUES ('A0000002B', 'Myra Morgan', 2, 'SOC');
INSERT INTO Students VALUES ('A0000003C', 'Raymond Benson', 2, 'SOC');
INSERT INTO Students VALUES ('A0000004D', 'Wendy Kelley', 3,'SOC');
INSERT INTO Students VALUES ('A0000005E', 'Patrick Bowers', 3,'FOE');

-- CourseGroups (c_id, g_num, g_capacity) --> c_id, g_num
INSERT INTO CourseGroups VAlUES ('CS2102', 1, 5);
INSERT INTO CourseGroups VAlUES ('CS2102', 2, 5);
INSERT INTO CourseGroups VAlUES ('CS2102', 3, 5);
INSERT INTO CourseGroups VAlUES ('CS2102', 4, 5);
INSERT INTO CourseGroups VAlUES ('CS2100', 1, 5);

-- StudentGroups (c_id, g_num, s_id) --> c_id, g_num, s_id
INSERT INTO StudentGroups VAlUES ('CS2102', 4, 'A0000001A');
INSERT INTO StudentGroups VAlUES ('CS2100', 2, 'A0000001A');

-- Enrollments (s_id, c_id, req_type, req_datetime, p_id, req_status) --> s_id, c_id, req_datetime
INSERT INTO Enrollments VALUES ('A0000001A', 'CS2102', 1, NOW()); 
INSERT INTO Enrollments VALUES ('A0000002B', 'CS2102', 1, NOW()); 
INSERT INTO Enrollments VALUES ('A0000003C', 'CS2102', 1, NOW()); 
INSERT INTO Enrollments VALUES ('A0000004D', 'CS2102', 0, NOW()); 
INSERT INTO Enrollments VALUES ('A0000001A', 'CS2100', 1, NOW()); 
INSERT INTO Enrollments VALUES ('A0000002B', 'CS2100', 1, NOW()); 
INSERT INTO Enrollments VALUES ('A0000003C', 'CS2030', 1, NOW()); 
INSERT INTO Enrollments VALUES ('A0000001A', 'CS4102', 1, NOW(), 'P0000001A', TRUE); 
INSERT INTO Enrollments VALUES ('A0000001A', 'CS4215', 1, NOW(), 'P0000001A', TRUE); 
INSERT INTO Enrollments VALUES ('A0000001A', 'CS2030', 0, NOW(), 'P0000001A', FALSE); 
INSERT INTO Enrollments VALUES ('A0000001A', 'BM5125', 0, NOW(), NULL, FALSE); 
INSERT INTO Enrollments VALUES ('A0000004D', 'CS4215', 0, NOW(), 'P0000001A', TRUE); 

INSERT INTO student_info (matric, name, faculty) VALUES ('A0000001A', 'Leslie Cole', 'SOC');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000002B', 'Myra Morgan', 'SOC');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000003C', 'Raymond Benson', 'SOC');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000004D', 'Wendy Kelley', 'SOC');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000005E', 'Patrick Bowers', 'FOE');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000006F', 'Ralph Hogan', 'FOE');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000007G', 'Cecil Rodriquez', 'SCI');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000008H', 'Delia Ferguson', 'SCI');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000009I', 'Frances Wright', 'SCI');
INSERT INTO student_info (matric, name, faculty) VALUES ('A0000010J', 'Alyssa Sims', 'SCI');

