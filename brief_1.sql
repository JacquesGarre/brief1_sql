-- 0) creer la base de données "data" et la table "client_0" 
-- comportant toutes les variables sauf la dernière

CREATE DATABASE IF NOT EXISTS data;

USE data;

CREATE TABLE client_0 (  
    ID INT PRIMARY KEY,
    SHIPPING_MODE VARCHAR(255),
    SHIPPING_PRICE VARCHAR(255),
    WARRANTIES_FLG VARCHAR(255),
    WARRANTIES_PRICE VARCHAR(255),
    CARD_PAYMENT VARCHAR(255),
    COUPON_PAYMENT VARCHAR(255),
    RSP_PAYMENT VARCHAR(255),
    WALLET_PAYMENT VARCHAR(255),
    PRICECLUB_STATUS VARCHAR(255),
    REGISTRATION_DATE VARCHAR(255),
    PURCHASE_COUNT VARCHAR(255),
    BUYER_BIRTHDAY_DATE VARCHAR(255),
    BUYER_DEPARTMENT VARCHAR(255),
    BUYING_DATE VARCHAR(255),
    SELLER_SCORE_COUNT VARCHAR(255),
    SELLER_SCORE_AVERAGE VARCHAR(255),
    SELLER_COUNTRY VARCHAR(255),
    SELLER_DEPARTMENT VARCHAR(255),
    PRODUCT_TYPE VARCHAR(255),
    PRODUCT_FAMILY VARCHAR(255),
    ITEM_PRICE VARCHAR(255),
    CLEF VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'C:/Users/Utilisateur/Desktop/FORMATION/S5_1002-1602_/1002_lundi/Base_eval.csv' 
INTO TABLE data.client_0
FIELDS TERMINATED BY ';' ENCLOSED BY '"'  
LINES TERMINATED BY '\n' IGNORE 1 LINES;


-- 1) combien de doublons avons-nous
SELECT SUM(T1.nb_doublon) AS nb_total_doublons 
FROM
(SELECT COUNT(*) AS nb_doublon, 
    ID,
    SHIPPING_MODE,
    SHIPPING_PRICE,
    WARRANTIES_FLG,
    WARRANTIES_PRICE,
    CARD_PAYMENT,
    COUPON_PAYMENT,
    RSP_PAYMENT,
    WALLET_PAYMENT,
    PRICECLUB_STATUS,
    REGISTRATION_DATE,
    PURCHASE_COUNT,
    BUYER_BIRTHDAY_DATE,
    BUYER_DEPARTMENT,
    BUYING_DATE,
    SELLER_SCORE_COUNT,
    SELLER_SCORE_AVERAGE,
    SELLER_COUNTRY,
    SELLER_DEPARTMENT,
    PRODUCT_TYPE,
    PRODUCT_FAMILY,
    ITEM_PRICE
FROM client_0
GROUP BY 
    SHIPPING_MODE,
    SHIPPING_PRICE,
    WARRANTIES_FLG,
    WARRANTIES_PRICE,
    CARD_PAYMENT,
    COUPON_PAYMENT,
    RSP_PAYMENT,
    WALLET_PAYMENT,
    PRICECLUB_STATUS,
    REGISTRATION_DATE,
    PURCHASE_COUNT,
    BUYER_BIRTHDAY_DATE,
    BUYER_DEPARTMENT,
    BUYING_DATE,
    SELLER_SCORE_COUNT,
    SELLER_SCORE_AVERAGE,
    SELLER_COUNTRY,
    SELLER_DEPARTMENT,
    PRODUCT_TYPE,
    PRODUCT_FAMILY,
    ITEM_PRICE
HAVING COUNT(*) > 1) T1;

2) supprimer les doublons
DELETE T1 
FROM client_0 AS T1,
(SELECT COUNT(*) AS nb_doublon, 
    ID,
    SHIPPING_MODE,
    SHIPPING_PRICE,
    WARRANTIES_FLG,
    WARRANTIES_PRICE,
    CARD_PAYMENT,
    COUPON_PAYMENT,
    RSP_PAYMENT,
    WALLET_PAYMENT,
    PRICECLUB_STATUS,
    REGISTRATION_DATE,
    PURCHASE_COUNT,
    BUYER_BIRTHDAY_DATE,
    BUYER_DEPARTMENT,
    BUYING_DATE,
    SELLER_SCORE_COUNT,
    SELLER_SCORE_AVERAGE,
    SELLER_COUNTRY,
    SELLER_DEPARTMENT,
    PRODUCT_TYPE,
    PRODUCT_FAMILY,
    ITEM_PRICE
FROM client_0
GROUP BY 
    SHIPPING_MODE,
    SHIPPING_PRICE,
    WARRANTIES_FLG,
    WARRANTIES_PRICE,
    CARD_PAYMENT,
    COUPON_PAYMENT,
    RSP_PAYMENT,
    WALLET_PAYMENT,
    PRICECLUB_STATUS,
    REGISTRATION_DATE,
    PURCHASE_COUNT,
    BUYER_BIRTHDAY_DATE,
    BUYER_DEPARTMENT,
    BUYING_DATE,
    SELLER_SCORE_COUNT,
    SELLER_SCORE_AVERAGE,
    SELLER_COUNTRY,
    SELLER_DEPARTMENT,
    PRODUCT_TYPE,
    PRODUCT_FAMILY,
    ITEM_PRICE
HAVING COUNT(*) > 1) AS T2
WHERE T1.ID > T2.ID
AND T1.SHIPPING_MODE = T2.SHIPPING_MODE
AND T1.SHIPPING_PRICE = T2.SHIPPING_PRICE
AND T1.WARRANTIES_FLG = T2.WARRANTIES_FLG
AND T1.WARRANTIES_PRICE = T2.WARRANTIES_PRICE
AND T1.CARD_PAYMENT = T2.CARD_PAYMENT
AND T1.COUPON_PAYMENT = T2.COUPON_PAYMENT
AND T1.RSP_PAYMENT = T2.RSP_PAYMENT
AND T1.WALLET_PAYMENT = T2.WALLET_PAYMENT
AND T1.PRICECLUB_STATUS = T2.PRICECLUB_STATUS
AND T1.REGISTRATION_DATE = T2.REGISTRATION_DATE
AND T1.PURCHASE_COUNT = T2.PURCHASE_COUNT
AND T1.BUYER_BIRTHDAY_DATE = T2.BUYER_BIRTHDAY_DATE
AND T1.BUYER_DEPARTMENT = T2.BUYER_DEPARTMENT
AND T1.BUYING_DATE = T2.BUYING_DATE
AND T1.SELLER_SCORE_COUNT = T2.SELLER_SCORE_COUNT
AND T1.SELLER_SCORE_AVERAGE = T2.SELLER_SCORE_AVERAGE 
AND T1.SELLER_COUNTRY = T2.SELLER_COUNTRY
AND T1.SELLER_DEPARTMENT = T2.SELLER_DEPARTMENT
AND T1.PRODUCT_TYPE = T2.PRODUCT_TYPE 
AND T1.PRODUCT_FAMILY = T2.PRODUCT_FAMILY
AND T1.ITEM_PRICE = T2.ITEM_PRICE;

-- 3) combien de vendeurs étrangers avons-nous
SELECT COUNT(*) AS nb_vendeurs_etrangers FROM client_0 WHERE SELLER_COUNTRY NOT LIKE "%FRANCE%";

-- 4) creer la table vendeur1 composée des vendeurs étrangers, 
-- la table vendeur2 composée des vendeurs français 
-- et la table vendeur3 composées des vendeurs français basés en métropole
CREATE TABLE vendeur1 IF NOT EXISTS
SELECT * FROM client_0 WHERE SELLER_COUNTRY NOT LIKE '%FRANCE%';
CREATE TABLE vendeur2 IF NOT EXISTS
SELECT * FROM client_0 WHERE SELLER_COUNTRY LIKE '%FRANCE%';
CREATE TABLE vendeur3 IF NOT EXISTS
SELECT * FROM client_0 WHERE SELLER_COUNTRY LIKE '%METROPOLITAN%';


-- 5) quelle est la probabilité pour un vendeur français d'avoir
--  un bon score si la vente a lieu un lundi
SELECT T1.nb_vendeurs / (SELECT COUNT(*) AS nb_total FROM vendeur2) AS PROBABILITE
FROM
(SELECT 
    COUNT(*) AS nb_vendeurs,
    DAYOFWEEK(
        CONCAT(
            SUBSTR(BUYING_DATE, INSTR(BUYING_DATE, '-')+1, LENGTH(BUYING_DATE)), 
            '-', 
            CASE SUBSTR(BUYING_DATE, 1, INSTR(BUYING_DATE, '-')-1) 
                WHEN 'janv' THEN '01'
                WHEN 'fï¿½vr' THEN '02'
                WHEN 'mars' THEN '03'
                WHEN 'avr' THEN '04'
                WHEN 'mai' THEN '05'
                WHEN 'juin' THEN '06'
                WHEN 'juil' THEN '07'
                WHEN 'aoï¿½t' THEN '08'
                WHEN 'sept' THEN '09'
                WHEN 'oct' THEN '10'
                WHEN 'nov' THEN '11'
                WHEN 'dec' THEN '12'
            END,
            '-01'
        ) 
    ) AS jour
    FROM vendeur2 WHERE 
    DAYOFWEEK(
    CONCAT(
        SUBSTR(BUYING_DATE, INSTR(BUYING_DATE, '-')+1, LENGTH(BUYING_DATE)), 
        '-', 
        CASE SUBSTR(BUYING_DATE, 1, INSTR(BUYING_DATE, '-')-1) 
            WHEN 'janv' THEN '01'
            WHEN 'fï¿½vr' THEN '02'
            WHEN 'mars' THEN '03'
            WHEN 'avr' THEN '04'
            WHEN 'mai' THEN '05'
            WHEN 'juin' THEN '06'
            WHEN 'juil' THEN '07'
            WHEN 'aoï¿½t' THEN '08'
            WHEN 'sept' THEN '09'
            WHEN 'oct' THEN '10'
            WHEN 'nov' THEN '11'
            WHEN 'dec' THEN '12'
        END,
        '-01'
        ) 
    ) = 2 -- 2 pour Lundi
    AND SELLER_SCORE_COUNT LIKE '%100000<1000000%'
) T1;

-- 6) quel est le montant total des 
-- articles vendus par famille de produits

-- 7) Entre nationaux et étrangers 
-- qui sont ceux qui ont le plus vendu d'articles?


-- 8) Créer la table produit_1 (à partir de la table vendeur1) 
-- comportant le montant des types de produits par famille de produits
CREATE TABLE produit_1
SELECT ITEM_PRICE, PRODUCT_FAMILY 
FROM vendeur1 GROUP BY ITEM_PRICE, PRODUCT_FAMILY;


-- 9) Créer la table produit_2 (à partir de la table vendeur2) 
-- comportant le montant des types de produits par famille de produits
CREATE TABLE produit_2
SELECT ITEM_PRICE, PRODUCT_FAMILY 
FROM vendeur2 GROUP BY ITEM_PRICE, PRODUCT_FAMILY;

-- 10) Créer la table produits (à partir des tables vendeur1 & vendeur2) comportant 
-- le montant des types de produits par famille de produits : pas de doublons svp
CREATE TABLE produits
SELECT ITEM_PRICE, PRODUCT_FAMILY 
FROM vendeur1 GROUP BY ITEM_PRICE, PRODUCT_FAMILY
UNION
SELECT ITEM_PRICE, PRODUCT_FAMILY 
FROM vendeur2 GROUP BY ITEM_PRICE, PRODUCT_FAMILY;

-- 11) En considérant que le deuxième achat effectué par un client constitue
--  un complément d'achat et non un doublon, l'entreprise vous demande de créer
--   à partir du fichier csv de départ une nouvelle table nommée vente_finale
--    en affichant pas les ventes complémentaires. 
--    Toutefois les montants affectés à ces ventes doivent figurer dans la nouvelles table.

