import processing.serial.*;

Serial myPort;

PGraphics new_texture;
boolean drawn_texture;

int texture_width, texture_height, shape, base, base_color, shape_size, n;
color fill_color;

byte [] currentUser ={0, 0, 0, 0};
byte [] previousUser = {0, 0, 0, 0};
String myString;
int lf = 10;

void setup() {
  //Configurar e Limpar a Serial Port
  printArray(Serial.list());
  /*String portName = Serial.list()[2];
   myPort = new Serial(this, portName, 9600);
   myPort.clear();*/

  //Janela
  size(640, 640, P3D);
  background(0);

  //Test Variables
  base = 1;
  base_color = 1;
  shape = 1;
  shape_size = 1;

  drawn_texture = false;

  texture_width = 640;
  texture_height = 640;

  //Captures
  n = 1;
}

void draw() {
  //background(0);

  //Read Data
  /*while (myPort.available() > 0) {
   getData();
   }*/

  //Textura
  if (drawn_texture == false) {
    new_texture = texture_generation(base, base_color, shape, shape_size, texture_width, texture_height);
    drawn_texture = true;
    //image(new_texture, 0, 0);
    shape();
  }
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

  previousUser = currentUser; //VER CÓDIGO

  //Ler a informação da serial port
  myString = myPort.readStringUntil(lf);
  println(myString);

  if (myString != null) {

    if (myString.charAt(0) == 'U') {

      String[] userIdSplit = split(myString, ' ');

      for (int i = 1; i < 5; i++) {
        currentUser[i-1] = byte(int(userIdSplit[i]));
        //println(hex(currentUser[i-1]));
      }
    }
  }

  //VER CÓDIGO
  if (previousUser != currentUser) {
    drawn_texture = false;
  }

  byte [] load = loadBytes(str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3])+".dat");
  //byte [] load = loadBytes("19 52 61 -67.dat");
  //byte [] load = loadBytes("-96 72 -101 83.dat");

  base = load[0];
  base_color = load[1];
  shape = load[2];
  //shape_size = load[3];
}