---------------------------------------------------------
-- CLEAN EXISTING DATA (SAFE CASCADE)
---------------------------------------------------------

TRUNCATE TABLE users RESTART IDENTITY CASCADE;
TRUNCATE TABLE products RESTART IDENTITY CASCADE;

---------------------------------------------------------
-- INSERT 25 REAL PRODUCTS WITH UNSPLASH CDN IMAGES
---------------------------------------------------------

INSERT INTO products (name, description, price, stock, image_url, category, rating) VALUES
('Lenovo ThinkPad X1 Carbon', '14-inch business ultrabook, 16GB RAM, 512GB SSD', 115000.00, 10,
 'https://p3-ofp.static.pub//fes/cms/2024/07/05/05dhzg0lrtq4i0d3wxqyjjakwmbmzr331426.png?width=400&height=400', 'Laptops', 4.8),

('Dell XPS 13', 'Compact ultrabook with InfinityEdge display, 16GB RAM', 128000.00, 8,
 'https://dellstatic.luroconnect.com/media/catalog/product/cache/dd2a0577161cfa9edc1f09acc4e3c944/x/s/xs9320nt-xnb-shot-5-1-sl.jpg', 'Laptops', 4.7),

('MacBook Air M2', '13-inch Liquid Retina Display, 8GB RAM, 256GB SSD', 99900.00, 12,
 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80', 'Laptops', 4.9),

('HP Spectre x360', 'Premium convertible laptop, 16GB RAM, 1TB SSD', 142000.00, 6,
 'https://img-cdn.tnwcdn.com/image?fit=1200%2C675&height=675&url=https%3A%2F%2Fcdn0.tnwcdn.com%2Fwp-content%2Fblogs.dir%2F1%2Ffiles%2F2021%2F08%2FHP-Spectre-x360-14-1-of-7.jpg&signature=be2373b43e1088c3457ffd4f53fd987a', 'Laptops', 4.6),

('iPad Pro 12.9', 'Apple M2 chip, 128GB storage, Liquid Retina XDR display', 112000.00, 7,
 'https://cdn.shopify.com/s/files/1/1203/6172/products/ipad-2021-hero-space-wifi-select_ddf39685-48f0-4b1e-b270-6e00cd876586.png?v=1648379258', 'Tablets', 4.9),

('Samsung Galaxy Tab S9', 'AMOLED display, Snapdragon 8 Gen 2', 89999.00, 10,
 'https://images.samsung.com/is/image/samsung/p6pim/in/2307/gallery/in-galaxy-tab-s9-plus-5g-x816-sm-x816bzaainu-537353313', 'Tablets', 4.7),

('iPhone 15', 'A16 Bionic chip, 128GB storage', 79900.00, 15,
 'https://iplanet.one/cdn/shop/files/iPhone_15_Blue_PDP_Image_Position-1__en-IN_dd67c045-7eab-42df-8594-221b12345acd.jpg?v=1695428778&width=823', 'Mobiles', 4.9),

('Samsung Galaxy S24', 'Dynamic AMOLED display, 12GB RAM', 72000.00, 14,
 'https://m.media-amazon.com/images/I/717Q2swzhBL._AC_UF1000,1000_QL80_.jpg', 'Mobiles', 4.7),

('OnePlus 12', 'Snapdragon 8 Gen 3, 16GB RAM', 68000.00, 20,
 'https://media.wired.com/photos/65af0355a73d6dedff595b7d/master/w_2560%2Cc_limit/Gear-OnePlus-12-SOURCE-Julian-Chokkattu.jpg', 'Mobiles', 4.6),

('Google Pixel 8', 'Tensor G3 chip, best-in-class photography', 64000.00, 10,
 'https://techstomper.com/wp-content/uploads/2023/10/Google-Pixel-8-Pro-specs-camera-5x.jpg', 'Mobiles', 4.8),

('Sony WH-1000XM5', 'Wireless Noise Cancelling Headphones', 29990.00, 25,
 'https://images.unsplash.com/photo-1583394838336-acd977736f90?auto=format&fit=crop&w=800&q=80', 'Audio', 4.8),

('Bose QC45', 'Iconic QuietComfort noise cancelling headphones', 26900.00, 20,
 'https://m.media-amazon.com/images/I/515b2YziSkL._AC_UF1000,1000_QL80_.jpg', 'Audio', 4.7),

('JBL Charge 5', 'Portable Bluetooth speaker, waterproof', 14999.00, 30,
 'https://www.lbtechreviews.com/wp-content/uploads/2023/07/JBL-Charge-5-wifi-1080x608.jpg', 'Audio', 4.6),

('Amazon Echo Dot (5th Gen)', 'Smart speaker with Alexa', 5499.00, 40,
 'https://bsmedia.business-standard.com/_media/bs/img/article/2023-03/02/full/1677744984-9169.jpg?im=FeatureCrop,size=(826,465)', 'Smart Home', 4.5),

('Google Nest Hub 2', 'Smart display with Google Assistant', 7499.00, 22,
 'https://m.media-amazon.com/images/I/61p+HaIkPCL._SL1500_.jpg', 'Smart Home', 4.5),

('Mi Power Bank 20000mAh', 'Fast charging, dual USB output', 1999.00, 50,
 'https://5.imimg.com/data5/AQ/CP/MY-20343569/power-banks-1000x1000.png', 'Accessories', 4.4),

('Anker PowerCore Slim', '10000mAh lightweight powerbank', 3499.00, 35,
 'https://www.dohansqatar.com/cdn/shop/files/dohans-power-banks-anker-powercore-slim-10000-power-bank-40064836108484.jpg?v=1724548822', 'Accessories', 4.6),

('Logitech MX Master 3S', 'Advanced ergonomic wireless mouse', 9500.00, 40,
 'https://shop.broot.in/cdn/shop/files/Logitech_MX_Master_3S_1024x1024@2x.webp?v=1755778882', 'Accessories', 4.8),

('Logitech K380 Keyboard', 'Compact Bluetooth keyboard', 3299.00, 30,
 'https://d2j6dbq0eux0bg.cloudfront.net/images/1107006/1682036355.jpg', 'Accessories', 4.7),

('Dell 27” Monitor', 'Quad HD IPS display with 75Hz refresh', 23500.00, 15,
 'https://www.tpstech.in/cdn/shop/files/monitor-pseries-p2725he-bk-gallery-2_5428efa4-0b0d-4e8f-a68b-7b3fd79d1531.png?v=1749653736&width=1206', 'Monitors', 4.5),

('LG UltraGear 27"', 'Gaming monitor, 144Hz IPS, 1ms', 28999.00, 12,
 'https://images-cdn.ubuy.co.in/64e86a8c5f2aaf2ffc53287d-lg-27-ultragear-qhd-1ms-240hz-gaming.jpg', 'Monitors', 4.6),

('HP DeskJet 2723', 'All-in-one wireless color printer', 6999.00, 25,
 'https://media-ik.croma.com/prod/https://media.tatacroma.com/Croma%20Assets/Computers%20Peripherals/Printers%20and%20Scanners/Images/247643_1_yra2ge.png?tr=w-1000', 'Printers', 4.3),

('Canon Pixma G2012', 'Refillable ink tank printer', 12499.00, 18,
 'https://www.shopyvision.com/wp-content/uploads/2024/02/Canon-PIXMA-MegaTank-G2012-All-in-One-Inktank-Colour-Printer-.jpg.webp', 'Printers', 4.6),

('INNOWIN Jazz Chair', 'Ergonomic office chair with lumbar support', 8499.00, 10,
 'https://www.innowinfurniture.com/cdn/shop/products/10_4140bcc3-0995-4f9a-98a9-29812ecdacef_1080x.png?v=1646996732', 'Furniture', 4.4),

('Green Soul Monster Pro', 'Premium gaming chair', 15999.00, 8,
 'https://img.tatacliq.com/images/i11/437Wx649H/MP000000017547127_437Wx649H_202305151207232.jpeg', 'Furniture', 4.7);

---------------------------------------------------------
-- ADD DEFAULT ADDRESS COLUMN IF NOT PRESENT
---------------------------------------------------------

ALTER TABLE users ADD COLUMN IF NOT EXISTS default_address TEXT;

---------------------------------------------------------
-- INSERT 50 REALISTIC USERS WITH DEFAULT ADDRESSES
---------------------------------------------------------

INSERT INTO users (username, password_hash, default_address) VALUES
('aarav.sharma', 'Password@123', '123 MG Road, Bengaluru, Karnataka'),
('riya.verma', 'Password@123', '221B Residency Road, Bengaluru, Karnataka'),
('advik.menon', 'Password@123', '45 Brigade Road, Bengaluru, Karnataka'),
('diya.kapoor', 'Password@123', '100 Church Street, Bengaluru, Karnataka'),
('arjun.nair', 'Password@123', '12 OMR Main Road, Chennai, Tamil Nadu'),
('saanvi.iyer', 'Password@123', '88 T Nagar, Chennai, Tamil Nadu'),
('kabir.reddy', 'Password@123', '55 Jubilee Hills, Hyderabad, Telangana'),
('anaya.rao', 'Password@123', '72 Banjara Hills, Hyderabad, Telangana'),
('vivaan.shetty', 'Password@123', '33 Indiranagar, Bengaluru, Karnataka'),
('myra.singh', 'Password@123', '14 Koramangala, Bengaluru, Karnataka'),

('devansh.jain', 'Password@123', '50 MG Road, Pune, Maharashtra'),
('isha.patel', 'Password@123', '110 SG Highway, Ahmedabad, Gujarat'),
('krish.goel', 'Password@123', '30 Golf Course Road, Gurgaon, Haryana'),
('tara.mehra', 'Password@123', '91 Defence Colony, Delhi'),
('om.arora', 'Password@123', '7 Connaught Place, Delhi'),
('zara.chopra', 'Password@123', '19 Bandra West, Mumbai'),
('aryan.shah', 'Password@123', '81 Powai, Mumbai'),
('navya.bose', 'Password@123', '5 Salt Lake, Kolkata'),
('anirudh.sen', 'Password@123', '9 Park Street, Kolkata'),
('meera.khurana', 'Password@123', '12 Hinjewadi, Pune'),

('ishan.gupta', 'Password@123', '44 Kothrud, Pune'),
('lavanya.krishnan', 'Password@123', '22 Velachery, Chennai'),
('rehan.khan', 'Password@123', '9 Gachibowli, Hyderabad'),
('aadhya.joshi', 'Password@123', '15 HSR Layout, Bengaluru'),
('samar.bajaj', 'Password@123', '18 Whitefield, Bengaluru'),
('kriti.bhatt', 'Password@123', '77 SG Highway, Ahmedabad'),
('yash.malhotra', 'Password@123', '101 Malviya Nagar, Delhi'),
('prisha.singhal', 'Password@123', '58 Civil Lines, Delhi'),
('karan.desai', 'Password@123', '12 Vile Parle, Mumbai'),
('tanya.bhattacharya', 'Password@123', '99 Jadavpur, Kolkata'),

('rudra.kashyap', 'Password@123', '21 Baner, Pune'),
('sara.das', 'Password@123', '10 Ballygunge, Kolkata'),
('veer.modi', 'Password@123', '14 Satellite Road, Ahmedabad'),
('alisha.pillai', 'Password@123', '33 Marine Drive, Mumbai'),
('aditya.banerjee', 'Password@123', '44 Salt Lake, Kolkata'),
('mahika.agarwal', 'Password@123', '22 Punjabi Bagh, Delhi'),
('sahil.bose', 'Password@123', '19 Newtown, Kolkata'),
('jhanvi.reddy', 'Password@123', '55 Madhapur, Hyderabad'),
('arav.kulkarni', 'Password@123', '18 FC Road, Pune'),
('mira.swaminathan', 'Password@123', '9 Adyar, Chennai'),

('ronit.jain', 'Password@123', '35 JP Nagar, Bengaluru'),
('esha.menon', 'Password@123', '16 MG Road, Kochi'),
('daksh.tiwari', 'Password@123', '11 Gomti Nagar, Lucknow'),
('shanaya.khanna', 'Password@123', '77 Salt Lake, Kolkata'),
('veer.sawant', 'Password@123', '42 Dadar West, Mumbai'),
('advika.patil', 'Password@123', '8 Wakad, Pune'),
('reyansh.seth', 'Password@123', '65 South Delhi'),
('kiara.dalal', 'Password@123', '20 Bandra East, Mumbai'),
('atharv.joshi', 'Password@123', '7 Kalyani Nagar, Pune'),
('vanya.singh', 'Password@123', '12 Jayanagar, Bengaluru');

