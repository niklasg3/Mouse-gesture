/**
 * Very simple sketch that sends x,y values to Wekinator  
 * Run Wekinator with 2 inputs (mouse x & y)
 * Unlike the DTW Mouse Explorer, this does NOT also act as an output!
 * You should use one of your own outputs.
 **/
import processing.sound.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

SinOsc sine;
OscP5 oscP5;
NetAddress dest;
ControlP5 cp5;
PFont f, f2;
boolean isRecording = true; //mode
boolean isRecordingNow = true;

final float TONE_d = 1174.66;

int areaTopX = 140;
int areaTopY = 70;
int areaWidth = 450;
int areaHeight = 390;

int currentClass = 1;

void setup() {
  // colorMode(HSB);
  size(640, 480, P2D);
  noStroke();
  sine = new SinOsc(this);
  sine.play();

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  dest = new NetAddress("127.0.0.1", 6448);

  sine.play();

  //Create the font
  f = createFont("Courier", 14);
  textFont(f);
  f2 = createFont("Courier", 40);
  textAlign(LEFT, TOP);

  createControls();
  sendNames();
}

void sendNames() {
  OscMessage msg = new OscMessage("/wekinator/control/setInputNames");
  msg.add("mouseX"); 
  msg.add("mouseY");
  oscP5.send(msg, dest);
}

void createControls() {
  cp5 = new ControlP5(this);
  cp5.addToggle("isRecording")
    .setPosition(10, 20)
    .setSize(75, 20)
    .setValue(true)
    .setCaptionLabel("record/run")
    .setMode(ControlP5.SWITCH)
    ;
}

float cutSize = 200;

void drawText() {
  fill(255);
  textFont(f);
  if (isRecording) {
    text("Run Wekinator with 2 inputs (mouse x,y), 1 DTW output", 100, 20);
    text("Click and drag to record gesture #" + currentClass + " (press number to change)", 100, 35);
  } else {
    text("Click and drag to test", 100, 20);
  }
  text ("This program does NOT act as an output; run with your own output!", 100, 50);
}

void draw() {
  background(0);
  smooth();
  drawText();

  if (mousePressed) {
    noStroke();
    fill(255, 0, 0);
    ellipse(mouseX, mouseY, 10, 10);
  }
  drawClassifierArea();
  if (mousePressed && frameCount % 2 == 0) {
    sendOsc();
  }
  if (klasse == 1) {
    fill(255, 0, 0);
    rect(0, 0, cutSize, height);
    rect(width-cutSize, 0, cutSize, height);
  }
  if (klasse ==3){
    fill(0,0,255);
  ellipse(width/2,height/2,100,100);
  }
  if (klasse ==5){
  sine.freq(TONE_d);
  }
}

void drawClassifierArea() {
  stroke(255);
  noFill();
  rect(areaTopX, areaTopY, areaWidth, areaHeight, 7);
}

boolean inBounds(int x, int y) {
  if (x < areaTopX || y < areaTopY) {
    return false;
  }
  if (x > areaTopX + areaWidth || y > areaTopY + areaHeight) {
    return false;
  } 
  return true;
}

void mousePressed() {
  if (! inBounds(mouseX, mouseY)) {
    return;
  }
  if (isRecording) {
    isRecordingNow = true;
    OscMessage msg = new OscMessage("/wekinator/control/startDtwRecording");
    msg.add(currentClass);
    oscP5.send(msg, dest);
  } else {
    OscMessage msg = new OscMessage("/wekinator/control/startRunning");
    oscP5.send(msg, dest);
  }
}

void mouseReleased() {
  if (isRecordingNow) {
    isRecordingNow = false;
    OscMessage msg = new OscMessage("/wekinator/control/stopDtwRecording");
    oscP5.send(msg, dest);
  }
}



void keyPressed() {
  int keyIndex = -1;
  if (key >= '1' && key <= '9') {
    currentClass = key - '1' + 1;
  }
}

void sendOsc() {
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add((float)mouseX); 
  msg.add((float)mouseY);
  oscP5.send(msg, dest);
}

int klasse = 0;

//This is called automatically when OSC message is received
void oscEvent(OscMessage msg) {
  println(msg);
  if (msg.checkAddrPattern("/output_1")) {
    klasse = 1;
  }
  if (msg.checkAddrPattern("/output_2")) {
    klasse = 2;
  }
  if (msg.checkAddrPattern("/output_3")) {
    klasse = 3;
  }
  if (msg.checkAddrPattern("/output_4")) {
    klasse = 4;}
}
