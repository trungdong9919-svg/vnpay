<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>
<fmt:setLocale value="en_US"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Giỏ hàng của bạn tại Murach CD Store">
  <title>Shopping Cart - Murach CD Store</title>
  <link rel="stylesheet" href="styles/main.css">
  <link rel="icon" type="image/svg+xml"
        href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🎵</text></svg>">
</head>
<body>
<div class="page-wrapper">
  <div class="card">

    <!-- ── Header ── -->
    <header class="card-header">
      <a href="${pageContext.request.contextPath}/" class="brand">
        <span class="brand-icon">🎵</span>
        <span class="brand-name">Murach CD Store</span>
      </a>
      <a href="${pageContext.request.contextPath}/cart" class="cart-badge" id="cart-link">
        <span class="cart-icon">🛒</span>
        <span>Shopping Cart</span>
        <span class="cart-count">${cartCount}</span>
      </a>
    </header>

    <!-- ── Body ── -->
    <div class="card-body">

      <!-- Breadcrumb -->
      <nav class="breadcrumb" aria-label="breadcrumb">
        <a href="${pageContext.request.contextPath}/">Home</a>
        <span class="sep">›</span>
        <span>Shopping Cart</span>
      </nav>

      <h1 class="section-title">Your Shopping Cart</h1>

      <c:choose>
        <%-- ── EMPTY CART ── --%>
        <c:when test="${empty sessionScope.cart}">
          <div class="empty-state" id="empty-cart">
            <div class="empty-icon">🛒</div>
            <h2>Your cart is empty</h2>
            <p>Add some CD albums to get started!</p>
            <a href="${pageContext.request.contextPath}/"
               class="btn btn-primary" id="continue-shopping-empty">
              ← Continue Shopping
            </a>
          </div>
        </c:when>

        <%-- ── CART WITH ITEMS ── --%>
        <c:otherwise>
          <table class="cart-table" id="cart-items-table">
            <thead>
              <tr>
                <th>Qty</th>
                <th>Album Description</th>
                <th class="col-right">Unit Price</th>
                <th class="col-right">Amount</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <c:set var="grandTotal" value="0"/>
              <c:forEach var="entry" items="${sessionScope.cart}">
                <c:set var="item" value="${entry.value}"/>
                <c:set var="grandTotal" value="${grandTotal + item.total}"/>
                <tr>
                  <%-- Qty input + update --%>
                  <td>
                    <form action="${pageContext.request.contextPath}/cart"
                          method="post" class="qty-form"
                          id="update-form-${item.product.code}">
                      <input type="hidden" name="action" value="update">
                      <input type="number"
                             name="qty_${item.product.code}"
                             value="${item.quantity}"
                             min="1" max="99"
                             class="qty-input"
                             id="qty-${item.product.code}">
                      <button type="submit" class="btn btn-outline"
                              id="update-${item.product.code}"
                              style="padding:6px 10px;font-size:12px;">
                        ↺
                      </button>
                    </form>
                  </td>
                  <td>${item.product.description}</td>
                  <td class="col-right">
                    <fmt:formatNumber value="${item.product.price}" type="currency"/>
                  </td>
                  <td class="col-right">
                    <strong>
                      <fmt:formatNumber value="${item.total}" type="currency"/>
                    </strong>
                  </td>
                  <%-- Remove button --%>
                  <td>
                    <form action="${pageContext.request.contextPath}/cart" method="post"
                          id="remove-form-${item.product.code}">
                      <input type="hidden" name="action"      value="remove">
                      <input type="hidden" name="productCode" value="${item.product.code}">
                      <button type="submit" class="btn btn-danger"
                              id="remove-${item.product.code}"
                              style="padding:6px 10px;font-size:12px;">
                        ✕
                      </button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>

          <%-- Order Summary --%>
          <div class="cart-summary" id="order-summary">
            <div class="cart-summary-row">
              <span>Subtotal</span>
              <span><fmt:formatNumber value="${grandTotal}" type="currency"/></span>
            </div>
            <div class="cart-summary-row">
              <span>Shipping</span>
              <span>Free</span>
            </div>
            <div class="cart-summary-row total">
              <span>Total</span>
              <span><fmt:formatNumber value="${grandTotal}" type="currency"/></span>
            </div>
          </div>

          <%-- Note --%>
          <div class="alert alert-warning" role="note">
            ⚠️ <span>To change quantity, enter new amount and click ↺. Entering 0 removes the item.</span>
          </div>

          <%-- Action buttons --%>
          <div class="action-bar">
            <form action="${pageContext.request.contextPath}/cart" method="post">
              <input type="hidden" name="action" value="continueShopping">
              <button type="submit" class="btn btn-outline" id="continue-shopping-btn">
                ← Continue Shopping
              </button>
            </form>

            <form action="${pageContext.request.contextPath}/cart" method="post">
              <input type="hidden" name="action" value="checkout">
              <button type="submit" class="btn btn-vnpay" id="checkout-btn">
                <span class="vnpay-logo">VNPay</span> — Thanh Toán Ngay
              </button>
            </form>
          </div>

        </c:otherwise>
      </c:choose>

    </div><!-- /card-body -->
  </div><!-- /card -->
</div><!-- /page-wrapper -->
</body>
</html>
