PGraphics texture_generation(int base, int base_color, int shape, int shape_size, int texture_width, int texture_height) {
  PImage background;
  PGraphics new_texture;

  // Background base
  background = createImage(texture_width, texture_height, RGB);
  background.loadPixels();

  if (base == 1) {
    //Adapted from Noise2D by Daniel Shiffman
    float increment = 0.02, xoff = 0.0, detail = 0.6;
    noiseDetail(8, detail);

    for (int x = 0; x < background.width; x++) {
      xoff += increment;
      float yoff = 0.0;
      for (int y = 0; y < background.height; y++) {
        yoff += increment;

        float color_value = noise(xoff, yoff) * 255;

        //Color pixels
        if (base_color == 1) {
          background.pixels[x+y*background.width] = color(color_value, 0, 0);
        } else if (base_color == 2) {
          background.pixels[x+y*background.width] = color(0, color_value, 0);
        } else if (base_color == 3) {
          background.pixels[x+y*background.width] = color(0, 0, color_value);
        } else if (base_color == 4) {
          background.pixels[x+y*background.width] = color(color_value);
        }
      }
    }
  } else if (base == 2) {
    ////Adapted from Graphing 2D Equations by Daniel Shiffman

    float n = 1, w = 16.0, h = 16.0;
    float dx = w / background.width;
    float dy = h / background.height;
    float x = -w/2;

    for (int i = 0; i < background.width; i++) {
      float y = -h/2;
      for (int j = 0; j < background.height; j++) {
        float r = sqrt((x*x) + (y*y));
        float theta = atan2(y, x);


        float val = sin(n*cos(r) + 5 * theta);

        //Color pixels
        if (base_color == 1) {
          background.pixels[i+j*background.width] = color(((val + 1.0) * 255.0/2.0), 0, 0);
        } else if (base_color == 2) {
          background.pixels[i+j*background.width] = color(0, ((val + 1.0) * 255.0/2.0), 0);
        } else if (base_color == 3) {
          background.pixels[i+j*background.width] = color(0, 0, ((val + 1.0) * 255.0/2.0));
        } else if (base_color == 4) {
          background.pixels[i+j*background.width] = color(((val + 1.0) * 255.0/2.0));
        }

        y += dy;
      }
      x += dx;
    }
  } else if (base == 3) {
    for (int x = 0; x < background.width; x++) {
      for (int y = 0; y < background.height; y++) {

        float color_value = map(x, 0, background.width, 255, 0);
        //Color pixels
        if (base_color == 1) {
          background.pixels[x+y*background.width] = color(color_value, 0, 0);
        } else if (base_color == 2) {
          background.pixels[x+y*background.width] = color(0, color_value, 0);
        } else if (base_color == 3) {
          background.pixels[x+y*background.width] = color(0, 0, color_value);
        } else if (base_color == 4) {
          background.pixels[x+y*background.width] = color(color_value);
        }
      }
    }
  } else if (base == 4) {
    for (int x = 0; x < background.width; x++) {
      for (int y = 0; y < background.height; y++) {

        //Color pixels
        if (base_color == 1) {
          background.pixels[x+y*background.width] = color(int(random(255)), 0, 0);
        } else if (base_color == 2) {
          background.pixels[x+y*background.width] = color(0, int(random(255)), 0);
        } else if (base_color == 3) {
          background.pixels[x+y*background.width] = color(0, 0, int(random(255)));
        } else if (base_color == 4) {
          background.pixels[x+y*background.width] = color(int(random(255)));
        }
      }
    }
  }

  background.updatePixels();




  //Shapes
  new_texture = createGraphics(texture_width, texture_height);
  new_texture.beginDraw();

  //Fill Color
  if (base_color == 1) {
    fill_color = #FFFFFF;
  } else if (base_color == 2) {
    fill_color = #F7FF1C;
  } else if (base_color == 3) {
    fill_color = #8FEDF0;
  } else if (base_color == 4) {
    fill_color = #000000;
  }

  //Set Background With the Background Image
  new_texture.background(background);

  //Add Shapes
  for (int i = 0; i< 300; i++) {
    new_texture.fill(fill_color);
    new_texture.stroke(fill_color);

    //Size
    float random_raio = random(5,20);
    float random_rect = random(5,20);
    float random_triangle = random(-20,20);
    float random_line = random(-60,60);

    if (shape_size == 1) {
      random_raio = random(5,20);
      random_rect = random(5,20);
      random_triangle = random(-20,20);
      random_line = random(-60,60);
    } else if (shape_size == 2) {
       random_raio = random(20,35);
      random_rect = random(20,35);
      random_triangle = random(-40,40);
      random_line = random(-100,100);
    } else if (shape_size == 3) {
       random_raio = random(35,50);
      random_rect = random(35,50);
      random_triangle = random(-60,60);
      random_line = random(-140,140);
    }

    if (shape == 1) {
      new_texture.ellipse(random(texture_width), random(texture_height), random_raio, random_raio);
    } else if (shape == 2) {
      new_texture.rect(random(texture_width), random(texture_height), random_rect,  random_rect);
    } else if (shape == 3) {
      float inicial_x = random(texture_width), inicial_y = random(texture_height);
      new_texture.triangle(inicial_x, inicial_y, inicial_x+random_triangle, inicial_y+random_triangle, inicial_x+random_triangle, inicial_y+random(-20, 20));
    } else if (shape == 4) {
      float inicial_x = random(texture_width), inicial_y = random(texture_height);

      new_texture.strokeWeight(2);
      new_texture.line(inicial_x, inicial_y, inicial_x+random_line, inicial_y+random_line);
    }
  }

  new_texture.endDraw();

  //Return Final Texture
  return new_texture;
}
