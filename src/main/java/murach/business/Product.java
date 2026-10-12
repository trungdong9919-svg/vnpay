package murach.business;

import java.io.Serializable;

/**
 * Model class đại diện cho một sản phẩm CD.
 */
public class Product implements Serializable {

    private String code;
    private String description;
    private double price;
    private String artist;
    private String albumTitle;

    public Product() {}

    public Product(String code, String artist, String albumTitle, double price) {
        this.code = code;
        this.artist = artist;
        this.albumTitle = albumTitle;
        this.description = "<strong>" + artist + "</strong> - " + albumTitle;
        this.price = price;
    }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getArtist() { return artist; }
    public void setArtist(String artist) { this.artist = artist; }

    public String getAlbumTitle() { return albumTitle; }
    public void setAlbumTitle(String albumTitle) { this.albumTitle = albumTitle; }
}
