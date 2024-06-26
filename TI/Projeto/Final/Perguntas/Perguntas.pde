import gab.opencv.*;
import processing.serial.*;
import processing.video.*;

int step, lf;    // Linefeed in ASCII

String myString;
Serial myPort;  // The serial port

byte[] currentUser;
boolean confirmedNewUser;

byte[] answers;
int selectedAnswer;
int currDistance;

String[] questions = {"Para começar o teste, por favor",
  "O que farias se a vida te desse limões?",
  "Qual é a cor do teu lobo frontal?",
  "Qual destas comidas inclui\nmais spyware do governo?", " "};
String[][] options = {
  {"encosta o teu cartão da UC ao leitor.",
    "Prometemos não comprar torradas",
    "com a tua conta dos SASUC.",
  "Talvez. :)"},
  {"Limonada (cringe)", "Nada, sou alérgico", "I DON'T WANT YOUR DAMN LEMONS!", "Limonada (não cringe)"},
  {"Vermelho", "Verde", "Azul", "Amarelo"},
  {"Bolachas Maria", "Sandes Mista", "Pizza", "Esparguete"},
  {" ", "Sorria, está a ser filmado! :D", " ", " "}};
int qID;

Capture cam;
PImage src, result, bg;
OpenCV opencv;
ArrayList<Contour> contours;
boolean polygonApproximation;
boolean mask;

JSONArray contoursJSON;
JSONArray points;

int blurValue;
int thresholdValue;

//UI
PImage bg_img;
PFont font;

float randX;
float randY;
float randSize;

boolean newbg;

void setup() {
  smooth(8);
  size(900, 900);
  frameRate(30);
  
  newbg = false;
  
  myPort = new Serial(this, Serial.list()[0], 9600);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    //exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    //if it fails replace cameras[0] per "pipeline:autovideosrc"
    cam = new Capture(this, 1600, 900, cameras[0], 30);
    cam.start();

    opencv = new OpenCV(this, cam);

    bg = cam.copy();
  }

  init();
}

void init() {
  noStroke();

  step = 0;
  lf = 10;

  myString = null;

  currentUser = new byte[4];
  confirmedNewUser = true;
  answers = new byte[4];

  selectedAnswer = 0;
  currDistance = 0;

  qID = 0;

  polygonApproximation = true;
  mask = false;

  randX = random(-0.5, 0.5);
  randY = random(-0.5, 0.5);
  randSize = random(0, 0.5);



  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort.clear();
  // Throw out the first reading, in case we started reading
  // in the middle of a string from the sender.
  myString = myPort.readStringUntil(lf);
  myString = null;

  bg_img = loadImage("bg.jpg");
  bg_img.resize(900, 900);
  background(bg_img);
  //fill();

  textSize(30);

  font = createFont("font.ttf", 80);
}

void draw() {

  if (cam.available() == true && newbg == false) {
    cam.read();
    bg = cam.copy();
    println("AMGEIGEIUH");
    newbg = true;
  }

  randX = random(-0.5, 0.5);
  randY = random(-0.5, 0.5);
  randSize = random(0, 0.5);


  println(qID);

  if (qID != 4) {
    background(bg_img);
    rectMode(CENTER);
    fill(0);
    rect(width/2-randX, height/2-randY, 850, 850);
  }

  textSize(40);

  if (cam.available() == true && (qID == 4 || qID == 5)) {
    cam.read();

    src = cam.copy();

    image(src, 0, 0);

    opencv.loadImage(src);

    opencv.diff(bg);

    blurValue = 24;
    thresholdValue = 35;

    opencv.blur(blurValue);
    opencv.threshold(thresholdValue);

    contours = opencv.findContours();

    result = opencv.getOutput();

    image(result, 0, 0);
  }

  displayCurrentUser();
  if (qID < 5) {
    showQuestions(qID);
  } else if (qID < 6) {
    init();
  }

  //Leitura do input
  while (myPort.available() > 0) {
    myString = myPort.readStringUntil(lf);
    if (myString != null) {

      if (myString.charAt(0) == 'D') {
        String[] stringSplit = split(myString, ':');
        if (stringSplit.length > 1) {
          currDistance = int(float(stringSplit[1]));
        }
      }

      //Se recebeu input de um botao
      if (myString.charAt(0) == 'B') {
        String[] stringSplit = split(myString, ':');
        //text(stringSplit[1], 50, 200);

        //Se recebeu uma botao numerico
        if (stringSplit[1].charAt(0) != 'S') {
          //Por alguma razao aqui temos de converter para float primeiro e depois int, senao da 0. Fixe!
          selectedAnswer = int(float(stringSplit[1]));
          //text(selectedAnswer, 50, 250);
        } else {
          //Se recebeu um Save
          if (qID == 4) {
            saveBytes("../data/"+str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3])+".dat", answers);
            qID++;
          }

          if (qID == 5) {

            background(0);
            PImage img = cam.copy();
            image(img, 0, 0);
            //saveFrame();

            cam.read();

            src = cam.copy();

            opencv.loadImage(src);

            opencv.diff(bg);

            blurValue = 24;
            thresholdValue = 35;

            opencv.blur(blurValue);
            opencv.threshold(thresholdValue);

            contours = opencv.findContours();

            result = opencv.getOutput();

            image(result, 0, 0);

            // get countours
            println("found", contours.size(), "contours");

            //image(src, 0, 0);

            if (mask) {
              //result.filter(INVERT);
              // ensure that result has the same size than frame
              result = result.get(0, 0, src.width, src.height);
              PImage copiedFrame = src.copy();
              copiedFrame.mask(result);
              //image(copiedFrame, src.width, 0);
            } else {
              //image(result, src.width, 0);
            }

            noFill();
            strokeWeight(5);

            contoursJSON = new JSONArray();

            int index = 0;

            for (Contour contour : contours) {

              JSONObject cnt = new JSONObject();

              cnt.setInt("id", index);

              color c = polygonApproximation ? color(255, 0, 0) : color(0, 255, 0);
              // draw contour
              if (!polygonApproximation) {
                stroke(c);
                contour.draw();
              } else {
                stroke(c);
                beginShape();

                points = new JSONArray();

                println(contour.getPolygonApproximation().getPoints());

                int pointIndex = 0;

                for (PVector point : contour.getPolygonApproximation().getPoints()) {
                  vertex(point.x, point.y);

                  JSONObject pnt = new JSONObject();

                  pnt.setFloat("x", point.x);
                  pnt.setFloat("y", point.y);

                  points.setJSONObject(pointIndex, pnt);

                  pointIndex++;
                }

                cnt.setJSONArray("points", points);
                endShape(CLOSE);
              }

              contoursJSON.setJSONObject(index, cnt);

              index++;
            }

            saveJSONArray(contoursJSON, "../data/"+str(currentUser[0])+" "+str(currentUser[1])+" "+str(currentUser[2])+" "+str(currentUser[3])+".json");

            return;
          }
          //Temos de ter uma resposta selecionada
          //Não podemos guardar nada na primeira pergunta
          if (selectedAnswer != 0 && qID != 0) {
            answers[qID-1] = byte(selectedAnswer);
            selectedAnswer = 0;
            answers[3] = byte(currDistance);

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

        if (qID < 5) {
          showQuestions(qID);
        }

        //Se um cartao diferente foi lido
        if (byte(int(userIdSplit[1])) != currentUser[0]
          || byte(int(userIdSplit[2])) != currentUser[1]
          || byte(int(userIdSplit[3])) != currentUser[2]
          || byte(int(userIdSplit[4])) != currentUser[3]) {

          //Se ja foi confirmado que se quer mudar de user, escreve este user
          if (confirmedNewUser) {
            writeNewUser(userIdSplit);
            qID = 1;

            if (qID < 5) {
              showQuestions(qID);
            }

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
  textFont(font);
  textSize(28);
  if (qID == 0) {
    fill(255, 255, 180);
    text(questions[qID], width/2+randX, 200+randY);
    text("Clica no botão 'LOCK' para progredir no teste.", width/2+randX, 820+randY);
  } else {
    fill(255, 255, 180);
    text(questions[qID], width/2+randX, 250+randY);
  }

  //Para todas as opcoes de resposta
  for (int i = 0; i < 4; i++) {
    //Se nao for o texto introdutorio

    pushStyle();
    strokeWeight(3);
    fill(10);

    if (i==0) {
      stroke(175, 116, 116);
    } else if (i == 1) {
      stroke(134, 162, 121);
    } else if (i == 2) {
      stroke(137, 172, 180);
    } else if (i == 3) {
      stroke(194, 165, 105);
    }

    rectMode(CENTER);
    if (qID != 0 && qID != 4 && qID != 5) {
      rect(width/2+randX, 300 + (95*(i+1))+randY, 510, 80);
    }
    popStyle();

    if (qID != 0) {
      //Se for a opcao selecionada, muda o aspeto
      if (i+1 == selectedAnswer) {
        float randAberr = random(1, 2);
        fill(255, 100, 100);
        text(options[qID][i], width/2+randAberr, 300 + (95*(i+1))+randY);
        fill(100, 100, 255);
        text(options[qID][i], width/2-randAberr, 300 + (95*(i+1))+randY);

        fill(255, 255, 180);
      } else {
        fill(175);
      }
    }
    //Desenha a opcao
    textSize(28);

    if (qID == 0) {
      text(options[qID][i], width/2+randX, 200 + (95*(i+1))+randY);
    } else {
      text(options[qID][i], width/2+randX, 300 + (95*(i+1))+randY);
    }
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
  /*text(currentUser[0], 50, 50);
   text(currentUser[1], 150, 50);
   text(currentUser[2], 250, 50);
   text(currentUser[3], 350, 50);*/
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
      println(load[i]);
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
