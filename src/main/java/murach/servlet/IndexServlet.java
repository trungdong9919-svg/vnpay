package murach.servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import murach.business.Product;
import murach.data.ProductDB;

import java.io.IOException;
import java.util.List;

/**
 * Servlet hiển thị trang chủ - danh sách sản phẩm CD.
 * URL: /  hoặc /index
 */
@WebServlet(urlPatterns = {"", "/index"})
public class IndexServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy danh sách sản phẩm từ CSDL giả lập
        List<Product> products = ProductDB.getAll();
        request.setAttribute("products", products);

        // Tính số lượng sản phẩm trong giỏ hàng để hiển thị trên header
        int cartCount = getCartCount(request.getSession(false));
        request.setAttribute("cartCount", cartCount);

        // Forward đến index.jsp
        RequestDispatcher dispatcher = request.getRequestDispatcher("/index.jsp");
        dispatcher.forward(request, response);
    }

    /**
     * Tính tổng số lượng sản phẩm trong giỏ hàng.
     */
    @SuppressWarnings("unchecked")
    private int getCartCount(HttpSession session) {
        if (session == null) return 0;
        java.util.LinkedHashMap<String, murach.business.CartItem> cart =
                (java.util.LinkedHashMap<String, murach.business.CartItem>) session.getAttribute("cart");
        if (cart == null) return 0;
        return cart.values().stream().mapToInt(murach.business.CartItem::getQuantity).sum();
    }
}
