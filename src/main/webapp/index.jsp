<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>
<fmt:setLocale value="en_US"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Murach CD Store - Mua album CD chính hãng với nhiều thể loại âm nhạc. Thanh toán an toàn qua VNPay.">
  <title>Murach CD Store - Available Albums</title>
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
        <span class="cart-count" id="cart-count">${cartCount}</span>
      </a>
    </header>

    <!-- ── Body ── -->
    <div class="card-body">
      <h1 class="section-title">Available CD Albums</h1>
      <p class="section-subtitle">
        Browse our collection of genuine music albums.
        Click "Add To Cart" to start your order.
      </p>

      <table class="product-table" id="product-list">
        <thead>
          <tr>
            <th>Album Description</th>
            <th class="col-price">Price</th>
            <th class="col-action">Action</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="product" items="${products}">
          <tr>
            <td>${product.description}</td>
            <td class="col-price">
              <fmt:formatNumber value="${product.price}" type="currency"/>
            </td>
            <td class="col-action">
              <form action="${pageContext.request.contextPath}/cart" method="post">
                <input type="hidden" name="action"      value="add">
                <input type="hidden" name="productCode" value="${product.code}">
                <button type="submit" class="btn btn-primary" id="add-${product.code}">
                  Add To Cart
                </button>
              </form>
            </td>
          </tr>
          </c:forEach>
        </tbody>
      </table>

      <div class="view-cart-row">
        <a href="${pageContext.request.contextPath}/cart"
           class="btn btn-outline" id="view-cart-btn">
          🛒 View Current Cart (${cartCount} items)
        </a>
      </div>
    </div><!-- /card-body -->

  </div><!-- /card -->
</div><!-- /page-wrapper -->
</body>
</html>
