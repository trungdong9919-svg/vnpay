package murach.servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import murach.business.CartItem;
import murach.business.Product;
import murach.data.ProductDB;

import java.io.IOException;
import java.util.LinkedHashMap;

/**
 * Servlet xử lý giỏ hàng.
 * URL: /cart
 * Actions: add, update, remove, continueShopping, checkout
 */
@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        // Lấy giỏ hàng từ session, nếu chưa có thì tạo mới
        LinkedHashMap<String, CartItem> cart =
                (LinkedHashMap<String, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new LinkedHashMap<>();
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "add":
                // Thêm sản phẩm vào giỏ
                String productCode = request.getParameter("productCode");
                Product product = ProductDB.getProductByCode(productCode);
                if (product != null) {
                    if (cart.containsKey(productCode)) {
                        CartItem existing = cart.get(productCode);
                        existing.setQuantity(existing.getQuantity() + 1);
                    } else {
                        cart.put(productCode, new CartItem(product));
                    }
                }
                session.setAttribute("cart", cart);
                response.sendRedirect(request.getContextPath() + "/cart");
                break;

            case "update":
                // Cập nhật số lượng
                for (String key : cart.keySet()) {
                    String qtyParam = request.getParameter("qty_" + key);
                    if (qtyParam != null && !qtyParam.trim().isEmpty()) {
                        try {
                            int qty = Integer.parseInt(qtyParam.trim());
                            if (qty > 0) {
                                cart.get(key).setQuantity(qty);
                            } else {
                                // qty = 0 → xóa item
                                cart.remove(key);
                                break; // ConcurrentModificationException guard
                            }
                        } catch (NumberFormatException e) {
                            // Bỏ qua nếu nhập sai
                        }
                    }
                }
                session.setAttribute("cart", cart);
                response.sendRedirect(request.getContextPath() + "/cart");
                break;

            case "remove":
                // Xóa sản phẩm khỏi giỏ
                String removeCode = request.getParameter("productCode");
                cart.remove(removeCode);
                session.setAttribute("cart", cart);
                response.sendRedirect(request.getContextPath() + "/cart");
                break;

            case "continueShopping":
                session.setAttribute("cart", cart);
                response.sendRedirect(request.getContextPath() + "/");
                break;

            case "checkout":
                // Chuyển đến trang thanh toán VNPay
                session.setAttribute("cart", cart);
                response.sendRedirect(request.getContextPath() + "/payment");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/");
                break;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int cartCount = getCartCount(request.getSession(false));
        request.setAttribute("cartCount", cartCount);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/cart.jsp");
        dispatcher.forward(request, response);
    }

    @SuppressWarnings("unchecked")
    private int getCartCount(HttpSession session) {
        if (session == null) return 0;
        LinkedHashMap<String, CartItem> cart =
                (LinkedHashMap<String, CartItem>) session.getAttribute("cart");
        if (cart == null) return 0;
        return cart.values().stream().mapToInt(CartItem::getQuantity).sum();
    }
}
