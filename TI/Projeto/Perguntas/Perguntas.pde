import gab.opencv.*;
import processing.serial.*;
import processing.video.*;

int step = 0;

int lf = 10;    // Linefeed in ASCII
String myString = null;
Serial myPort;  // The serial port

byte[] currentUser = new byte[4];
boolean confirmedNewUser = true;

byte[] answers = new byte[4];
int selectedAnswer = 0;

String[] questions = {"Para começar o teste, por favor", "Pergunta 1", "Pergunta 2", "Pergunta 3", "Pergunta 4", " "};
String[][] options = {
  {"encosta o teu cartão da UC ao leitor.",
    "Prometemos não comprar torradas",
    "com a tua conta dos SASUC.",
  "Talvez. :)"},
  {"Q2 O1", "Q2 O2", "Q2 O3", "Q2 O4"},
  {"Q3 O1", "Q3 O2", "Q3 O3", "Q3 O4"},
  {"Q4 O1", "Q4 O2", "Q4 O3", "Q4 O4"},
  {"Q5 O1", "Q5 O2", "Q5 O3", "Q5 O4"},
  {" ", "Sorria, está a ser filmado! :D", " ", " "}};
int qID = 0;

Capture cam;
PImage src, result, bg;
OpenCV opencv;
ArrayList<Contour> contours;
void setup() {

  size(900, 900);
  background(0);

  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.clear();
  // Throw out the first reading, in case we started reading
  // in the middle of a string from the sender.
  myString = myPort.readStringUntil(lf);
  myString = null;

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    //exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    //if it fails replace cameras[0] per "pipeline:autovideosrc"
    cam = new Capture(this, 1280, 720, cameras[0], 30);
    cam.start();

    opencv = new OpenCV(this, cam);

    bg = cam.copy();
  }
  frameRate(30);
}

void draw() {

  if (qID != 5) {
    background(0);
  }
  textSize(40);

  if (cam.available() == true && qID == 5) {
    cam.read();

    src = cam.copy();

    opencv.loadImage(src);
    if (step < 1) {
      //opencv.gray();
    } else if (step < 2) {
      opencv.blur(5);
    } else if (step < 3) {
      opencv.blur(5);
      opencv.diff(bg);
    } else if (step < 4) {
      opencv.blur(5);
      opencv.diff(bg);
      opencv.threshold(100);
    } else if (step < 5) {
      opencv.blur(5);
      opencv.diff(bg);
      opencv.contrast(3);
      opencv.threshold(100);
      opencv.findCannyEdges(0, 150);
    } else if (step < 6) {
      opencv.blur(5);
      opencv.diff(bg);
      opencv.contrast(3);
      opencv.threshold(100);
      opencv.findCannyEdges(0, 150);
      println("found " + contours.size() + " contours");
    }

    contours = opencv.findContours();

    result = opencv.getOutput();

    image(result, 0, 0);

    pushStyle();
    for (Contour contour : contours) {
      noFill();
      stroke(0, 255, 0);
      contour.draw();

      stroke(255, 0, 0);
      beginShape();
      for (PVector point : contour.getPolygonApproximation().getPoints()) {
        vertex(point.x, point.y);
      }
      endShape();
    }
    popStyle();
  }

  displayCurrentUser();
  showQuestions(qID);

  //Leitura do input
  while (myPort.available() > 0) {
    myString = myPort.readStringUntil(lf);
    if (myString != null) {

      //Se recebeu input de um botao
      if (myString.charAt(0) == 'B') {
        String[] stringSplit = split(myString, ':');
        text(stringSplit[1], 50, 200);

        //Se recebeu uma botao numerico
        if (stringSplit[1].charAt(0) != 'S') {
          //Por alguma razao aqui temos de converter para float primeiro e depois int, senao da 0. Fixe!
          selectedAnswer = int(float(stringSplit[1]));
          text(selectedAnswer, 50, 250);
        } else {
          //Se recebeu um Save
          if (qID == 5) {
            saveBytes(str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3])+".dat", answers);
            return;
          }
          //Temos de ter uma resposta selecionada
          //Não podemos guardar nada na primeira pergunta
          if (selectedAnswer != 0 && qID != 0) {
            answers[qID-1] = byte(selectedAnswer);
            selectedAnswer = 0;

            qID++;
          }
        }

        //Se recebeu input do RFID ----- "U: 19 19 19 19 "
      } else if (myString.charAt(0) == 'U') {

        //Divide pelos espacos e ignora o U
        String[] userIdSplit = split(myString, ' ');

        //Se ainda nao existe um user
        if (checkUserEmpty()) {
          //Regista o novo user
          writeNewUser(userIdSplit);
        }

        showQuestions(qID);

        //Se um cartao diferente foi lido
        if (byte(int(userIdSplit[1])) != currentUser[0]
          || byte(int(userIdSplit[2])) != currentUser[1]
          || byte(int(userIdSplit[3])) != currentUser[2]
          || byte(int(userIdSplit[4])) != currentUser[3]) {

          //Se ja foi confirmado que se quer mudar de user, escreve este user
          if (confirmedNewUser) {
            writeNewUser(userIdSplit);
            qID = 0;
            showQuestions(qID);

            //Senao, pede confirmacao
          } else {
            confirmNewUser();
          }
        }
      }
    }
  }
}

void showQuestions(int qID) {

  pushStyle();

  //Desenha a pergunta
  textAlign(CENTER, CENTER);
  text(questions[qID], width/2, 350);

  //Para todas as opcoes de resposta
  for (int i = 0; i < 4; i++) {
    //Se nao for o texto introdutorio
    if (qID != 0) {
      //Se for a opcao selecionada, muda o aspeto
      if (i+1 == selectedAnswer) fill(255, 0, 0);
      else fill(255);
    }
    //Desenha a opcao
    text(options[qID][i], width/2, 350 + (50*(i+1)));
  }
  popStyle();
}

void writeNewUser(String[] userIdSplit) {
  //Escreve cada um dos bytes no sitio respetivo, ignorando o "U: "
  for (int i = 1; i < 5; i++) {
    currentUser[i-1] = byte(int(userIdSplit[i]));
    //println(hex(currentUser[i-1]));
  }
  //Impede escrever um novo user sem permissao
  confirmedNewUser = false;
  //Vai para a primeira pergunta
  qID = 1;
  //Reseta a opcao selecionada
  selectedAnswer = 0;
}

void confirmNewUser() {
  if (key == 'y') {
    confirmedNewUser = true;
  }
}

void displayCurrentUser() {
  text(currentUser[0], 50, 50);
  text(currentUser[1], 150, 50);
  text(currentUser[2], 250, 50);
  text(currentUser[3], 350, 50);
}

boolean checkUserEmpty() {
  if (currentUser[0] == 0
    && currentUser[1] == 0
    && currentUser[2] == 0
    && currentUser[3] == 0) {
    return true;
  } else {
    return false;
  }
}

void keyReleased() {
  confirmedNewUser = !confirmedNewUser;
  println(confirmedNewUser);

  if (key == 'n') {
    qID++;
  }
  if (key == 'v') {
    byte[] load = loadBytes(str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3])+".dat");
    for (int i = 0; i < 4; i++) {
      println("Gay: "+load[i]);
    }
  }
  if (key == 'p') {
    if (step < 8) {
      step++;
    } else {
      step = 0;
    }
  }
  if (key == 'b') {
    bg = src.copy();
  }
}
