package murach.data;

import murach.business.Product;
import java.util.ArrayList;
import java.util.List;

/**
 * Lớp giả lập CSDL sản phẩm CD.
 * Trong thực tế có thể thay bằng kết nối MySQL/PostgreSQL.
 */
public class ProductDB {

    public static List<Product> getAll() {
        List<Product> products = new ArrayList<>();
        products.add(new Product("p1", "86 (the band)", "True Life Songs and Pictures", 14.95));
        products.add(new Product("p2", "Paddlefoot", "The first CD", 12.95));
        products.add(new Product("p3", "Paddlefoot", "The second CD", 14.95));
        products.add(new Product("p4", "Joe Rut", "Genuine Wood Grained Finish CD", 14.95));
        products.add(new Product("p5", "The Midnight", "Monsters", 16.95));
        products.add(new Product("p6", "Fleetwood Mac", "Rumours (Remastered)", 18.95));
        return products;
    }

    public static Product getProductByCode(String code) {
        for (Product p : getAll()) {
            if (p.getCode().equals(code)) {
                return p;
            }
        }
        return null;
    }
}
