<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kết Quả Thanh Toán - Murach CD Store</title>
  <link rel="stylesheet" href="styles/main.css">
  <link rel="icon" type="image/svg+xml"
        href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🎵</text></svg>">
  <style>
    .confetti-bg {
      background: linear-gradient(135deg, #d1fae5 0%, #ecfdf5 40%, #f0fdfa 100%);
    }
    .fail-bg {
      background: linear-gradient(135deg, #fee2e2 0%, #fef2f2 40%, #fff 100%);
    }
    .result-card-body {
      text-align: center;
      padding: 40px 28px;
    }
  </style>
</head>
<body>
<div class="page-wrapper ${success ? 'confetti-bg' : 'fail-bg'}">
  <div class="card">

    <!-- Header -->
    <header class="card-header">
      <a href="${pageContext.request.contextPath}/" class="brand">
        <span class="brand-icon">🎵</span>
        <span class="brand-name">Murach CD Store</span>
      </a>
    </header>

    <div class="card-body result-card-body">

      <c:choose>
        <%-- ── THANH TOÁN THÀNH CÔNG ── --%>
        <c:when test="${success}">
          <div class="result-icon" id="result-icon">🎉</div>
          <h1 class="result-title success" id="result-title">
            Thanh Toán Thành Công!
          </h1>
          <p class="result-subtitle">
            Cảm ơn bạn đã mua hàng tại Murach CD Store.
            Đơn hàng của bạn đã được xác nhận.
          </p>

          <div class="transaction-info" id="transaction-info">
            <table>
              <tr>
                <td>Mã giao dịch VNPay</td>
                <td><strong>${transactionNo}</strong></td>
              </tr>
              <tr>
                <td>Mã đơn hàng</td>
                <td>${txnRef}</td>
              </tr>
              <tr>
                <td>Số tiền</td>
                <td>
                  <fmt:formatNumber value="${amountVND}" type="number" groupingUsed="true"/>
                  VNĐ
                </td>
              </tr>
              <tr>
                <td>Ngân hàng</td>
                <td>${bankCode}</td>
              </tr>
              <tr>
                <td>Thời gian</td>
                <td>${payDate}</td>
              </tr>
              <tr>
                <td>Trạng thái</td>
                <td style="color:#059669;font-weight:700;">✅ Thành công</td>
              </tr>
            </table>
          </div>

          <a href="${pageContext.request.contextPath}/"
             class="btn btn-primary" id="continue-shopping-result">
            🎵 Tiếp tục mua sắm
          </a>
        </c:when>

        <%-- ── THANH TOÁN THẤT BẠI ── --%>
        <c:otherwise>
          <div class="result-icon" id="result-icon-fail">❌</div>
          <h1 class="result-title error" id="result-title-fail">
            Thanh Toán Thất Bại
          </h1>
          <p class="result-subtitle">
            Giao dịch không thành công.
            <c:if test="${not empty errorCode}">
              Mã lỗi VNPay: <strong>${errorCode}</strong>
            </c:if>
          </p>

          <div class="transaction-info" id="transaction-info-fail">
            <table>
              <tr>
                <td>Mã đơn hàng</td>
                <td>${txnRef}</td>
              </tr>
              <c:if test="${not empty transactionNo}">
              <tr>
                <td>Mã giao dịch</td>
                <td>${transactionNo}</td>
              </tr>
              </c:if>
              <tr>
                <td>Trạng thái</td>
                <td style="color:#dc2626;font-weight:700;">❌ Thất bại (${errorCode})</td>
              </tr>
            </table>
          </div>

          <div class="action-bar" style="justify-content:center;gap:12px;">
            <a href="${pageContext.request.contextPath}/payment"
               class="btn btn-vnpay" id="retry-payment-btn">
              ↺ Thử lại thanh toán
            </a>
            <a href="${pageContext.request.contextPath}/cart"
               class="btn btn-outline" id="back-to-cart-result">
              ← Về giỏ hàng
            </a>
          </div>

          <div class="alert alert-warning" style="margin-top:16px;text-align:left;">
            ⚠️ Thẻ test sandbox:
            <strong>9704198526191432198</strong> / 07/15 / OTP: <strong>123456</strong>
          </div>
        </c:otherwise>
      </c:choose>

    </div>
  </div>
</div>
</body>
</html>
