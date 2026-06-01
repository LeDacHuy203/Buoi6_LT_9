CREATE
DATABASE Buoi6_lt_9;

CREATE SCHEMA session6;

SET
search_path TO session6;

-- 1. Tạo bảng Product
CREATE TABLE Product
(
    id       SERIAL PRIMARY KEY,
    name     VARCHAR(100),
    category VARCHAR(50),
    price    NUMERIC(10, 2)
);

-- 2. Tạo bảng OrderDetail
CREATE TABLE OrderDetail
(
    id         SERIAL PRIMARY KEY,
    order_id   INT,
    product_id INT REFERENCES Product (id), -- Thêm khóa ngoại để liên kết dữ liệu chuẩn xác
    quantity   INT
);


-- Chèn 5 sản phẩm thuộc 3 danh mục khác nhau
INSERT INTO Product (name, category, price)
VALUES ('iPhone 15', 'Điện tử', 25000000),        -- id: 1
       ('MacBook Air', 'Điện tử', 30000000),      -- id: 2
       ('Bàn làm việc', 'Nội thất', 5000000),     -- id: 3
       ('Ghế công thái học', 'Nội thất', 4000000),-- id: 4
       ('Sách SQL cơ bản', 'Sách', 200000);
-- id: 5 (Sản phẩm chưa bán được đơn nào để test LEFT JOIN)

-- Chèn 6 dòng chi tiết đơn hàng để tính toán doanh thu
INSERT INTO OrderDetail (order_id, product_id, quantity)
VALUES (101, 1, 1),
       (102, 1, 1),
       (101, 2, 1),
       (103, 3, 2),
       (104, 4, 3),
       (105, 4, 1);

-- 1. Tính tổng doanh thu từng sản phẩm, hiển thị product_name, total_sales (SUM(price * quantity))
SELECT p.name                     product_name,
       sum(p.price * od.quantity) total_sales
FROM OrderDetail od
         JOIN Product p on p.id = od.product_id
GROUP BY p.name
;
-- 2. Tính doanh thu trung bình theo từng loại sản phẩm (GROUP BY category)
SELECT category,
       AVG(total_sales)
FROM (SELECT p.category,
             p.id,
             SUM(p.price * od.quantity) total_sales
      FROM Product p
               JOIN OrderDetail od
                    ON p.id = od.product_id
      GROUP BY p.category, p.id) t
GROUP BY category;
-- 3. Chỉ hiển thị các loại sản phẩm có doanh thu trung bình > 20 triệu (HAVING)
SELECT p.category,
       AVG(p.price * od.quantity) avg_category_sales
FROM Product p
         JOIN OrderDetail od
              ON p.id = od.product_id
GROUP BY p.category
HAVING AVG(p.price * od.quantity) > 20000000;
-- 4. Hiển thị tên sản phẩm có doanh thu cao hơn doanh thu trung bình toàn bộ sản phẩm (dùng Subquery)
SELECT p.name, sum(p.price * od.quantity) total_sales
FROM Product p
         JOIN OrderDetail OD on p.id = OD.product_id
GROUP BY p.name
HAVING sum(p.price * od.quantity) > (SELECT avg(total_sales) as average_product_revenue
                                     FROM (SELECT p.id, p.name, sum(p.price * od.quantity) total_sales
                                           FROM Product p
                                                    JOIN OrderDetail OD on p.id = OD.product_id
                                           GROUP BY p.id, p.name) total_amuont);

--
-- SELECT avg(total_sales) as average_product_revenue
-- FROM (SELECT p.id, p.name, sum(p.price * od.quantity) total_sales
--       FROM Product p
--                JOIN OrderDetail OD on p.id = OD.product_id
--       GROUP BY p.id, p.name) total_amuont;
--
--
-- SELECT p.id, p.name, sum(p.price * od.quantity) total_sales
-- FROM Product p
--          JOIN OrderDetail OD on p.id = OD.product_id
-- GROUP BY p.id, p.name;
-- 5. Liệt kê toàn bộ sản phẩm và số lượng bán được (nếu có) – kể cả sản phẩm chưa có đơn hàng (LEFT JOIN)
SELECT p.id,
       p.name,
       p.category,
       p.price,
       COALESCE(SUM(od.quantity),0) total_quantity
FROM Product p
         LEFT JOIN OrderDetail od
                   ON p.id = od.product_id
GROUP BY p.id,p.name,p.category,p.price;
