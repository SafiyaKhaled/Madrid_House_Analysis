-- 1️⃣	Total Properties	إجمالي عدد العقارات المعروضة
select * 
from Madrid_data

select count(*) as Total_Properties_number
from madrid_data

-- 2️⃣	Average Buy Price	متوسط السعر الإجمالي للعقارات
select avg(buy_price) as Average_Buy_Price
from madrid_data

-- Average Buy Price for each district
select district, avg(buy_price) as Average_Price_District,
	   avg(buy_price_by_area) as Average_Price_area_District,
	   count(*) as Properties_number_district,
	   COUNT(*) * 100.0 / (SELECT COUNT(*) FROM madrid_data) AS Percent_of_total_properties,
	   avg(sq_mt_built) as Average_area_District
from madrid_data
group by district
HAVING COUNT(*) >= 20
order by avg(buy_price) desc


SELECT 
  district,
  COUNT(*) AS total_properties,

  AVG(buy_price) AS avg_price,
  AVG(buy_price_by_area) AS avg_price_per_m2,
  AVG(CASE WHEN sq_mt_built IS NOT NULL THEN sq_mt_built END) AS avg_size,

  SUM(CASE WHEN has_lift = 'TRUE' THEN 1 ELSE 0 END) AS with_lift,
  SUM(CASE WHEN has_parking = 'TRUE' THEN 1 ELSE 0 END) AS with_parking,

  ROUND(SUM(CASE WHEN has_lift = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS percent_with_lift,
  ROUND(SUM(CASE WHEN has_parking = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS percent_with_parking

FROM madrid_data
WHERE has_lift IS NOT NULL AND sq_mt_built IS NOT NULL
GROUP BY district
HAVING COUNT(*) >= 10
ORDER BY avg_price DESC;


-- 3️⃣	Median Price per m²	سعر المتر المربع في الوسط
-- 4️⃣	Most Expensive District (per m²)	الحي الأغلى حسب سعر المتر
-- 5️⃣	Top House Type (by count)	أكثر نوع عقار منتشر
-- 6️⃣	% of Properties Needing Renewal	نسبة العقارات اللي محتاجة تجديد
-- 7️⃣	% with Parking	نسبة العقارات اللي فيها جراج
-- 8️⃣	Average Area per Room	متوسط المساحة لكل غرفة
-- 9️⃣	Properties over 500k	عدد العقارات اللي سعرها فوق 500 ألف يورو
-- 🔟	New Developments Share	نسبة العقارات الجديدة (is_new_development=True)

CREATE VIEW property_summary_by_district AS
SELECT 
  district,
  COUNT(*) AS total_properties,

  -- الأسعار والمساحة
  AVG(buy_price) AS avg_price,
  AVG(buy_price_by_area) AS avg_price_per_m2,
  AVG(CASE WHEN sq_mt_built IS NOT NULL THEN sq_mt_built END) AS avg_size,

  -- الخصائص
  SUM(CASE WHEN has_lift = 'TRUE' THEN 1 ELSE 0 END) AS with_lift,
  SUM(CASE WHEN has_parking = 'TRUE' THEN 1 ELSE 0 END) AS with_parking,
  SUM(CASE WHEN is_new_development = 'TRUE' THEN 1 ELSE 0 END) AS new_projects,

  -- النسب المئوية
  ROUND(SUM(CASE WHEN has_lift = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS percent_with_lift,
  ROUND(SUM(CASE WHEN has_parking = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS percent_with_parking,
  ROUND(SUM(CASE WHEN is_new_development = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS percent_new_development,
  ROUND(SUM(CASE WHEN has_lift = 'TRUE' AND has_parking = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS percent_with_lift_and_parking,

  -- السعر حسب الغرف
  AVG(buy_price / NULLIF(n_rooms, 0)) AS avg_price_per_room

FROM madrid_data
WHERE 
  has_lift IS NOT NULL AND 
  sq_mt_built IS NOT NULL AND 
  is_new_development IS NOT NULL
GROUP BY district
HAVING COUNT(*) >= 10;

---------------------------------------------------
---------------------------------------------------

CREATE VIEW fact_properties AS
SELECT 
  id, title, city, district,
  sq_mt_built, n_rooms, n_bathrooms,
  buy_price, buy_price_by_area,
  house_type_id, built_year_date,
  has_lift, has_parking,
  is_new_development, is_floor_under,
  is_exterior, is_renewal_needed,
  price_category, floor
FROM madrid_data
WHERE buy_price IS NOT NULL;

-----------------------------------------------------
-----------------------------------------------------

CREATE VIEW dim_district AS
SELECT DISTINCT district
FROM madrid_data;


-------------------------------------------------------
-------------------------------------------------------

CREATE VIEW dim_features AS
SELECT DISTINCT
  has_lift,
  has_parking,
  is_new_development,
  is_floor_under,
  is_exterior,
  is_renewal_needed
FROM madrid_data;

--------------------------------------------------------------
--------------------------------------------------------------