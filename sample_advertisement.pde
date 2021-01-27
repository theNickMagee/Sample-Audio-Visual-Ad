import com.hamoid.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.spi.*;

VideoExport videoExport;

String audioFilePath = "song.mp3";

String SEP = "|";

BufferedReader reader;

float movieFPS = 30;

PImage img, streamingLogos;

String artistName, songName;

PFont artistFont, songFont;

int lineCount = 0;

FloatList allValues, timeValues;

int bufferSize = 1024;

float[] allVals, timeVals;

PGraphics lineCanvas;

color bgColor1 = color(250, 250, 250);
color bgColor2 = color(250, 250, 250);

color textColor = color(0,0,0);

String nowStreaming;

void setup() {
  size(600, 600);
  
   artistName = "Y O U R  N A M E  H E R E";
  artistFont = createFont("Bebas-Regular.ttf", 72);
  
  songName = "Song Name";
  songFont = createFont("Windsong.ttf", 32);
  textMode(SHAPE);
  
  nowStreaming = "NOW STREAMING ON";
  
  img = loadImage("sampleAlbum.png");
  
  streamingLogos = loadImage("streamingServicesLogos/logos.png");
  
  frameRate(1000);
  
  lineCanvas = createGraphics(600, 600);
  
  //audioToWaveFile(audioFilePath);
  
  reader = createReader(audioFilePath + "Wave.txt");
  
  allValues = new FloatList();
  timeValues = new FloatList();
  
  String line;
  
  try{
  line = reader.readLine();
  while (line != null) {
      String[] p = split(line, SEP);
      allValues.append(float(p[1]));
      timeValues.append(float(p[0]));
      line = reader.readLine();
    }
  }catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  
  timeVals = timeValues.array();
  
  allVals = allValues.array();

  // Set up the video exporting
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(movieFPS);
  videoExport.setAudioFileName(audioFilePath);
  videoExport.setQuality(60, 192);
  videoExport.startMovie();
  
   
}

void draw(){


  
  
  if (lineCount >= timeVals.length) {
    // Done reading the file.
    // Close the video file.
    videoExport.endMovie();
    exit();
  } else {
    // The first column indicates 
    // the sound time in seconds.
    float soundTime = timeVals[lineCount];
    
    while (videoExport.getCurrentTime() < soundTime && lineCount < timeVals.length - bufferSize) {
      //println(videoExport.getCurrentTime());
       background(0);
       setGradient(0, 0, width, height, bgColor1, bgColor2, 1);
       imageMode(CENTER);
       image(img, width/2, height/2 + 20, 300, 300);
       
       
       
       textFont(artistFont);
       textAlign(CENTER, BOTTOM);
       textSize(60);
       fill(textColor);
       text(artistName, width/2, 90);
       
       textSize(20);
       text(nowStreaming, 300, 520);
        image(streamingLogos, 300, 550);
       
       textFont(songFont);
       textSize(50);
       fill(textColor);
       text(songName, width/2, 165);
       
      noStroke();
      
      strokeWeight(2);
      stroke(textColor);
      //for(int i = 0; i < bufferSize-1; i++){
      //  float x1 = map(i, 0, bufferSize, width/2 - 150 , width/2 + 150 );
      //  float x2 = map(i+1, 0, bufferSize, width/2 - 150 , width/2 + 150 );
      //  float bufferVal = allVals[lineCount + i];
      //  float bufferVal2 = allVals[lineCount + i+1];
      //  line( x1, 500 + bufferVal*20, x2, 500 + bufferVal2*20 );
      //}
      
      for(int i = 0; i < bufferSize-1; i++){
        float y1 = map(i, 0, bufferSize, width/2 - 150 , width/2 + 150 ) + 20;
        float y2 = map(i+1, 0, bufferSize, width/2 - 150 , width/2 + 150 ) + 20;
        float bufferVal = allVals[lineCount + i];
        float bufferVal2 = allVals[lineCount + i+1];
        line( 500 + bufferVal*20,y1 , 500 + bufferVal2*20,  y2);
      }
      
      lineCanvas.beginDraw();
      lineCanvas.strokeWeight(2);
      lineCanvas.stroke(textColor);
      
      for(int i = 0; i < bufferSize-1; i++){
        float y1 = map(i, 0, bufferSize, width/2 - 150 , width/2 + 150 ) + 20;
        float y2 = map(i+1, 0, bufferSize, width/2 - 150 , width/2 + 150 ) + 20;
        float bufferVal = allVals[lineCount + i];
        float bufferVal2 = allVals[lineCount + i+1];
        lineCanvas.line( 100 + bufferVal*20,y1 , 100 + bufferVal2*20,  y2);
      }
      
      lineCanvas.endDraw();
      
      lineCanvas.beginDraw();
      
      //lineCanvas.filter(BLUR, 2);
      
      lineCanvas.endDraw();
      imageMode(CORNER);
      //blendMode(ADD);
      image(lineCanvas, 0, 0, 600, 600);
      lineCanvas.clear();
      videoExport.saveFrame();
      
      
    }
    lineCount += 1000;
  }
}


void keyPressed(){
  if (key == 'e' || key == 'p'){
    videoExport.endMovie();
    exit();
  }
}



void audioToWaveFile(String fileName) {
  
  PrintWriter output; //print writer

  Minim minim = new Minim(this); //new minim
  
  output = createWriter(dataPath(fileName + "Wave.txt")); //text file for fft

  AudioSample track = minim.loadSample(fileName, 2048); //minim audioSample from song file loaded

  float sampleRate = track.sampleRate(); 


  float[] leftChannel = track.getChannel(AudioSample.LEFT);  //get channel left as samples L
  float[] rightChannel = track.getChannel(AudioSample.RIGHT);  



    
    for (int i=0; i<leftChannel.length; ++i) {
      output.println(nf(i / sampleRate, 0, 5 )+ "|" + leftChannel[i]);
    }
    
  
  track.close();
  output.flush();
  output.close();
  println("Sound Waveform analysis done");
}

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == 0) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == 1) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}
