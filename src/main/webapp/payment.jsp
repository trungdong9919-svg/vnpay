<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>
<fmt:setLocale value="en_US"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Xác nhận và thanh toán đơn hàng qua VNPay">
  <title>Thanh Toán VNPay - Murach CD Store</title>
  <link rel="stylesheet" href="styles/main.css">
  <link rel="icon" type="image/svg+xml"
        href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🎵</text></svg>">
  <style>
    .step-bar {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0;
      margin-bottom: 28px;
    }
    .step {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 13px;
      font-weight: 500;
      color: #9ca3af;
    }
    .step-num {
      width: 28px; height: 28px;
      border-radius: 50%;
      background: #e5e7eb;
      color: #6b7280;
      display: flex; align-items: center; justify-content: center;
      font-size: 12px; font-weight: 700;
    }
    .step.done .step-num  { background: #0d9488; color: #fff; }
    .step.done            { color: #0d9488; }
    .step.active .step-num { background: #0d9488; color: #fff; }
    .step.active          { color: #0f766e; font-weight: 600; }
    .step-line {
      width: 40px; height: 2px;
      background: #e5e7eb; margin: 0 4px;
    }
    .step-line.done { background: #0d9488; }

    .secure-badges {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 16px;
      margin-top: 16px;
      flex-wrap: wrap;
    }
    .secure-badge {
      display: flex;
      align-items: center;
      gap: 5px;
      font-size: 11px;
      color: #6b7280;
      background: #f9fafb;
      border: 1px solid #e5e7eb;
      border-radius: 6px;
      padding: 4px 10px;
    }
  </style>
</head>
<body>
<div class="page-wrapper">
  <div class="card">

    <!-- Header -->
    <header class="card-header">
      <a href="${pageContext.request.contextPath}/" class="brand">
        <span class="brand-icon">🎵</span>
        <span class="brand-name">Murach CD Store</span>
      </a>
      <a href="${pageContext.request.contextPath}/cart" class="cart-badge">
        <span class="cart-icon">🛒</span>
        <span>Cart</span>
        <span class="cart-count">${cartCount}</span>
      </a>
    </header>

    <div class="card-body">

      <!-- Breadcrumb -->
      <nav class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">Home</a>
        <span class="sep">›</span>
        <a href="${pageContext.request.contextPath}/cart">Cart</a>
        <span class="sep">›</span>
        <span>Payment</span>
      </nav>

      <!-- Step Bar -->
      <div class="step-bar">
        <div class="step done">
          <div class="step-num">✓</div>
          <span>Chọn hàng</span>
        </div>
        <div class="step-line done"></div>
        <div class="step done">
          <div class="step-num">✓</div>
          <span>Giỏ hàng</span>
        </div>
        <div class="step-line done"></div>
        <div class="step active">
          <div class="step-num">3</div>
          <span>Thanh toán</span>
        </div>
      </div>

      <h1 class="section-title">Xác Nhận Thanh Toán</h1>
      <p class="section-subtitle">Kiểm tra lại đơn hàng trước khi thanh toán qua VNPay.</p>

      <%-- Error message --%>
      <c:if test="${not empty error}">
        <div class="alert alert-warning" role="alert">
          ⚠️ ${error}
        </div>
      </c:if>

      <%-- Order Summary --%>
      <div class="payment-summary">
        <div class="payment-summary-title">
          📋 Chi Tiết Đơn Hàng
        </div>
        <table style="width:100%;border-collapse:collapse;">
          <thead>
            <tr style="font-size:12px;color:#6b7280;text-transform:uppercase;letter-spacing:0.05em;">
              <th style="text-align:left;padding:6px 0;font-weight:600;">Sản phẩm</th>
              <th style="text-align:center;padding:6px 0;font-weight:600;">SL</th>
              <th style="text-align:right;padding:6px 0;font-weight:600;">Thành tiền</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="entry" items="${sessionScope.cart}">
              <c:set var="item" value="${entry.value}"/>
              <tr style="border-top:1px solid #ccfbf1;">
                <td style="padding:8px 0;font-size:13px;">${item.product.description}</td>
                <td style="text-align:center;padding:8px 0;font-size:13px;color:#6b7280;">
                  × ${item.quantity}
                </td>
                <td style="text-align:right;padding:8px 0;font-size:13px;font-weight:600;">
                  <fmt:formatNumber value="${item.total}" type="currency"/>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>

      <%-- Amount Box --%>
      <div class="payment-amount-box" id="payment-amount">
        <div class="payment-amount-usd">
          Tổng: <fmt:formatNumber value="${totalUSD}" type="currency"/>
          (tỷ giá tham khảo ~25,000 VNĐ/USD)
        </div>
        <div class="payment-amount-vnd">
          <fmt:formatNumber value="${totalVND}" type="number" groupingUsed="true"/>
          <span> VNĐ</span>
        </div>
      </div>

      <%-- Sandbox Notice --%>
      <div class="alert alert-warning">
        🧪 <span>
          Đang sử dụng <strong>VNPay Sandbox</strong>.
          Thẻ test: <strong>9704198526191432198</strong> / 07/15 / OTP: <strong>123456</strong>.
          <a href="https://sandbox.vnpayment.vn/apis/docs/huong-dan-tich-hop/"
             target="_blank" rel="noopener">Xem hướng dẫn ↗</a>
        </span>
      </div>

      <%-- Pay Button --%>
      <form action="${pageContext.request.contextPath}/payment" method="post"
            id="payment-form">
        <div style="text-align:center;">
          <button type="submit" class="btn btn-vnpay" id="pay-now-btn">
            <span class="vnpay-logo">VNPay</span>
            &nbsp;— Thanh Toán ${totalVND != null ? totalVND : ""}₫ Ngay
          </button>
        </div>
      </form>

      <%-- Secure Badges --%>
      <div class="secure-badges">
        <div class="secure-badge">🔒 SSL Secured</div>
        <div class="secure-badge">🏦 PCI DSS Compliant</div>
        <div class="secure-badge">✅ VNPay Certified</div>
      </div>

      <p class="vnpay-note">
        Bạn sẽ được chuyển đến trang thanh toán bảo mật của VNPay.
        Murach CD Store không lưu thông tin thẻ của bạn.
      </p>

      <div style="text-align:center;margin-top:16px;">
        <a href="${pageContext.request.contextPath}/cart"
           class="btn btn-outline" id="back-to-cart-btn">
          ← Quay lại giỏ hàng
        </a>
      </div>

    </div>
  </div>
</div>
</body>
</html>
