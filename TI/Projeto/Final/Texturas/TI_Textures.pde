import processing.serial.*;

Serial myPort;

PGraphics new_texture;
boolean drawn_texture = false;

int texture_width, texture_height, shape, base, base_color, shape_size, n;
color fill_color;

JSONArray contours, points;
JSONObject contour, point;

byte [] currentUser = {0, 0, 0, 0};
byte [] previousUser = {1, 1, 1, 1};
String myString;
int lf = 10;

void setup() {
  //Configurar e Limpar a Serial Port
  printArray(Serial.list());
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.clear();

  noStroke();
  //Janela
  size(800, 800, P3D);
  background(0);

  //Test Variables
  base = 1;
  base_color = 1;
  shape = 1;
  shape_size = 1;

  texture_width = 800;
  texture_height = 800;

  //Shape
  contours = loadJSONArray("../data/0 0 0 0.json");
  /*contour = contours.getJSONObject(0);
   points = contour.getJSONArray("points");
   point = points.getJSONObject(0);*/
  //float x = point.getFloat("x");
  new_texture = texture_generation(base, base_color, shape, shape_size, texture_width, texture_height);

  //Captures
  n = 1;

  smooth(8);
}

void draw() {
  //background(0);
  //println(drawn_texture);

  //Read Data
  /*previousUser = currentUser;
   println("pu" + previousUser);*/
  //println(myPort.available()>0);

  while (myPort.available() > 0) {
    getData();
  }

  String strCurr = str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3]);
  String strPrev = str(previousUser[0])+" "+str(previousUser[1])+" "+str(previousUser[2])+" "+str(previousUser[3]);

  println(strCurr);
  println(strPrev);

  if (strCurr.equals(strPrev)) {

    println("AQUI");

    if (drawn_texture == false) {

      drawn_texture = true;
    }
  } else {

    println("BUS");

    byte [] load = loadBytes("../data/" + str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3])+".dat");
    contours = loadJSONArray("../data/" + str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3])+".json");

    base = load[0];
    base_color = load[1];
    shape = load[2];
    shape_size = load[3];

    new_texture = texture_generation(base, base_color, shape, shape_size, texture_width, texture_height);

    shape_contour();

    previousUser[0] = currentUser[0];
    previousUser[1] = currentUser[1];
    previousUser[2] = currentUser[2];
    previousUser[3] = currentUser[3];
    //
  }

  pushStyle();

  rectMode(CORNER);
  //blendMode(MULTIPLY);
  fill(0);
  for (int i = 0; i < 20; i++) {
    rect(random(width), random(height), 1, 1);
  }

  popStyle();

  blendMode(BLEND);

  //println(drawn_texture);
  //Textura
  /*if (drawn_texture == false) {*/

  //drawn_texture = true;
  //image(new_texture, 0, 0);
  //shape();

  /*}*/

  //println(currentUser);
}

//Create Shape and Fill with Texture
void shape() {
  textureMode(NORMAL);
  beginShape();
  tint(255, 128); //  Transparency
  texture(new_texture);
  vertex(40, 80, 0, 0);
  vertex(320, 20, 1, 0);
  vertex(640, 360, 1, 1);
  vertex(160, 640, 0, 1);
  endShape();
}

void shape_contour() {
  float x;
  float y;

  textureMode(IMAGE);
  for (int i=0; i<contours.size(); i++) {
    beginShape();
    contour = contours.getJSONObject(i);
    points = contour.getJSONArray("points");
    tint(255, 180); //  Transparency
    texture(new_texture);
    for (int j=0; j<points.size(); j++) {
      point = points.getJSONObject(j);
      x = point.getFloat("x");
      y = point.getFloat("y");
      vertex(x, y, x, y);
      //println(x);
      //println(y);
    }


    endShape(CLOSE);
  }
}

//Control Test Variables
void keyPressed() {
  if (key == 'b') {
    base ++;
    if (base >= 5) {
      base = 1;
    }
  } else if (key == 'c') {
    base_color ++;
    if (base_color >= 5) {
      base_color = 1;
    }
  } else if (key == 's') {
    shape ++;
    if (shape >= 5) {
      shape = 1;
    }
  } else if (key == 't') {
    shape_size ++;
    if (shape_size >= 4) {
      shape_size = 1;
    }
  }

  if (key == 'p') {
    n++;
    save("teste"+n+".png");
  }

  if (key == 'd') {
    drawn_texture = !drawn_texture;
  }
}

void getData() {
  //println(currentUser);

  //Ler a informação da serial port
  myString = myPort.readStringUntil(lf);
  //println(myString);

  if (myString != null) {

    if (myString.charAt(0) == 'U') {

      String[] userIdSplit = split(myString, ' ');

      for (int i = 0; i < 4; i++) {
        currentUser[i] = byte(int(userIdSplit[i+1]));
      }
    }
  }
}



/*

 */
