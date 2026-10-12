package murach.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Tiện ích tích hợp VNPay Payment Gateway.
 *
 * Tài liệu: https://sandbox.vnpayment.vn/apis/docs/huong-dan-tich-hop/
 *
 * Cấu hình Sandbox:
 *   TMN Code : DEMO2024
 *   Hash Secret: DEMO_SECRET_KEY_2024
 *   URL: https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
 *
 * QUAN TRỌNG: Thay thế TMN_CODE và HASH_SECRET bằng thông tin thật
 * khi deploy production (nên đặt trong biến môi trường).
 */
public class VNPayUtil {

    // ============================================================
    // CẤU HÌNH VNPAY - Thay đổi khi deploy production
    // ============================================================
    public static final String VNP_TMN_CODE   = System.getenv("VNP_TMN_CODE")   != null
            ? System.getenv("VNP_TMN_CODE")   : "DEMO2024";
    public static final String VNP_HASH_SECRET = System.getenv("VNP_HASH_SECRET") != null
            ? System.getenv("VNP_HASH_SECRET") : "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456";
    public static final String VNP_PAY_URL    = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static final String VNP_RETURN_URL_KEY = "VNP_RETURN_URL";

    /**
     * Tạo URL thanh toán VNPay.
     *
     * @param orderId     Mã đơn hàng (duy nhất)
     * @param amount      Tổng tiền (VNĐ - nhân 100 trước khi gửi)
     * @param orderInfo   Mô tả đơn hàng
     * @param returnUrl   URL callback sau khi thanh toán
     * @param ipAddr      IP của khách hàng
     * @return URL thanh toán đầy đủ
     */
    public static String createPaymentUrl(String orderId, long amount,
                                          String orderInfo, String returnUrl,
                                          String ipAddr) throws Exception {
        String vnpVersion    = "2.1.0";
        String vnpCommand    = "pay";
        String vnpCurrCode   = "VND";
        String vnpLocale     = "vn";
        String vnpOrderType  = "other";

        // Thời gian tạo và hết hạn (15 phút)
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        formatter.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        String vnpCreateDate = formatter.format(cld.getTime());
        cld.add(Calendar.MINUTE, 15);
        String vnpExpireDate = formatter.format(cld.getTime());

        // Tập hợp tham số (TreeMap để tự động sort theo alphabet)
        Map<String, String> vnpParams = new TreeMap<>();
        vnpParams.put("vnp_Version",    vnpVersion);
        vnpParams.put("vnp_Command",    vnpCommand);
        vnpParams.put("vnp_TmnCode",    VNP_TMN_CODE);
        vnpParams.put("vnp_Amount",     String.valueOf(amount * 100)); // VNPay nhận đơn vị * 100
        vnpParams.put("vnp_CurrCode",   vnpCurrCode);
        vnpParams.put("vnp_TxnRef",     orderId);
        vnpParams.put("vnp_OrderInfo",  orderInfo);
        vnpParams.put("vnp_OrderType",  vnpOrderType);
        vnpParams.put("vnp_Locale",     vnpLocale);
        vnpParams.put("vnp_ReturnUrl",  returnUrl);
        vnpParams.put("vnp_IpAddr",     ipAddr);
        vnpParams.put("vnp_CreateDate", vnpCreateDate);
        vnpParams.put("vnp_ExpireDate", vnpExpireDate);

        // Build query string và hash data
        StringBuilder hashData  = new StringBuilder();
        StringBuilder queryData = new StringBuilder();

        for (Map.Entry<String, String> entry : vnpParams.entrySet()) {
            String key   = entry.getKey();
            String value = entry.getValue();
            if (value != null && !value.isEmpty()) {
                hashData.append(key).append('=')
                        .append(URLEncoder.encode(value, StandardCharsets.US_ASCII));
                queryData.append(URLEncoder.encode(key, StandardCharsets.US_ASCII))
                         .append('=')
                         .append(URLEncoder.encode(value, StandardCharsets.US_ASCII));
                hashData.append('&');
                queryData.append('&');
            }
        }

        // Xóa ký tự & cuối
        if (hashData.length() > 0) hashData.deleteCharAt(hashData.length() - 1);
        if (queryData.length() > 0) queryData.deleteCharAt(queryData.length() - 1);

        // Tạo chữ ký HMAC-SHA512
        String vnpSecureHash = hmacSHA512(VNP_HASH_SECRET, hashData.toString());
        queryData.append("&vnp_SecureHash=").append(vnpSecureHash);

        return VNP_PAY_URL + "?" + queryData;
    }

    /**
     * Xác thực callback từ VNPay (kiểm tra chữ ký).
     *
     * @param params Map các tham số nhận về từ VNPay
     * @return true nếu chữ ký hợp lệ
     */
    public static boolean verifyReturn(Map<String, String> params) throws Exception {
        String vnpSecureHash = params.get("vnp_SecureHash");
        if (vnpSecureHash == null) return false;

        // Lọc bỏ các key chữ ký, sort, build hashData
        Map<String, String> sortedParams = new TreeMap<>(params);
        sortedParams.remove("vnp_SecureHash");
        sortedParams.remove("vnp_SecureHashType");

        StringBuilder hashData = new StringBuilder();
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            String value = entry.getValue();
            if (value != null && !value.isEmpty()) {
                hashData.append(entry.getKey()).append('=')
                        .append(URLEncoder.encode(value, StandardCharsets.US_ASCII))
                        .append('&');
            }
        }
        if (hashData.length() > 0) hashData.deleteCharAt(hashData.length() - 1);

        String calculatedHash = hmacSHA512(VNP_HASH_SECRET, hashData.toString());
        return calculatedHash.equalsIgnoreCase(vnpSecureHash);
    }

    /**
     * Tính HMAC-SHA512.
     */
    public static String hmacSHA512(String key, String data) throws Exception {
        Mac hmac = Mac.getInstance("HmacSHA512");
        SecretKeySpec secretKey = new SecretKeySpec(
                key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
        hmac.init(secretKey);
        byte[] bytes = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
