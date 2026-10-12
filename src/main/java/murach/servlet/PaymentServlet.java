package murach.servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import murach.business.CartItem;
import murach.util.VNPayUtil;

import java.io.IOException;
import java.text.NumberFormat;
import java.util.LinkedHashMap;
import java.util.Locale;

/**
 * Servlet xử lý thanh toán VNPay.
 *
 * GET  /payment  → hiển thị trang xác nhận thanh toán
 * POST /payment  → tạo URL và redirect đến VNPay
 */
@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {

    @SuppressWarnings("unchecked")
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        LinkedHashMap<String, CartItem> cart =
                (LinkedHashMap<String, CartItem>) session.getAttribute("cart");

        // Nếu giỏ hàng trống → về trang chủ
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Tính tổng tiền USD → VND (tỷ giá tham khảo ~25.000)
        double totalUSD = cart.values().stream().mapToDouble(CartItem::getTotal).sum();
        long totalVND   = Math.round(totalUSD * 25000);

        request.setAttribute("cart",     cart);
        request.setAttribute("totalUSD", totalUSD);
        request.setAttribute("totalVND", totalVND);
        request.setAttribute("cartCount", cart.values().stream().mapToInt(CartItem::getQuantity).sum());

        RequestDispatcher dispatcher = request.getRequestDispatcher("/payment.jsp");
        dispatcher.forward(request, response);
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        LinkedHashMap<String, CartItem> cart =
                (LinkedHashMap<String, CartItem>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Tính tổng tiền VNĐ
        double totalUSD = cart.values().stream().mapToDouble(CartItem::getTotal).sum();
        long totalVND   = Math.round(totalUSD * 25000);

        // Tạo Order ID duy nhất
        String orderId  = "CD" + System.currentTimeMillis();
        String orderInfo= "Thanh toan don hang " + orderId;

        // URL callback sau khi VNPay xử lý
        String returnUrl = request.getScheme() + "://"
                + request.getServerName() + ":" + request.getServerPort()
                + request.getContextPath() + "/vnpay-return";

        // Lấy IP khách hàng
        String ipAddr = request.getHeader("X-Forwarded-For");
        if (ipAddr == null || ipAddr.isEmpty()) {
            ipAddr = request.getRemoteAddr();
        }

        try {
            String paymentUrl = VNPayUtil.createPaymentUrl(
                    orderId, totalVND, orderInfo, returnUrl, ipAddr);

            // Lưu orderId vào session để xác thực callback
            session.setAttribute("pendingOrderId", orderId);

            // Redirect đến trang thanh toán VNPay
            response.sendRedirect(paymentUrl);

        } catch (Exception e) {
            request.setAttribute("error", "Không thể tạo yêu cầu thanh toán: " + e.getMessage());
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
        }
    }
}
