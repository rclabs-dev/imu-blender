import hypermedia.net.*;
import processing.opengl.*;
import toxi.geom.*;
import toxi.processing.*;
import peasy.*;

PeasyCam cam;
UDP udp; //Create UDP object for recieving
ToxiclibsSupport gfx;

// UDP listen port
int UDP_PORT = 9999;

// Images for dice texture
PImage[] tex = new PImage[6];;

// toxclibs quaternion data
float[] q = new float[4];
Quaternion quat = new Quaternion(1, 0, 0, 0);

void setup() {
  size(800, 600, P3D);
  if (frame != null) {
    frame.setResizable(true);
  }
  
  cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  
  // Load image for six faces of the dice
  for (int i = 1; i <= 6; i++) {
    tex[i-1] = loadImage("dice"+i+".png");
  }
  
  gfx = new ToxiclibsSupport(this);

  // setup lights and antialiasing
  lights();
  smooth();
  textureMode(NORMAL);
  fill(255);
  stroke(color(44,48,32));
  
  // Start UDP server to listen
  udp= new UDP(this, UDP_PORT);
  udp.log(false);
  udp.listen(true);
  
}

void draw() {
  background(0);
  noStroke();
  lights();
  float[] axis = quat.toAxisAngle();
  translate(0,0,20);
  rotate(axis[0], -axis[1], axis[3], axis[2]);  
  scale(80);
  TexturedCube();
  
}

void TexturedCube() {
  // Front face
  beginShape(QUADS);
    texture(tex[0]);
    vertex(-1, -1,  1, 0, 0);
    vertex( 1, -1,  1, 1, 0);
    vertex( 1,  1,  1, 1, 1);
    vertex(-1,  1,  1, 0, 1);
  endShape();

  // Top face
  beginShape(QUADS);
    texture(tex[1]);
    vertex(-1, -1, -1, 0, 0);
    vertex( 1, -1, -1, 1, 0);
    vertex( 1, -1,  1, 1, 1);
    vertex(-1, -1,  1, 0, 1);
  endShape();

  // Right face
  beginShape(QUADS);
    texture(tex[2]);
    vertex( 1, -1,  1, 0, 0);
    vertex( 1, -1, -1, 1, 0);
    vertex( 1,  1, -1, 1, 1);
    vertex( 1,  1,  1, 0, 1);
  endShape();

  // Left face
  beginShape(QUADS);
  texture(tex[3]);
    vertex(-1, -1, -1, 0, 0);
    vertex(-1, -1,  1, 1, 0);
    vertex(-1,  1,  1, 1, 1);
    vertex(-1,  1, -1, 0, 1);
  endShape();

  // Bottom face
  beginShape(QUADS);
    texture(tex[4]);
    vertex(-1,  1,  1, 0, 0);
    vertex( 1,  1,  1, 1, 0);
    vertex( 1,  1, -1, 1, 1);
    vertex(-1,  1, -1, 0, 1);
  endShape(); 

  // Back face
  beginShape(QUADS);
    texture(tex[5]);
    vertex( 1, -1, -1, 0, 0);
    vertex(-1, -1, -1, 1, 0);
    vertex(-1,  1, -1, 1, 1);
    vertex( 1,  1, -1, 0, 1);
  endShape();

}

void receive(byte[] data){
  
  // Convert byte to string and get separeted quaternion data 
  data = subset(data, 0, data.length - 2);
  String[] message = split(new String( data ), ',');
  
  // Set quaternion data from received data
  q[0] = float(message[0]); // w
  q[1] = float(message[1]); // x
  q[2] = float(message[2]); // y
  q[3] = float(message[3]); // z
  quat.set(q[3], q[0], q[1], q[2]);
}


