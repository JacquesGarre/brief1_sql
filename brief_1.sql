-- 0) creer la base de données "data" et la table "client_0" 
-- comportant toutes les variables sauf la dernière

CREATE DATABASE IF NOT EXISTS data;

USE data;

DROP TABLE IF EXISTS client_0;

CREATE TABLE client_0 (  
    ID VARCHAR(255),
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
    _KEY VARCHAR(255)
) CHARACTER SET latin1; -- windows-1252/WinLatin 1

LOAD DATA LOCAL INFILE 'C:/Users/jcqsg/Desktop/brief1_sql/Base_eval.csv' 
INTO TABLE data.client_0 
FIELDS TERMINATED BY ';' ENCLOSED BY '"'  
LINES TERMINATED BY '\n' IGNORE 1 LINES
(   
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
    ITEM_PRICE,
    _KEY,
    @dummy
);




-- 1) combien de doublons avons-nous

SELECT 
    COUNT(*) AS NB_DOUBLONS 
FROM 
    (
        SELECT 
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
            ITEM_PRICE,
            _KEY,
            COUNT(*)
        FROM 
            client_0
        GROUP BY 
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
            ITEM_PRICE,
            _KEY
        HAVING COUNT(*) > 1
    ) T1;




-- 2) supprimer les doublons

CREATE TABLE tmp AS
SELECT 
    * 
FROM 
    client_0 
GROUP BY 
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
    ITEM_PRICE,
    _KEY;
DROP TABLE client_0;
RENAME TABLE tmp TO client_0;




-- 3) combien de vendeurs étrangers avons-nous

SELECT COUNT(*) AS nb_vendeurs_etrangers FROM client_0 WHERE SELLER_COUNTRY NOT LIKE "%FRANCE%";




-- 4) creer la table vendeur1 composée des vendeurs étrangers,
-- la table vendeur2 composée des vendeurs français 
-- et la table vendeur3 composées des vendeurs français basés en métropole

CREATE TABLE vendeur1 AS
SELECT * FROM client_0 WHERE SELLER_COUNTRY NOT LIKE "%FRANCE%";
CREATE TABLE vendeur2 AS
SELECT * FROM client_0 WHERE SELLER_COUNTRY LIKE "%FRANCE%";
CREATE TABLE vendeur3 AS
SELECT * FROM client_0 WHERE SELLER_COUNTRY LIKE "%METROPOLITAN%";




-- 5) quelle est la probabilité pour un vendeur français d'avoir
--  un bon score si la vente a lieu un lundi

SELECT 
    T1.nb_vendeurs / (SELECT COUNT(*) AS nb_total FROM vendeur2) AS PROBABILITE
FROM
    (
        SELECT 
            COUNT(*) AS nb_vendeurs
        FROM 
            vendeur2 
        WHERE 
        DAYOFWEEK(
            CONCAT(
                SUBSTR(BUYING_DATE, INSTR(BUYING_DATE, '-')+1, LENGTH(BUYING_DATE)), 
                '-', 
                CASE SUBSTR(BUYING_DATE, 1, INSTR(BUYING_DATE, '-')-1) 
                    WHEN 'janv' THEN '01'
                    WHEN 'févr' THEN '02'
                    WHEN 'mars' THEN '03'
                    WHEN 'avr' THEN '04'
                    WHEN 'mai' THEN '05'
                    WHEN 'juin' THEN '06'
                    WHEN 'juil' THEN '07'
                    WHEN 'août' THEN '08'
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

SELECT
    PRODUCT_FAMILY,
	SUM(
        CASE 
            WHEN INSTR(ITEM_PRICE, '<') = 1 OR INSTR(ITEM_PRICE, '>') = 1 THEN SUBSTR(ITEM_PRICE, 2, LENGTH(ITEM_PRICE))
            WHEN INSTR(ITEM_PRICE, '<') > 1 THEN (SUBSTR(ITEM_PRICE, INSTR(ITEM_PRICE, '<') + 1, LENGTH(ITEM_PRICE)) + SUBSTR(ITEM_PRICE, 1, INSTR(ITEM_PRICE, '<')))/2
            ELSE ITEM_PRICE
        END
    ) AS MONTANT_TOTAL_VENDU
FROM client_0
GROUP BY PRODUCT_FAMILY;




-- 7) Entre nationaux et étrangers 
-- qui sont ceux qui ont le plus vendu d'articles?

SELECT 
    CASE
        WHEN (SELECT COUNT(*) FROM vendeur2) > (SELECT COUNT(*) FROM vendeur1) THEN 'Vendeurs nationaux'
        WHEN (SELECT COUNT(*) FROM vendeur2) = (SELECT COUNT(*) FROM vendeur1) THEN 'Pareil'
        ELSE 'Vendeurs étrangers'
    END AS QUI_A_LE_PLUS_DE_VENTES;




-- 8) Créer la table produit_1 (à partir de la table vendeur1) 
-- comportant le montant des types de produits par famille de produits

CREATE TABLE produit_1 
SELECT PRODUCT_FAMILY, ITEM_PRICE
FROM vendeur1 GROUP BY PRODUCT_FAMILY, ITEM_PRICE;




-- 9) Créer la table produit_2 (à partir de la table vendeur2) 
-- comportant le montant des types de produits par famille de produits

CREATE TABLE produit_2 
SELECT PRODUCT_FAMILY, ITEM_PRICE
FROM vendeur2 GROUP BY PRODUCT_FAMILY, ITEM_PRICE;




-- 10) Créer la table produits (à partir des tables vendeur1 & vendeur2) comportant 
-- le montant des types de produits par famille de produits : pas de doublons svp

CREATE TABLE produits
SELECT PRODUCT_FAMILY,ITEM_PRICE
FROM vendeur1 GROUP BY PRODUCT_FAMILY,ITEM_PRICE
UNION
SELECT PRODUCT_FAMILY,ITEM_PRICE
FROM vendeur2 GROUP BY PRODUCT_FAMILY,ITEM_PRICE;




-- 11) En considérant que le deuxième achat effectué par un client constitue
--  un complément d'achat et non un doublon, l'entreprise vous demande de créer
--   à partir du fichier csv de départ une nouvelle table nommée vente_finale
--en affichant pas les ventes complémentaires. 
--    Toutefois les montants affectés à ces ventes doivent figurer dans la nouvelles table.

CREATE TABLE vente_finale AS
SELECT
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
    CASE 
        WHEN 
            INSTR(CONCAT(
                SUM(
                    CASE 
                        WHEN INSTR(ITEM_PRICE, '<') = 1 OR INSTR(ITEM_PRICE, '>') = 1 THEN 0
                        WHEN INSTR(ITEM_PRICE, '<') > 1 THEN SUBSTR(ITEM_PRICE, 1, INSTR(ITEM_PRICE, '<')-1)
                        WHEN INSTR(ITEM_PRICE, '>') > 1 THEN SUBSTR(ITEM_PRICE, 1, INSTR(ITEM_PRICE, '>')-1)
                        ELSE ITEM_PRICE
                    END
                ),
                '<',
                SUM(
                    CASE 
                        WHEN INSTR(ITEM_PRICE, '<') = 1 THEN SUBSTR(ITEM_PRICE, 2, LENGTH(ITEM_PRICE))
                        WHEN INSTR(ITEM_PRICE, '<') > 1 THEN SUBSTR(ITEM_PRICE, INSTR(ITEM_PRICE, '<')+1, LENGTH(ITEM_PRICE))
                        WHEN INSTR(ITEM_PRICE, '>') > 1 THEN SUBSTR(ITEM_PRICE, INSTR(ITEM_PRICE, '>')+1, LENGTH(ITEM_PRICE))
                        ELSE ITEM_PRICE
                    END
                )
            ), '0') = 1
        THEN
            SUBSTR(CONCAT(
                SUM(
                    CASE 
                        WHEN INSTR(ITEM_PRICE, '<') = 1 OR INSTR(ITEM_PRICE, '>') = 1 THEN 0
                        WHEN INSTR(ITEM_PRICE, '<') > 1 THEN SUBSTR(ITEM_PRICE, 1, INSTR(ITEM_PRICE, '<')-1)
                        WHEN INSTR(ITEM_PRICE, '>') > 1 THEN SUBSTR(ITEM_PRICE, 1, INSTR(ITEM_PRICE, '>')-1)
                        ELSE ITEM_PRICE
                    END
                ),
                '<',
                SUM(
                    CASE 
                        WHEN INSTR(ITEM_PRICE, '<') = 1 THEN SUBSTR(ITEM_PRICE, 2, LENGTH(ITEM_PRICE))
                        WHEN INSTR(ITEM_PRICE, '<') > 1 THEN SUBSTR(ITEM_PRICE, INSTR(ITEM_PRICE, '<')+1, LENGTH(ITEM_PRICE))
                        WHEN INSTR(ITEM_PRICE, '>') > 1 THEN SUBSTR(ITEM_PRICE, INSTR(ITEM_PRICE, '>')+1, LENGTH(ITEM_PRICE))
                        ELSE ITEM_PRICE
                    END
                )
            ), 2, LENGTH(ITEM_PRICE))
        ELSE
            CONCAT(
                SUM(
                    CASE 
                        WHEN INSTR(ITEM_PRICE, '<') = 1 OR INSTR(ITEM_PRICE, '>') = 1 THEN 0
                        WHEN INSTR(ITEM_PRICE, '<') > 1 THEN SUBSTR(ITEM_PRICE, 1, INSTR(ITEM_PRICE, '<')-1)
                        WHEN INSTR(ITEM_PRICE, '>') > 1 THEN SUBSTR(ITEM_PRICE, 1, INSTR(ITEM_PRICE, '>')-1)
                        ELSE ITEM_PRICE
                    END
                ),
                '<',
                SUM(
                    CASE 
                        WHEN INSTR(ITEM_PRICE, '<') = 1 THEN SUBSTR(ITEM_PRICE, 2, LENGTH(ITEM_PRICE))
                        WHEN INSTR(ITEM_PRICE, '<') > 1 THEN SUBSTR(ITEM_PRICE, INSTR(ITEM_PRICE, '<')+1, LENGTH(ITEM_PRICE))
                        WHEN INSTR(ITEM_PRICE, '>') > 1 THEN SUBSTR(ITEM_PRICE, INSTR(ITEM_PRICE, '>')+1, LENGTH(ITEM_PRICE))
                        ELSE ITEM_PRICE
                    END
                )
            )
        END
    AS ITEM_PRICE,
    _KEY
FROM client_0 GROUP BY ID;




-- AFTER READING THIS
--     _____
--    [IIIII]
--     )"""(
--    /     \
--   /       \
--   |`-...-'|
--   |aspirin|
-- _ |`-...-'j    _
-- (\)`-.___.(I) _(/)
--   (I)  (/)(I)(\)
--     (I)        
