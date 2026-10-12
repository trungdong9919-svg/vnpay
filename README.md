# 🎵 Murach CD Store — with VNPay Payment

Java Servlet/JSP web application giống mẫu **bai4-sandbox.onrender.com**, tích hợp thanh toán **VNPay**, deploy trên **Tomcat 10** via Docker.

## Tính năng

- 📀 Danh sách sản phẩm CD (Product List)
- 🛒 Giỏ hàng (Shopping Cart) với session tracking
- 💳 Thanh toán VNPay (Sandbox & Production ready)
- 🔒 Xác thực callback HMAC-SHA512
- 🐳 Docker multi-stage build → Tomcat 10

## Cấu trúc Project

```
cdstore/
├── src/main/
│   ├── java/murach/
│   │   ├── business/      Product.java, CartItem.java
│   │   ├── data/          ProductDB.java
│   │   ├── servlet/       IndexServlet, CartServlet, PaymentServlet, VNPayReturnServlet
│   │   └── util/          VNPayUtil.java (HMAC-SHA512)
│   └── webapp/
│       ├── index.jsp      Trang chủ - danh sách CD
│       ├── cart.jsp       Giỏ hàng
│       ├── payment.jsp    Xác nhận thanh toán VNPay
│       ├── payment-result.jsp  Kết quả giao dịch
│       ├── styles/main.css
│       └── WEB-INF/web.xml
├── Dockerfile
├── docker-compose.yml
└── pom.xml
```

## Chạy với Docker (Khuyên dùng)

```bash
# Build và chạy
docker-compose up --build

# Truy cập
http://localhost:8080
```

## Cấu hình VNPay

Thay đổi trong `docker-compose.yml`:

```yaml
environment:
  - VNP_TMN_CODE=<TMN_CODE_THẬT_CỦA_BẠN>
  - VNP_HASH_SECRET=<HASH_SECRET_THẬT_CỦA_BẠN>
```

### Đăng ký VNPay Sandbox
1. Truy cập: https://sandbox.vnpayment.vn/devreg/
2. Đăng ký tài khoản → nhận TMN Code và Hash Secret
3. Cập nhật biến môi trường trong `docker-compose.yml`

### Thẻ test Sandbox
| Thông tin   | Giá trị                |
|-------------|------------------------|
| Số thẻ      | 9704198526191432198    |
| Tên chủ thẻ | NGUYEN VAN A           |
| Ngày HH     | 07/15                  |
| OTP         | 123456                 |

## Luồng thanh toán

```
Chọn sản phẩm → Giỏ hàng → Xác nhận → VNPay Gateway → Callback → Kết quả
     (index)       (cart)    (payment)    [external]    (/vnpay-return)  (payment-result)
```

## Build thủ công (không Docker)

```bash
mvn clean package -DskipTests
# Copy target/cdstore.war vào thư mục webapps của Tomcat 10
```

## Tech Stack

| Thành phần | Phiên bản |
|------------|-----------|
| Java       | 17        |
| Jakarta Servlet | 6.0  |
| JSTL       | 3.0       |
| Tomcat     | 10.1      |
| Maven      | 3.9.6     |
| Docker     | 20+       |
| VNPay API  | 2.1.0     |
