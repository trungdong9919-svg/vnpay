package murach.servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import murach.util.VNPayUtil;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet nhận callback từ VNPay sau khi thanh toán.
 * URL: /vnpay-return
 *
 * VNPay sẽ redirect về URL này với các tham số:
 *   vnp_ResponseCode: 00 = thành công
 *   vnp_SecureHash: chữ ký để xác thực
 */
@WebServlet("/vnpay-return")
public class VNPayReturnServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Thu thập tất cả tham số từ VNPay
        Map<String, String> params = new HashMap<>();
        request.getParameterMap().forEach((key, values) -> {
            if (values != null && values.length > 0) {
                params.put(key, values[0]);
            }
        });

        String responseCode = params.getOrDefault("vnp_ResponseCode", "");
        String transactionNo = params.getOrDefault("vnp_TransactionNo", "");
        String amount        = params.getOrDefault("vnp_Amount", "0");
        String orderInfo     = params.getOrDefault("vnp_OrderInfo", "");
        String txnRef        = params.getOrDefault("vnp_TxnRef", "");
        String bankCode      = params.getOrDefault("vnp_BankCode", "");
        String payDate       = params.getOrDefault("vnp_PayDate", "");

        boolean signatureValid = false;
        try {
            signatureValid = VNPayUtil.verifyReturn(params);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi xác thực chữ ký: " + e.getMessage());
        }

        // Xác định kết quả thanh toán
        boolean paymentSuccess = "00".equals(responseCode) && signatureValid;

        if (paymentSuccess) {
            // Thanh toán thành công → xóa giỏ hàng
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.removeAttribute("cart");
                session.removeAttribute("pendingOrderId");
            }
            request.setAttribute("success", true);
        } else {
            request.setAttribute("success", false);
            request.setAttribute("errorCode", responseCode);
        }

        // Truyền thông tin giao dịch cho view
        request.setAttribute("transactionNo", transactionNo);
        request.setAttribute("txnRef",        txnRef);
        request.setAttribute("orderInfo",     orderInfo);
        request.setAttribute("bankCode",      bankCode);
        request.setAttribute("payDate",       payDate);

        // Format số tiền (VNPay trả về đã * 100)
        try {
            long amountLong = Long.parseLong(amount) / 100;
            request.setAttribute("amountVND", amountLong);
        } catch (NumberFormatException e) {
            request.setAttribute("amountVND", 0L);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/payment-result.jsp");
        dispatcher.forward(request, response);
    }
}
