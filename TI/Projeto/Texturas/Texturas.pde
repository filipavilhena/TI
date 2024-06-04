import processing.serial.*;

Serial myPort;

PGraphics new_texture;
PImage noise_texture, wave_texture, gradient_texture;

int texture_width, texture_height, shape, base, base_color, n;
color fill_color;

byte [] currentUser ={0, 0, 0, 0};
String myString;
int lf = 10;

void setup() {
  //Configurar e Limpar a Serial Port
  printArray(Serial.list());
  String portName = Serial.list()[2];
  myPort = new Serial(this, portName, 9600);
  myPort.clear();

  //Janela
  size(640, 640, P3D);

  //Test Variables
  base = 0;
  base_color = 0;
  shape = 0;

  texture_width = 640;
  texture_height = 640;

  //Captures
  n = 1;
}

void draw() {
  background(0);

  //Read Data
  while (myPort.available() > 0) {
    getData();
  }

  //Textura
  new_texture = texture_generation(base, base_color, shape, texture_width, texture_height);
  //image(new_texture, 0, 0);
  shape();
}

//Create Shape and Fill with Texture
void shape() {
  textureMode(NORMAL);

  beginShape();
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
  }

  if (key == 'p') {
    n++;
    save("teste"+n+".png");
  }
}

void getData() {
     
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

  byte [] load = loadBytes(str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3])+".dat");
  //byte [] load = loadBytes("19 52 61 -67.dat");
  //byte [] load = loadBytes("-96 72 -101 83.dat");

  base = load[0];
  base_color = load[1];
  shape = load[2];
}
