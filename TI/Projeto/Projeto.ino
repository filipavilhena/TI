/*
 * --------------------------------------------------------------------------------------------------------------------
 * Example sketch/program showing how to read data from a PICC to serial.
 * --------------------------------------------------------------------------------------------------------------------
 * This is a MFRC522 library example; for further details and other examples see: https://github.com/miguelbalboa/rfid
 * 
 * Example sketch/program showing how to read data from a PICC (that is: a RFID Tag or Card) using a MFRC522 based RFID
 * Reader on the Arduino SPI interface.
 * 
 * When the Arduino and the MFRC522 module are connected (see the pin layout below), load this sketch into Arduino IDE
 * then verify/compile and upload it. To see the output: use Tools, Serial Monitor of the IDE (hit Ctrl+Shft+M). When
 * you present a PICC (that is: a RFID Tag or Card) at reading distance of the MFRC522 Reader/PCD, the serial output
 * will show the ID/UID, type and any data blocks it can read. Note: you may see "Timeout in communication" messages
 * when removing the PICC from reading distance too early.
 * 
 * If your reader supports it, this sketch/program will read all the PICCs presented (that is: multiple tag reading).
 * So if you stack two or more PICCs on top of each other and present them to the reader, it will first output all
 * details of the first and then the next PICC. Note that this may take some time as all data blocks are dumped, so
 * keep the PICCs at reading distance until complete.
 * 
 * @license Released into the public domain.
 * 
 * Typical pin layout used:
 * -----------------------------------------------------------------------------------------
 *             MFRC522      Arduino       Arduino   Arduino    Arduino          Arduino
 *             Reader/PCD   Uno/101       Mega      Nano v3    Leonardo/Micro   Pro Micro
 * Signal      Pin          Pin           Pin       Pin        Pin              Pin
 * -----------------------------------------------------------------------------------------
 * RST/Reset   RST          9             5         D9         RESET/ICSP-5     RST
 * SPI SS      SDA(SS)      10            53        D10        10               10
 * SPI MOSI    MOSI         11 / ICSP-4   51        D11        ICSP-4           16
 * SPI MISO    MISO         12 / ICSP-1   50        D12        ICSP-1           14
 * SPI SCK     SCK          13 / ICSP-3   52        D13        ICSP-3           15
 *
 * More pin layouts for other boards can be found here: https://github.com/miguelbalboa/rfid#pin-layout
 */

#include <SPI.h>
#include <MFRC522.h>

#define RST_PIN 9  // Configurable, see typical pin layout above
#define SS_PIN 10  // Configurable, see typical pin layout above

int ledPin = 7;

MFRC522 mfrc522(SS_PIN, RST_PIN);  // Create MFRC522 instance

byte accessUID[4] = { 0x13, 0x34, 0x3D, 0xBD };

//int buzzerPin = 4;

int potPin = A0;
int savePin = 6;
int but1Pin = 5;
int but2Pin = 4;
int but3Pin = 3;
int but4Pin = 2;

int saveState;                           // the current reading from the input pin
int lastSaveState = LOW;                 // the previous reading from the input pin
unsigned long lastSaveDebounceTime = 0;  // the last time the output pin was toggled

int but1State;                           // the current reading from the input pin
int lastBut1State = LOW;                 // the previous reading from the input pin
unsigned long lastBut1DebounceTime = 0;  // the last time the output pin was toggled

int but2State;                           // the current reading from the input pin
int lastBut2State = LOW;                 // the previous reading from the input pin
unsigned long lastBut2DebounceTime = 0;  // the last time the output pin was toggled

int but3State;                           // the current reading from the input pin
int lastBut3State = LOW;                 // the previous reading from the input pin
unsigned long lastBut3DebounceTime = 0;  // the last time the output pin was toggled~

int but4State;                           // the current reading from the input pin
int lastBut4State = LOW;                 // the previous reading from the input pin
unsigned long lastBut4DebounceTime = 0;  // the last time the output pin was toggled

unsigned long debounceDelay = 20;  // the debounce time; increase if the output flickers

void setup() {

  //pinMode(buzzerPin, OUTPUT);
  pinMode(potPin, INPUT);
  pinMode(savePin, INPUT);
  pinMode(but1Pin, INPUT);
  pinMode(but2Pin, INPUT);
  pinMode(but3Pin, INPUT);

  pinMode(ledPin, OUTPUT);

  // set initial LED state
  digitalWrite(savePin, saveState);
  digitalWrite(but1Pin, but1State);
  digitalWrite(but2Pin, but2State);
  digitalWrite(but3Pin, but3State);

  digitalWrite(ledPin, LOW);

  Serial.begin(9600);  // Initialize serial communications with the PC
  while (!Serial)
    ;                                 // Do nothing if no serial port is opened (added for Arduinos based on ATMEGA32U4)
  SPI.begin();                        // Init SPI bus
  mfrc522.PCD_Init();                 // Init MFRC522
  delay(4);                           // Optional delay. Some board do need more time after init to be ready, see Readme
  mfrc522.PCD_DumpVersionToSerial();  // Show details of PCD - MFRC522 Card Reader details
  Serial.println(F("Scan PICC to see UID, SAK, type, and data blocks..."));
}

void loop() {

  int readingSave = digitalRead(savePin);
  int readingBut1 = digitalRead(but1Pin);
  int readingBut2 = digitalRead(but2Pin);
  int readingBut3 = digitalRead(but3Pin);
  int readingBut4 = digitalRead(but4Pin);

  if (readingSave != lastSaveState) {
    // reset the debouncing timer
    lastSaveDebounceTime = millis();
  }
  if (readingBut1 != lastBut1State) {
    // reset the debouncing timer
    lastBut1DebounceTime = millis();
  }
  if (readingBut2 != lastBut2State) {
    // reset the debouncing timer
    lastBut2DebounceTime = millis();
  }
  if (readingBut3 != lastBut3State) {
    // reset the debouncing timer
    lastBut3DebounceTime = millis();
  }
  if (readingBut4 != lastBut4State) {
    // reset the debouncing timer
    lastBut4DebounceTime = millis();
  }

  if ((millis() - lastSaveDebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (readingSave != saveState) {
      saveState = readingSave;

      // only toggle the LED if the new button state is HIGH
      if (saveState == HIGH) {
        saveState = !saveState;

        Serial.println("Button:Save");
      }
    }
  }
  if ((millis() - lastBut1DebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (readingBut1 != but1State) {
      but1State = readingBut1;

      // only toggle the LED if the new button state is HIGH
      if (but1State == HIGH) {
        but1State = !but1State;

        Serial.println("Button:1");
      }
    }
  }
  if ((millis() - lastBut2DebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (readingBut2 != but2State) {
      but2State = readingBut2;

      // only toggle the LED if the new button state is HIGH
      if (but2State == HIGH) {
        but2State = !but2State;

        Serial.println("Button:2");
      }
    }
  }
  if ((millis() - lastBut3DebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (readingBut3 != but3State) {
      but3State = readingBut3;

      // only toggle the LED if the new button state is HIGH
      if (but3State == HIGH) {
        but3State = !but3State;

        Serial.println("Button:3");
      }
    }
  }
  if ((millis() - lastBut4DebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (readingBut4 != but4State) {
      but4State = readingBut4;

      // only toggle the LED if the new button state is HIGH
      if (but4State == HIGH) {
        but4State = !but4State;

        Serial.println("Button:4");
      }
    }
  }

  // set the LED:
  digitalWrite(savePin, saveState);
  digitalWrite(but1Pin, but1State);
  digitalWrite(but2Pin, but2State);
  digitalWrite(but3Pin, but3State);
  digitalWrite(but4Pin, but4State);

  // save the reading. Next time through the loop, it'll be the lastButtonState:
  lastSaveState = readingSave;
  lastBut1State = readingBut1;
  lastBut2State = readingBut2;
  lastBut3State = readingBut3;
  lastBut4State = readingBut4;

  // Reset the loop if no new card present on the sensor/reader. This saves the entire process when idle.
  if (mfrc522.PICC_IsNewCardPresent()) {
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
    return;
  }

  // Select one of the cards
  if (mfrc522.PICC_ReadCardSerial()) {
  } else {
    return;
  }

  Serial.print("U: ");
  for (int i = 0; i < 4; i++) {
    Serial.print(mfrc522.uid.uidByte[i]);
    Serial.print(" ");
  }

  // Dump debug info about the card; PICC_HaltA() is automatically called
  //mfrc522.PICC_DumpToSerial(&(mfrc522.uid.uidByte));


  if (mfrc522.uid.uidByte[0] == accessUID[0] && mfrc522.uid.uidByte[1] == accessUID[1] && mfrc522.uid.uidByte[2] == accessUID[2] && mfrc522.uid.uidByte[3] == accessUID[3]) {
    Serial.println("Access Granted");
  } else {
    Serial.println("Access Denied");
    //digitalWrite(buzzerPin, HIGH);
    delay(1000);
    //digitalWrite(buzzerPin, LOW);
  }

  mfrc522.PICC_HaltA();
}
