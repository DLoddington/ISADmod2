DROP TABLE drug_pharmacy ;
DROP TABLE prescription;
DROP TABLE nurse_appointment;
DROP TABLE diagnosis;
DROP TABLE appointment;
DROP TABLE drug;
DROP TABLE pharmacy;
DROP TABLE doctor;
DROP TABLE nurse;
DROP TABLE pet;
DROP TABLE owner;
DROP TABLE apptimeslots;
DROP TABLE fees;
DROP TABLE gender;
DROP TABLE yesno;

CREATE TABLE yesno (
y_n CHAR(1) CONSTRAINT yesno_yes_no_pk PRIMARY KEY,
yes_no VARCHAR2(3)
);

CREATE TABLE gender (
m_f CHAR(1) CONSTRAINT gender_m_f_pk PRIMARY KEY,
gender_desc VARCHAR2(6)
);

CREATE TABLE fees (
app_fee NUMBER(6,2) CONSTRAINT fees_app_fee_pk PRIMARY KEY
);

CREATE TABLE apptimeslots (
avail_time DATE CONSTRAINT apptimeslots_avail_time_pk PRIMARY KEY
);


CREATE TABLE owner (
owner_id       NUMBER GENERATED ALWAYS AS IDENTITY START WITH 10000 INCREMENT BY 1 CONSTRAINT owner_owner_id_pk PRIMARY KEY     ,
first_name     VARCHAR2(15)                                                                                                    ,
last_name      VARCHAR2(15)    CONSTRAINT owner_last_name_nn NOT NULL                                                          ,
age            NUMBER(2)                                                                                                       ,
tel            VARCHAR2(20)    CONSTRAINT owner_tel_nn NOT NULL                                                                ,
email          VARCHAR2(40)                                                                                                    ,
street_address VARCHAR2(25)   CONSTRAINT owner_street_address_nn NOT NULL                                                      ,
postcode       VARCHAR2(8)     CONSTRAINT owner_postcode_nn NOT NULL
);

CREATE TABLE pet (
pet_id            NUMBER GENERATED ALWAYS AS IDENTITY START WITH 1000 INCREMENT BY 1 CONSTRAINT pet_id_ck CHECK (pet_id <=3000)  CONSTRAINT pet_pet_id_pk PRIMARY KEY    ,
name              VARCHAR2(25)       CONSTRAINT pet_name_nn NOT NULL                                                                                                     ,
type              VARCHAR2(25)                                                                                                                                           ,
gender            CHAR(1)            CONSTRAINT pet_gender_ck REFERENCES gender(m_f)                                                                                     , 
date_of_birth     DATE               CONSTRAINT pet_date_of_birth_nn NOT NULL                                                                                            ,
date_of_pet_entry DATE               CONSTRAINT pet_date_of_pet_entry_nn NOT NULL                                                                                        ,
colour            VARCHAR2(40)                                                                                                                                           ,
weight_in_kg      NUMBER(3,1)                                                                                                                                            ,
owner_id          NUMBER(5)          CONSTRAINT pet_owner_id_nn NOT NULL CONSTRAINT pet_owner_id_fk REFERENCES owner(owner_id)                                           ,
CONSTRAINT pet_age_at_entry_ck   CHECK (TRUNC((date_of_pet_entry - date_of_birth)/365) BETWEEN 1 AND 12)
);

CREATE TABLE nurse (
nurse_id      NUMBER GENERATED ALWAYS AS IDENTITY START WITH 22000 INCREMENT BY 1 CONSTRAINT nurse_nurse_id_pk PRIMARY KEY                                             ,
first_name    VARCHAR2(15)                                                                                                                                            ,
last_name     VARCHAR2(15)    CONSTRAINT nurse_last_name_nn NOT NULL                                                                                                  ,
email         VARCHAR2(40)    CONSTRAINT nurse_email_nn NOT NULL CONSTRAINT nurse_email_uk UNIQUE                                                                     ,
tel           VARCHAR2(13)    CONSTRAINT nurse_tel_nn NOT NULL                                                                                                        ,
is_full_time  CHAR(1)         CONSTRAINT nurse_is_full_time_fk REFERENCES yesno(y_n)   
);

CREATE TABLE doctor (
doctor_id     NUMBER GENERATED ALWAYS AS IDENTITY START WITH 2200 INCREMENT BY 1 CONSTRAINT doctor_doctor_id_pk PRIMARY KEY                                            ,
first_name    VARCHAR2(15)                                                                                                                                             ,
last_name     VARCHAR2(15)    CONSTRAINT doctor_last_name_nn NOT NULL                                                                                                  ,
office_num    VARCHAR2(2)                                                                                                                                              ,
tel           VARCHAR2(13)    CONSTRAINT doctor_tel_nn NOT NULL                                                                                                        ,
email         VARCHAR2(40)    CONSTRAINT doctor_email_nn NOT NULL CONSTRAINT doctor_email_uk UNIQUE                                                                    ,
is_full_time  CHAR(1)         CONSTRAINT doctor_is_full_time_fk REFERENCES yesno(y_n)                                                                                           
);

CREATE TABLE pharmacy (
pharmacy_id   NUMBER GENERATED ALWAYS AS IDENTITY START WITH 6000 INCREMENT BY 1 CONSTRAINT pharmacy_pharmacy_id_pk PRIMARY KEY                                  ,
name          VARCHAR2(25)    CONSTRAINT pharmacy_name_nn NOT NULL                                            ,
street_address       VARCHAR2(40)
);

CREATE TABLE drug (
drug_id       NUMBER GENERATED ALWAYS AS IDENTITY START WITH 5000 INCREMENT BY 1 CONSTRAINT drug_drug_id_pk PRIMARY KEY                                          ,
name          VARCHAR2(25)    CONSTRAINT drug_name_nn NOT NULL                                            
);

CREATE TABLE appointment (
app_id             NUMBER(6) CONSTRAINT appointment_app_id_pk PRIMARY KEY,
app_date           DATE,
app_timeslot       DATE      CONSTRAINT appointment_app_timeslot_fk REFERENCES apptimeslots(avail_time),  
pet_id             NUMBER(4) CONSTRAINT appointment_pet_id_fk REFERENCES pet(pet_id),
pet_date_of_birth  DATE,
doctor_id          NUMBER(4) CONSTRAINT appointment_doctor_id_fk REFERENCES doctor(doctor_id),
is_app_cancelled   Char(1) CONSTRAINT app_app_cancelled_fk REFERENCES yesno(y_n),
date_app_cancelled   DATE,
app_fee            NUMBER (6,2) CONSTRAINT app_app_fee_fk REFERENCES fees(app_fee),
is_cancel_fee_paid    Char(1) CONSTRAINT app_cancel_fee_paid_fk REFERENCES yesno(y_n),
CONSTRAINT app_cancelled_date_ck CHECK ((date_app_cancelled IS NOT NULL) OR (date_app_cancelled IS NULL AND is_app_cancelled <> 'Y')),
CONSTRAINT app_cancel_fee_paid_ck CHECK ((is_cancel_fee_paid IS NOT NULL) OR (is_cancel_fee_paid IS NULL AND is_app_cancelled <> 'Y' ) OR 
(is_cancel_fee_paid IS NULL AND is_app_cancelled = 'Y' AND(TRUNC(app_date - date_app_cancelled) > 0))),
CONSTRAINT app_pet_age_at_app_ck CHECK  (TRUNC((app_date - pet_date_of_birth)/365) BETWEEN 1 AND 12),
CONSTRAINT app_app_fee_ck CHECK (((is_app_cancelled = 'N' AND TRUNC((app_date - pet_date_of_birth)/365) BETWEEN 1 AND 4) AND app_fee = 10) OR 
((is_app_cancelled = 'N' AND TRUNC((app_date - pet_date_of_birth)/365) BETWEEN 5 AND 9) AND app_fee = 15) OR
((is_app_cancelled = 'N' AND TRUNC((app_date - pet_date_of_birth)/365) BETWEEN 10 AND 12) AND app_fee = 20) OR
(is_app_cancelled = 'Y' AND TRUNC(app_date - date_app_cancelled) > 0 AND app_fee = 0) OR
(is_app_cancelled = 'Y' AND TRUNC(app_date - date_app_cancelled) = 0 AND app_fee = 5)),
CONSTRAINT app_dr_doublebooked_ck UNIQUE (doctor_id, app_date, app_timeslot),
CONSTRAINT app_pet_doublebooked_ck UNIQUE (pet_id, app_date, app_timeslot)   
);

CREATE TABLE diagnosis (
diag_id              NUMBER GENERATED ALWAYS AS IDENTITY START WITH 10000 INCREMENT BY 1 CONSTRAINT diagnosis_diag_id_pk PRIMARY KEY                              ,
app_id               NUMBER(6)       CONSTRAINT diagnosis_app_id_nn NOT NULL CONSTRAINT diagnosis_app_id_fk REFERENCES appointment(app_id)                        ,
diag_desc            VARCHAR2(500)
);

CREATE TABLE nurse_appointment (
nurse_id NUMBER(6) CONSTRAINT nurse_appointment_nurse_id_nn NOT NULL CONSTRAINT nurse_appointment_nurse_id_fk REFERENCES nurse(nurse_id),
app_id NUMBER(6) CONSTRAINT nurse_appointment_app_id_nn NOT NULL CONSTRAINT nurse_appointment_app_id_fk REFERENCES appointment(app_id),
app_date DATE CONSTRAINT nurse_app_app_date_nn NOT NULL,
app_timeslot DATE CONSTRAINT nurse_app_app_timeslot_nn NOT NULL,
CONSTRAINT nurse_appointment_pk PRIMARY KEY (nurse_id, app_id),
CONSTRAINT nurse_app_doublebooked_ck UNIQUE (nurse_id, app_date, app_timeslot)
);

CREATE TABLE prescription (
diag_id NUMBER(5) CONSTRAINT pres_diag_id_nn NOT NULL CONSTRAINT pres_diag_id_fk REFERENCES diagnosis(diag_id) ON DELETE CASCADE,
drug_id NUMBER(4) CONSTRAINT pres_drug_id_nn NOT NULL CONSTRAINT pres_drug_id_fk REFERENCES drug(drug_id) ON DELETE CASCADE ,
pres_dose NUMBER (6,2),
pres_dose_unit VARCHAR2(10),
pres_amount NUMBER (3),
pres_guidance VARCHAR2 (500),
CONSTRAINT pres_pk PRIMARY KEY (diag_id, drug_id)
);

CREATE TABLE drug_pharmacy (
drug_id NUMBER(4) CONSTRAINT pharmacy_drugs_drug_id_nn NOT NULL CONSTRAINT pharmacy_drugs_drug_id_fk REFERENCES drug(drug_id),
pharmacy_id NUMBER(4) CONSTRAINT pharmacy_drugs_pharmacy_id_nn NOT NULL CONSTRAINT pharmacy_drugs_pharmacy_id_fk REFERENCES pharmacy(pharmacy_id),
pharmacy_available_dose NUMBER(6,2) CONSTRAINT pharmacy_available_dose_nn NOT NULL,
pharmacy_dose_unit VARCHAR2(20) CONSTRAINT pharmacy_dose_unit_nn NOT NULL,
drug_cost_per_dose_gbp NUMBER(6,2) CONSTRAINT drug_cost_per_dose_gbp_nn NOT NULL,
CONSTRAINT pharmacy_drugs_pk PRIMARY KEY (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit)
);

INSERT INTO yesno 
	   (y_n, yes_no)
    VALUES ('Y', 'Yes');

INSERT INTO yesno 
	   (y_n, yes_no)
    VALUES ('N', 'No');

INSERT INTO gender
           (m_f, gender_desc)
    VALUES ('M', 'Male');

INSERT INTO gender
           (m_f, gender_desc)
    VALUES ('F', 'Female');
	
INSERT INTO fees
           (app_fee)
    VALUES (0);

INSERT INTO fees
           (app_fee)
    VALUES (5);

INSERT INTO fees
           (app_fee)
    VALUES (10);

INSERT INTO fees
           (app_fee)
    VALUES (15);

INSERT INTO fees
           (app_fee)
    VALUES (20);
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('08.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('08.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('08.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('08.45','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('09.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('09.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('09.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('09.45','HH24:MI'));
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('10.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('10.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('10.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('10.45','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('11.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('11.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('11.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('11.45','HH24:MI'));
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('12.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('12.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('12.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('12.45','HH24:MI'));

INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('13.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('13.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('13.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('13.45','HH24:MI'));

INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('14.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('14.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('14.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('14.45','HH24:MI'));
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('15.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('15.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('15.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('15.45','HH24:MI'));

INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('16.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('16.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('16.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('16.45','HH24:MI'));

INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('17.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('17.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('17.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('17.45','HH24:MI'));

INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('18.00','HH24:MI')); 
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('18.15','HH24:MI'));   
    
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('18.30','HH24:MI'));   
   
INSERT INTO apptimeslots
           (avail_time)
    VALUES (TO_DATE('18.45','HH24:MI'));

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ( 'David', 'Guetta', 53, '01616623454', 'David.Guetta@aol.com', '50 Chester Road', 'M16 4TU');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Sam', 'Smith', 29, '01612112324', 'SSmith@hotmail.com', 'Apartment 55 Murrays Mill', 'M4 6LS');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Craig', 'Charles', 57, '01616656653', 'craig.charles@robotwars.com', '1 Coronation Street', 'M5 3SA');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('George', 'Michael', '', '01618172881', 'carelesswhisperer@gmail.com', '30 Canal Street', 'M1 3HE');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Kylie', 'Minogue', '', '0748622232', 'thelocomotion@gmail.com', '31 Canal Street', 'M1 3HE');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Kylie', 'Jenner', 24, '07999999943', 'pepsiadvert@gmail.com', 'Big Mansion on Broadway', 'WA15 0PQ');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Chabbu', 'Chabak', 31, '+44(0)7652 534 213', 'Chabchab@yahoo.com', 'Sir Matt Busby Way', 'M16 0RA');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Sarah', 'Palin', 57, '07263837326', 'alaskagovenor@aol.com', '9 Republican Avenue', 'M12 9SH');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Gabby', 'Logan', 48, '0161 5432616', 'Gabby.logan@bbc.co.uk', '1 Media City Apartments', 'M50 2EQ');
	
INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Bruce', 'Dickinson', 61, '0161 4287839', 'BrucieD@ironmaiden.co.uk', '23 Hells lane', 'M66 6IM');
	
INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Steve', 'Harris', 59, '01613747583', 'StevieH@ironmaiden.co.uk', '21 Edward Close', 'M66 6EC');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Alexi', 'Laiho', 45, '0161 643 2335', 'childsdebodskialex@guitarists.fn', '498 Shred Street', 'M32 2AJ');

INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Jeffrey', 'Hanneman', 49, '0161 473 5849', 'HanneyJingles@guitartists.com', '1 Solo Avenue', 'M5 9TK');
	
INSERT INTO owner 
	   (first_name, last_name, age, tel, email, street_address, postcode)
    VALUES ('Dimebag', 'Darrel', 38, '0161 294 4050', 'DimebagDarrel@hotmail.com', '13 Happy Town', 'M13 8KT');


INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('chappyDog', 'Alsation', 'M', '08 MAR 2019', SYSDATE, 'beige', 03.0, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('David') AND UPPER(last_name) = UPPER('Guetta')));
	
INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('chiwado', 'Chiwawa', 'F','9 July 2011', SYSDATE, 'black', 01.0, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Sam') AND UPPER(last_name) = UPPER('Smith')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('bullyTom', 'Bull dog', 'F', '20 October 2015', SYSDATE , 'grey', 4.5, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Craig') AND UPPER(last_name) = UPPER('Charles')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('terryToe', 'Terrier', 'F', '02 August 2017', SYSDATE, 'white', 1.2, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('George') AND UPPER(last_name) = UPPER('Michael')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('poody', 'Boxer', 'M', '29 August 2013', SYSDATE, 'black', 1, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Kylie') AND UPPER(last_name) = UPPER('Minogue')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('dood', 'Dalmation', 'F', '25 Dec 2017', SYSDATE, 'spotted', 7, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Chabbu') AND UPPER(last_name) = UPPER('Chabak')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('dood', 'SheepWolf', 'M', '5 MARCH 2010', SYSDATE, 'brown', 10.0, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Sarah') AND UPPER(last_name) = UPPER('Palin')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('labbyDee', 'Labrador', 'M', '5 MARCH 2009', SYSDATE, 'white', 12, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Kylie') AND UPPER(last_name) = UPPER('Jenner')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('shiTzo', 'Shih Tzu', 'F', '28 Feb 2014', SYSDATE, 'mixed brown', 1, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Kylie') AND UPPER(last_name) = UPPER('Minogue')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('jake', 'Shih Tzu', 'M', '1 Jan 2018', SYSDATE, 'Greyish white', 4, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Gabby') AND UPPER(last_name) = UPPER('Logan')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('gotty', 'Shih Tzu', 'M', '1 October 2017', SYSDATE, 'mixed brown', 1, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Kylie') AND UPPER(last_name) = UPPER('Minogue')));
	
INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('Dobby', 'Doberman', 'M', '12 September 2016', SYSDATE, 'black and tan', 8, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Bruce') AND UPPER(last_name) = UPPER('Dickinson')));
	
INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('Goldy', 'Golden Retriever', 'F', '30 August 2020', SYSDATE, 'golden', 6.5, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Steve') AND UPPER(last_name) = UPPER('Harris')));
	
INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('Lotty', 'Alsation', 'F', '19 July 2018', SYSDATE, 'Black', 6, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Alexi') AND UPPER(last_name) = UPPER('Laiho')));
	
INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('Panface', 'Spaniel', 'F', '19 October 2017', SYSDATE, 'Ginger', 3, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Jeffrey') AND UPPER(last_name) = UPPER('Hanneman')));
	
INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('Rotty', 'Rottweiler', 'M', '15 December 2009', SYSDATE, 'Ginger', 3, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('Dimebag') AND UPPER(last_name) = UPPER('Darrel')));

INSERT INTO pet (name, type, gender, date_of_birth, date_of_pet_entry, colour, weight_in_kg, owner_id)
VALUES ('Sebastian', 'Irish Wolfhound', 'M', '15 December 2010', SYSDATE, 'Grey', 8, (SELECT owner_id
    FROM owner
    WHERE UPPER(first_name) = UPPER('George') AND UPPER(last_name) = UPPER('Michael')));	

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Davidth', 'Chapelle', '0161 3446 801', 'chapelleD@noahs.com', 'N');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Robert', 'Kreitscher', '0161 3446 802', 'kreitscherR@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Rebecca', 'White', '0161 3446 803', 'whiteR@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Zoya', 'Maqbul', '0161 3446 804', 'maqbulZ@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Mindy', 'Black', '0161 3446 805', 'blackM@noahs.com', 'N');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Robyn', 'Hood', '0161 3446 806', 'hoodR@noahs.com', 'N');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Max', 'Plank', '0161 3446 808', 'plankM@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Wesley', 'Harrington', '0161 3446 858', 'harringtonW@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Verity', 'Dogman', '0161 3446 809', 'dogmanV@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Paul', 'Francis', '0161 3446 810', 'francisP@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Barry', 'White', '0161 3446 811', 'whiteB@noahs.com', 'N');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Lucy', 'Smith', '0161 3446 812', 'smithL@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('FFion', 'Mceown', '0161 3446 813', 'mceownF@noahs.com', 'Y');

INSERT INTO nurse
      (first_name, last_name, tel, email, is_Full_Time)
VALUES('Thomas', 'Mackrory', '0161 3446 814', 'mackroryT@noahs.com', 'Y');
		
INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Claire', 'Cleverly', 12, '0161 3446 543', 'cleverly_cl@noahs.com', 'N');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Kieran', 'Mike', 34, '0161 3446 522', 'mikeK@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Farran', 'Farraday', 34, '0161 3446 521', 'farradayF@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Finola', 'Fred', 41, '0161 3446 508', 'fredF@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Siobhan', 'Watson', 1, '0161 3446 500', 'watsS@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Frank', 'Freeman', 2, '0161 3446 565', 'freemanF@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Chris', 'Crowley', 10, '0161 3446 535', 'crowleyC@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Bilal', 'Rahib', 16, '0161 3446 511', 'rahibB@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Darren', 'Dancey', 3, '0161 3446 586', 'danceyD@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Stephen', 'Gordon', 69, '0161 3446 420', 'gordonS@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Clarice', 'Starling', 43, '0161 3446 654', 'starlingC@noahs.com', 'N');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Lindsey', 'Lohan', 23, '0161 3446 987', 'lohanL@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Leonard', 'Nemoy', 50, '0161 3446 900', 'nemoyL@noahs.com', 'N');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Fox', 'Maulder', 99, '0161 3446 980', 'maulderF@noahs.com', 'N');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Dana', 'Scully', 99, '0161 3446 981', 'scullyD@noahs.com', 'Y');

INSERT INTO doctor
      (first_name, last_name, office_num, tel, email, is_Full_Time)
VALUES('Frank', 'Black', 26, '0161 3446 656', 'blackF@noahs.com', 'N');

INSERT INTO pharmacy
      (name, street_address)
VALUES(UPPER('ringos pharmacopeia'),UPPER('1 dramhall lane'));

INSERT INTO pharmacy
      (name, street_address)
VALUES(UPPER('doots pharmacy'),UPPER('20 farmer drive'));

INSERT INTO pharmacy
      (name, street_address)
VALUES(UPPER('schloyds pharmacy'),UPPER('18 high street'));

INSERT INTO pharmacy
      (name, street_address)
VALUES(UPPER('megadrug'),UPPER('30 angel avenue'));

INSERT INTO pharmacy
      (name, street_address)
VALUES(UPPER('pet drug superstore'),UPPER('948 woof woof close'));

INSERT INTO pharmacy
      (name, street_address)
VALUES(UPPER('Smiths Pharmacy'),UPPER('1 Long Road'));

INSERT INTO drug
      (name)
VALUES(UPPER('metronidazole'));

INSERT INTO drug
      (name)
VALUES(UPPER('worming treament'));

INSERT INTO drug
      (name)
VALUES(UPPER('anti histamine'));

INSERT INTO drug
      (name)
VALUES(UPPER('tramadol'));

INSERT INTO drug
      (name)
VALUES(UPPER('AA'));

INSERT INTO drug
      (name)
VALUES(UPPER('hydrocortisone cream'));

INSERT INTO drug
      (name)
VALUES(UPPER('Flea Treatment'));

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105078, TO_DATE('06/09/2021' , 'DD/MM/YYYY'), TO_DATE('10:30' , 'hh24:mi') ,1000, (SELECT date_of_birth FROM pet WHERE pet_id = 1000), 2201, 'N', 10); 

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105091, TO_DATE('06/09/2021' , 'DD/MM/YYYY'), TO_DATE('10:30' , 'hh24:mi'), 1003, (SELECT date_of_birth FROM pet WHERE pet_id = 1003), 2202, 'N', 10 );

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105187, TO_DATE('29/09/2021' , 'DD/MM/YYYY'), TO_DATE('10:30' , 'hh24:mi'), 1002, (SELECT date_of_birth FROM pet WHERE pet_id = 1002), 2203, 'N', 15);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105235, TO_DATE('07/10/2021' , 'DD/MM/YYYY'), TO_DATE('10:30' , 'hh24:mi'), 1006, (SELECT date_of_birth FROM pet WHERE pet_id = 1006), 2204, 'N', 20 );

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, date_app_cancelled, app_fee, is_cancel_Fee_Paid)
VALUES(104821, TO_DATE('03/08/2021' , 'DD/MM/YYYY'), TO_DATE('11:00' , 'hh24:mi'), 1009, (SELECT date_of_birth FROM pet WHERE pet_id = 1009), 2207, 'Y', TO_DATE('03/08/2021','DD/MM/YYYY'), 5, 'N');

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(104876, TO_DATE('05/08/2021' , 'DD/MM/YYYY'), TO_DATE('13:15' , 'hh24:mi'), 1000, (SELECT date_of_birth FROM pet WHERE pet_id = 1000), 2201, 'N', 10);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(104881, TO_DATE('05/08/2021' , 'DD/MM/YYYY'), TO_DATE('17:30' , 'hh24:mi'), 1003, (SELECT date_of_birth FROM pet WHERE pet_id = 1003), 2200, 'N', 10);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(104901, TO_DATE('09/08/2021' , 'DD/MM/YYYY'), TO_DATE('16:00' , 'hh24:mi'), 1004, (SELECT date_of_birth FROM pet WHERE pet_id = 1004), 2201, 'N', 15);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(104921, TO_DATE('13/08/2021' , 'DD/MM/YYYY'), TO_DATE('12:00' , 'hh24:mi'), 1015, (SELECT date_of_birth FROM pet WHERE pet_id = 1015), 2212, 'N', 20);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, date_app_cancelled, app_fee)
VALUES(104945, TO_DATE('16/08/2021' , 'DD/MM/YYYY'), TO_DATE('12:30' , 'hh24:mi'), 1001, (SELECT date_of_birth FROM pet WHERE pet_id = 1001), 2202, 'Y', TO_DATE('13/08/2021','DD/MM/YYYY'), 0);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(104962, TO_DATE('18/08/2021' , 'DD/MM/YYYY'), TO_DATE('09:00' , 'hh24:mi'), 1014, (SELECT date_of_birth FROM pet WHERE pet_id = 1014), 2213, 'N', 10);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(104999, TO_DATE('02/09/2021' , 'DD/MM/YYYY'), TO_DATE('14:15' , 'hh24:mi'), 1005, (SELECT date_of_birth FROM pet WHERE pet_id = 1005), 2206, 'N', 10);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, date_app_cancelled, app_fee, is_cancel_Fee_Paid)
VALUES(105002, TO_DATE('03/09/2021' , 'DD/MM/YYYY'), TO_DATE('17:15' , 'hh24:mi'), 1008, (SELECT date_of_birth FROM pet WHERE pet_id = 1008), 2207, 'Y', TO_DATE('03/09/2021','DD/MM/YYYY'), 5,'N');

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105080, TO_DATE('06/09/2021' , 'DD/MM/YYYY'), TO_DATE('9:00' , 'hh24:mi'), 1011, (SELECT date_of_birth FROM pet WHERE pet_id = 1011), 2210, 'N', 10);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105099, TO_DATE('10/09/2021' , 'DD/MM/YYYY'), TO_DATE('13:45' , 'hh24:mi'), 1012, (SELECT date_of_birth FROM pet WHERE pet_id = 1012), 2208, 'N', 10);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105096, TO_DATE('10/09/2021' , 'DD/MM/YYYY'), TO_DATE('12:00' , 'hh24:mi'), 1008, (SELECT date_of_birth FROM pet WHERE pet_id = 1008), 2213, 'N', 15);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105121, TO_DATE('15/09/2021' , 'DD/MM/YYYY'), TO_DATE('09:45' , 'hh24:mi'), 1015, (SELECT date_of_birth FROM pet WHERE pet_id = 1015), 2210, 'N', 20);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105171, TO_DATE('27/09/2021' , 'DD/MM/YYYY'), TO_DATE('12:15' , 'hh24:mi'), 1006, (SELECT date_of_birth FROM pet WHERE pet_id = 1006), 2204, 'N', 20);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105206, TO_DATE('04/10/2021' , 'DD/MM/YYYY'), TO_DATE('10:00' , 'hh24:mi'), 1007, (SELECT date_of_birth FROM pet WHERE pet_id = 1007), 2203, 'N', 20);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105229, TO_DATE('05/10/2021' , 'DD/MM/YYYY'), TO_DATE('12:00' , 'hh24:mi'), 1005, (SELECT date_of_birth FROM pet WHERE pet_id = 1005), 2213, 'N', 10);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105398, TO_DATE('11/10/2021' , 'DD/MM/YYYY'), TO_DATE('09:00' , 'hh24:mi'), 1002, (SELECT date_of_birth FROM pet WHERE pet_id = 1002), 2203, 'N', 15);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, date_app_cancelled, app_fee)
VALUES(105408, TO_DATE('12/10/2021' , 'DD/MM/YYYY'), TO_DATE('16:00' , 'hh24:mi'), 1013, (SELECT date_of_birth FROM pet WHERE pet_id = 1013), 2209, 'Y', TO_DATE('8/10/2021','DD/MM/YYYY'), 0);

INSERT INTO appointment
      (app_id, app_date, app_timeslot, pet_id, pet_date_of_birth, doctor_id, is_app_cancelled, app_fee)
VALUES(105478, TO_DATE('26/10/2021' , 'DD/MM/YYYY'), TO_DATE('12:30' , 'hh24:mi'), 1010, (SELECT date_of_birth FROM pet WHERE pet_id = 1010), 2210, 'N', 10);

ALTER TABLE appointment
ADD CONSTRAINT app_weekday_app_ck CHECK ((to_char(app_date, 'DAY') LIKE 'MONDAY%') OR (to_char(app_date, 'DAY') LIKE 'FRIDAY%')) ENABLE NOVALIDATE;    

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1000 AND doctor_id = 2201 AND TRUNC(app_date) = TO_DATE('05/08/2021','DD/MM/YYYY')), 'Bring him Tuesdays 10 to 12.pm');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1003 AND doctor_id = 2200 AND TRUNC(app_date) = TO_DATE('05/08/2021','DD/MM/YYYY')), 'Get AA from Smiths Pharmacy');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1004 AND doctor_id = 2201 AND TRUNC(app_date) = TO_DATE('09/08/2021','DD/MM/YYYY')), 'Claws clipped, cleaned inside ears');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1015 AND doctor_id = 2212 AND TRUNC(app_date) = TO_DATE('13/08/2021','DD/MM/YYYY')), 'Ripped claw out and became infected, cleaned, wrapped and prescibed metronidazole');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1005 AND doctor_id = 2206 AND TRUNC(app_date) = TO_DATE('02/09/2021','DD/MM/YYYY')), 'Lethargic, diet change and playtime suggested');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1000 AND doctor_id = 2201 AND TRUNC(app_date) = TO_DATE('06/09/2021','DD/MM/YYYY')), 'Needs socialisation treats');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1011 AND doctor_id = 2210 AND TRUNC(app_date) = TO_DATE('06/09/2021','DD/MM/YYYY')), 'Concussion from running into wall, prescribed tramadol');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1012 AND doctor_id = 2208 AND TRUNC(app_date) = TO_DATE('10/09/2021','DD/MM/YYYY')), 'Allergy to flea bites, treat with anti histamine and flea treatment for regular sized dog');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1012 AND doctor_id = 2208 AND TRUNC(app_date) = TO_DATE('10/09/2021','DD/MM/YYYY')), 'Needs worming treatment');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1008 AND doctor_id = 2213 AND TRUNC(app_date) = TO_DATE('10/09/2021','DD/MM/YYYY')), 'Regular checkup, all fine');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1002 AND doctor_id = 2203 AND TRUNC(app_date) = TO_DATE('29/09/2021','DD/MM/YYYY')), 'Needs socialisation treats & worming treatment');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1007 AND doctor_id = 2203 AND TRUNC(app_date) = TO_DATE('04/10/2021','DD/MM/YYYY')), 'Cateracts developing, referred to specialist');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1014 AND doctor_id = 2213 AND TRUNC(app_date) = TO_DATE('18/08/2021','DD/MM/YYYY')), 'Nervous, recommended socialisation');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1006 AND doctor_id = 2204 AND TRUNC(app_date) = TO_DATE('07/10/2021','DD/MM/YYYY')), 'Take Park walks every evening');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1006 AND doctor_id = 2204 AND TRUNC(app_date) = TO_DATE('07/10/2021','DD/MM/YYYY')), 'Overgrown Skin');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1005 AND doctor_id = 2213 AND TRUNC(app_date) = TO_DATE('05/10/2021','DD/MM/YYYY')), 'Dog seems fine, no visible problems, suggested coming back in a week if problems persist.');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1002 AND doctor_id = 2203 AND TRUNC(app_date) = TO_DATE('11/10/2021','DD/MM/YYYY')), 'Surgery on 21-Nov-21');

INSERT INTO diagnosis
	  (app_id, diag_desc)
VALUES((SELECT app_id FROM appointment WHERE pet_id = 1010 AND doctor_id = 2210 AND TRUNC(app_date) = TO_DATE('26/10/2021','DD/MM/YYYY')), 'Agressive rash. treat with Rash Cream');

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105078, 22004, (SELECT app_date FROM appointment WHERE app_id = 105078) , (SELECT app_timeslot FROM appointment WHERE app_id = 105078));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105078, 22011, (SELECT app_date FROM appointment WHERE app_id = 105078), (SELECT app_timeslot FROM appointment WHERE app_id = 105078));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105091, 22012, (SELECT app_date FROM appointment WHERE app_id = 105091) ,(SELECT app_timeslot FROM appointment WHERE app_id = 105091));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105091, 22001, (SELECT app_date FROM appointment WHERE app_id = 105091), (SELECT app_timeslot FROM appointment WHERE app_id = 105091));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105096, 22003, (SELECT app_date FROM appointment WHERE app_id = 105096), (SELECT app_timeslot FROM appointment WHERE app_id = 105096));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105096, 22001, (SELECT app_date FROM appointment WHERE app_id = 105096), (SELECT app_timeslot FROM appointment WHERE app_id = 105096));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104962, 22010, (SELECT app_date FROM appointment WHERE app_id = 104962), (SELECT app_timeslot FROM appointment WHERE app_id = 104962));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104962, 22013, (SELECT app_date FROM appointment WHERE app_id = 104962), (SELECT app_timeslot FROM appointment WHERE app_id = 104962));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105229, 22003, (SELECT app_date FROM appointment WHERE app_id = 105229), (SELECT app_timeslot FROM appointment WHERE app_id = 105229));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105121, 22001, (SELECT app_date FROM appointment WHERE app_id = 105121), (SELECT app_timeslot FROM appointment WHERE app_id = 105121));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105187, 22000, (SELECT app_date FROM appointment WHERE app_id = 105187) ,(SELECT app_timeslot FROM appointment WHERE app_id = 105187));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105187, 22010, (SELECT app_date FROM appointment WHERE app_id = 105187), (SELECT app_timeslot FROM appointment WHERE app_id = 105187));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105235, 22011, (SELECT app_date FROM appointment WHERE app_id = 105235), (SELECT app_timeslot FROM appointment WHERE app_id = 105235));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105235, 22003, (SELECT app_date FROM appointment WHERE app_id = 105235), (SELECT app_timeslot FROM appointment WHERE app_id = 105235));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104821, 22005, (SELECT app_date FROM appointment WHERE app_id = 104821), (SELECT app_timeslot FROM appointment WHERE app_id = 104821));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104876, 22013, (SELECT app_date FROM appointment WHERE app_id = 104876), (SELECT app_timeslot FROM appointment WHERE app_id = 104876));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104876, 22007, (SELECT app_date FROM appointment WHERE app_id = 104876), (SELECT app_timeslot FROM appointment WHERE app_id = 104876));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104881, 22006, (SELECT app_date FROM appointment WHERE app_id = 104881), (SELECT app_timeslot FROM appointment WHERE app_id = 104881));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104901, 22009, (SELECT app_date FROM appointment WHERE app_id = 104901), (SELECT app_timeslot FROM appointment WHERE app_id = 104901));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104945, 22008, (SELECT app_date FROM appointment WHERE app_id = 104945), (SELECT app_timeslot FROM appointment WHERE app_id = 104945));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104945, 22001, (SELECT app_date FROM appointment WHERE app_id = 104945), (SELECT app_timeslot FROM appointment WHERE app_id = 104945));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(104999, 22011, (SELECT app_date FROM appointment WHERE app_id = 104999), (SELECT app_timeslot FROM appointment WHERE app_id = 104999));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105002, 22006, (SELECT app_date FROM appointment WHERE app_id = 105002), (SELECT app_timeslot FROM appointment WHERE app_id = 105002));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105080, 22000, (SELECT app_date FROM appointment WHERE app_id = 105080), (SELECT app_timeslot FROM appointment WHERE app_id = 105080));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105080, 22010, (SELECT app_date FROM appointment WHERE app_id = 105080), (SELECT app_timeslot FROM appointment WHERE app_id = 105080));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105099, 22003, (SELECT app_date FROM appointment WHERE app_id = 105099), (SELECT app_timeslot FROM appointment WHERE app_id = 105099));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105099, 22005, (SELECT app_date FROM appointment WHERE app_id = 105099), (SELECT app_timeslot FROM appointment WHERE app_id = 105099));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105171, 22010, (SELECT app_date FROM appointment WHERE app_id = 105171), (SELECT app_timeslot FROM appointment WHERE app_id = 105171));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105206, 22012, (SELECT app_date FROM appointment WHERE app_id = 105206), (SELECT app_timeslot FROM appointment WHERE app_id = 105206));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105171, 22000, (SELECT app_date FROM appointment WHERE app_id = 105171), (SELECT app_timeslot FROM appointment WHERE app_id = 105171));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105398, 22008, (SELECT app_date FROM appointment WHERE app_id = 105398), (SELECT app_timeslot FROM appointment WHERE app_id = 105398));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105408, 22009, (SELECT app_date FROM appointment WHERE app_id = 105408), (SELECT app_timeslot FROM appointment WHERE app_id = 105408));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105408, 22004, (SELECT app_date FROM appointment WHERE app_id = 105408), (SELECT app_timeslot FROM appointment WHERE app_id = 105408));

INSERT INTO nurse_appointment
	  (app_id, nurse_id, app_date, app_timeslot)
VALUES(105478, 22010, (SELECT app_timeslot FROM appointment WHERE app_id = 105478), (SELECT app_timeslot FROM appointment WHERE app_id = 105478));

INSERT INTO prescription
	  (diag_id, drug_id, pres_dose, pres_dose_unit, pres_amount, pres_guidance)
VALUES(10001, (SELECT drug_id FROM drug WHERE name LIKE UPPER('%AA%')), 100, 'mg', 30,'One 100mg table to be taken once a day, with food');

INSERT INTO prescription
	  (diag_id, drug_id, pres_dose, pres_dose_unit, pres_amount, pres_guidance)
VALUES(10003, (SELECT drug_id FROM drug WHERE name LIKE UPPER('%metro%')), 15, 'mg',15,'One 15mg table to be taken per day for 15 days. Do not give to animal on an empty stomach.');

INSERT INTO prescription
	  (diag_id, drug_id, pres_dose, pres_dose_unit, pres_amount, pres_guidance)
VALUES(10006, (SELECT drug_id FROM drug WHERE name LIKE UPPER('%trama%')), 10, 'mg', 4, 'HALF (1/2) a table to be given once a day for 7 days. Ensure plenty of water is available throughtout the day. If you notice any tiredness or dizyness or any other side effects, contact your vet immediately. ');

INSERT INTO prescription
	  (diag_id, drug_id, pres_dose, pres_dose_unit, pres_amount, pres_guidance)
VALUES(10007, (SELECT drug_id FROM drug WHERE name LIKE UPPER('%flea%')), 1, 'regular', 6,'Break neck on capsule and apply direcylu to back of neck between the shoulder blades, once a month for 6 months' );

INSERT INTO prescription
	  (diag_id, drug_id, pres_dose, pres_dose_unit, pres_amount, pres_guidance)
VALUES(10007, (SELECT drug_id FROM drug WHERE name LIKE UPPER('%anti hist%')), 5, 'mg', 14,'TWO tablets to be taken each day. Once in the morning, and once before sleep, for 7 days. If symptoms continue, contact your vet' );

INSERT INTO prescription
	  (diag_id, drug_id, pres_dose, pres_dose_unit, pres_amount, pres_guidance)
VALUES(10008, (SELECT drug_id FROM drug WHERE name LIKE UPPER('%worm%')), 1, 'mg', 14,'Apply ONE GRADUATION of paste from the syringe directly into you pets mouth, once a day for 2 weeks');

INSERT INTO prescription
	  (diag_id, drug_id, pres_dose, pres_dose_unit, pres_amount, pres_guidance)
VALUES(10009, (SELECT drug_id FROM drug WHERE name LIKE UPPER('%worm%')), 1, 'mg', 28,'Apply TWO GRADUATIONS of paste from the syringe directly into you pets mouth, once a day for 2 weeks');

INSERT INTO prescription
	  (diag_id, drug_id, pres_dose, pres_dose_unit, pres_amount, pres_guidance)
VALUES(10014, (SELECT drug_id FROM drug WHERE name LIKE UPPER('%hydrocortisone%')), 50, 'ml', 1, 'Apply TWO pea sized amounts to the effected skin each day until the rash disappears');

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%AA%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%Smiths%')), 100, 'mg', 1.50 );

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%AA%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%Smiths%')), 200, 'mg', 2.75 );

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%AA%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%ringo%')), 200, 'mg', 2.50 );

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%AA%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%doot%')), 100, 'mg', 1.45 );

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%metro%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%mega%')), 15, 'mg', 3.00 );

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%metro%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%mega%')), 50, 'mg', 9.00 );

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%metro%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%Smith%')), 5, 'mg', 1.00 );

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%metro%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%Smith%')), 15, 'mg', 2.75 );


INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%metro%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%ringo%')), 5, 'mg', 0.80 );

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%worm%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%pet drug%')), 1, 'mg', 6);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%worm%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%schloyds%')), 1, 'mg', 10);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%worm%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%mega%')), 1, 'mg', 6);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%flea%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%mega%')), 1, 'regular size', 8);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%flea%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%mega%')), 1, 'large size', 12);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%flea%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%smith%')), 1, 'regular size', 8);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%flea%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%smith%')), 1, 'large size', 12);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%anti%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%ringo%')), 5, 'mg', 1.00);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%anti%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%ringo%')), 10, 'mg', 2.00);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%anti%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%mega%')), 5, 'mg', 1.20);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%anti%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%doot%')), 5, 'mg', 0.80);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%hydrocortisone%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%doot%')), 50, 'ml', 7);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%hydrocortisone%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%doot%')), 10, 'ml', 1.50);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%hydrocortisone%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%mega%')), 50, 'ml', 7.99);

INSERT INTO drug_pharmacy
	  (drug_id, pharmacy_id, pharmacy_available_dose, pharmacy_dose_unit, drug_cost_per_dose_gbp)
VALUES((SELECT drug_id FROM drug WHERE name LIKE UPPER('%hydrocortisone%')),(SELECT pharmacy_id FROM pharmacy WHERE name LIKE UPPER('%schloyds%')), 25, 'ml', 3.25);

