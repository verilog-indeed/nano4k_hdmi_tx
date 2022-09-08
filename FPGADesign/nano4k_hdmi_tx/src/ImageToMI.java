import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import javax.imageio.*;
import java.net.*;
import java.util.Arrays;

class ImageToMI {
	/*quick and dirty script to convert images into the RGB222 colorspace, 
	 *then generate Gowin-format .mi SRAM initialization file*/
    public static void main(String[] args) throws IOException, MalformedURLException{
        FileWriter output = null;
        BufferedImage image;
		//TODO use args instead?
        File imageFile = new File("image3.png"); //change this to desired image URL
        image = ImageIO.read(imageFile);
        int[] rgbArray = new int[image.getWidth() * image.getHeight()];//each int is a ARGB 32-bit pixel
        rgbArray = image.getRGB(0, 0, image.getWidth(), image.getHeight(), rgbArray, 0, image.getWidth());
        image.getColorModel();
        output = new FileWriter("image3.mi"); //change this to desired memory initialization filename
        output.write("#File_format=Hex\n");
        output.write("#Address_depth="+ rgbArray.length +"\n");
        //TODO variable target width?
        output.write("#Data_width=6\n");
        for (int i = 0; i < rgbArray.length; i++) {
            int adjustedRGB = rgbArray[i] & 0x00FFFFFF; //zero out alpha channel, 0x00RRGGBB
            int adjustedRed = adjustedRGB >> 16; //isolate red component
            int adjustedGreen = (adjustedRGB >> 8) & 0xFF; //isolate green component
            int adjustedBlue = adjustedRGB & 0xFF; //isolate blue component
			
			//change color intensities from a 0-255 scale (8-bit components) to a 0-3 scale (2-bit components) 
            adjustedRed = (int) Math.round(((adjustedRed / 255.0) * (Math.pow(2, 2) - 1)));
            adjustedGreen = (int) Math.round(((adjustedGreen / 255.0) * (Math.pow(2, 2) - 1)));
            adjustedBlue = (int) Math.round(((adjustedBlue / 255.0) * (Math.pow(2, 2) - 1)));

            //RGB222
            adjustedRGB = (adjustedRed << 4) | (adjustedGreen << 2) | adjustedBlue;
            output.write(String.format("%02X\n", adjustedRGB));
        }
        output.close();
    }
}