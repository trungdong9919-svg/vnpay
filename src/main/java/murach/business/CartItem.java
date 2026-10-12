package murach.business;

import java.io.Serializable;

/**
 * Đại diện cho một dòng trong giỏ hàng.
 */
public class CartItem implements Serializable {

    private Product product;
    private int quantity;

    public CartItem(Product product) {
        this.product = product;
        this.quantity = 1;
    }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    /** Tổng tiền của item này */
    public double getTotal() {
        return product.getPrice() * quantity;
    }
}
