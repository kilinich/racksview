#include <Adafruit_NeoPixel.h>

#define PIN 2
#define NUMPIXELS 10
// Time values are the amounts of cycles (eash 50 miliseconds), not time
#define NORMALTIME 30000
#define FAILTIME 6000
#define RECOVERYTIME 6000

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
long INNERTIMER = 0;
long FAILURETIMER = 0;
bool FAILED = 0;
long FAILEDLED[] = {1, 3, 5, 7};
long FAILEDLEDID = random(1, 4);
bool RECOVERYPHASE = 0;
long RECOVERYTIMER = 0;
long RECOVERYFLAG = 1;

void setup() {
  strip.begin();
  strip.show();
  // Standby
  strip.setPixelColor(0, strip.Color(255, 165, 0));
  strip.show();
  delay(5000);
  // Initialization
  for(int i = 8; i > 0; i -= 2) {
    strip.clear();
    strip.setPixelColor(9, strip.Color(255, 165, 0));
    strip.setPixelColor(0, strip.Color(0, 0, 255));
    strip.setPixelColor(i, strip.Color(0, 255, 0));
    strip.show();
    delay(250);
  }
}

void loop() {
  strip.clear();
  if(FAILED) { // Drive failure operation
    if(FAILURETIMER < FAILTIME) {
      FAILURETIMER += 1;
    }
    else {
      FAILURETIMER = 0;
      FAILED = 0;
      RECOVERYPHASE = 1;
    }
    for(int i = 1; i < 9; i+=2) {
      if(random(2) == 1) {
        if(random(2) == 1 && i != FAILEDLED[FAILEDLEDID]) {
          strip.setPixelColor(i + 1, strip.Color(0, 255, 0));
        }
      }
    }
    strip.setPixelColor(FAILEDLED[FAILEDLEDID], strip.Color(255, 0, 0));
    strip.setPixelColor(0, strip.Color(0, 255, 0));
    strip.setPixelColor(9, strip.Color(255, 165, 0));
  }
  else if (RECOVERYPHASE) { // Recovery operation
    if(RECOVERYTIMER < RECOVERYTIME) {
      RECOVERYTIMER += 1;
    }
    else {
      RECOVERYTIMER = 0;
      RECOVERYPHASE = 0;
    }
    if (FAILEDLED[FAILEDLEDID] < 5) {
      strip.clear();
      strip.setPixelColor(9, strip.Color(0, 0, 255));
      strip.setPixelColor(0, strip.Color(0, 255, 0));
      strip.setPixelColor(1, strip.Color(255, 165, 0));
      strip.setPixelColor(3, strip.Color(255, 165, 0));
      for(int i = 1; i < 9; i+=2) {
        if(random(2) == 1) {
          if(random(2) == 1) {
            strip.setPixelColor(i + 1, strip.Color(0, 255, 0));
          }
        }
      }
      if (RECOVERYFLAG) {
        strip.setPixelColor(2, strip.Color(0, 255, 0));
        strip.setPixelColor(4, strip.Color(0, 255, 0));
        RECOVERYFLAG = 0;
      }
      else {
        strip.setPixelColor(2, strip.Color(0, 0, 0));
        strip.setPixelColor(4, strip.Color(0, 0, 0));
        RECOVERYFLAG = 1;
      }
    }
    else {
      strip.clear();
      strip.setPixelColor(9, strip.Color(0, 0, 255));
      strip.setPixelColor(0, strip.Color(0, 255, 0));
      strip.setPixelColor(5, strip.Color(255, 165, 0));
      strip.setPixelColor(7, strip.Color(255, 165, 0));
      for(int i = 1; i < 9; i+=2) {
        if(random(2) == 1) {
          if(random(2) == 1) {
            strip.setPixelColor(i + 1, strip.Color(0, 255, 0));
          }
        }
      }
      if (RECOVERYFLAG) {
        strip.setPixelColor(6, strip.Color(0, 255, 0));
        strip.setPixelColor(8, strip.Color(0, 255, 0));
        RECOVERYFLAG = 0;
      }
      else {
        strip.setPixelColor(6, strip.Color(0, 0, 0));
        strip.setPixelColor(8, strip.Color(0, 0, 0));
        RECOVERYFLAG = 1;
      }
    }
  }
  else { // Normal operation
    if(FAILURETIMER < NORMALTIME) {
      FAILURETIMER += 1;
    }
    else {
      FAILURETIMER = 0;
      FAILED = 1;
      FAILEDLEDID = random(0, 4);
    }
    for(int i = 1; i < 9; i+=2) {
      if(random(2) == 1) {
        if(random(2) == 1) {
          strip.setPixelColor(i + 1, strip.Color(0, 255, 0));
        }
      }
    }
    strip.setPixelColor(9, strip.Color(0, 0, 255));
    strip.setPixelColor(0, strip.Color(0, 255, 0));
  }
  strip.show();
  delay(50);
}