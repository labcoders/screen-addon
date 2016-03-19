#define PIN(x) (x)

#define PIN_R_LO PIN(0)
#define PIN_R_HI PIN(2)
#define PIN_G_LO PIN(8)
#define PIN_G_HI PIN(10)
#define PIN_B_LO PIN(4)
#define PIN_B_HI PIN(6)
#define PIN_HSYNC PIN(18)
#define PIN_VSYNC PIN(20)

/* We will encode one pixel in the following format.
  0bRRGGBB
  where each pair of letters denotes, in order, the high bit for the color followed by the low bit for the color.
  Consequently, we can combine four shades of red, four shades of blue, and four shades of green.
  
  Notice that a pixel is coded on six bits. Hence, four pixels are coded on three bytes.
*/

#define BANG_PIXEL(p)       digitalWrite(PIN_R_HI, (p & 128)); \
                            digitalWrite(PIN_R_LO, (p & 64)); \
                            digitalWrite(PIN_G_HI, (p & 32)); \
                            digitalWrite(PIN_G_LO, (p & 16)); \
                            digitalWrite(PIN_B_HI, (p & 8)); \
                            digitalWrite(PIN_B_LO, (p & 4)); \
                            delay(1); \
                            digitalWrite(PIN_R_HI, (p & 2)); \
                            digitalWrite(PIN_R_LO, (p & 1));
#define BANG_PIXEL_2(q)     digitalWrite(PIN_G_HI, (q & 128)); \
                            digitalWrite(PIN_G_LO, (q & 64)); \
                            digitalWrite(PIN_B_HI, (q & 32)); \
                            digitalWrite(PIN_B_LO, (q & 16)); \
                            delay(1); \
                            digitalWrite(PIN_R_HI, q & 8); \
                            digitalWrite(PIN_R_LO, q & 4); \
                            digitalWrite(PIN_G_HI, q & 2); \
                            digitalWrite(PIN_G_LO, q & 1);
#define BANG_PIXEL_3(r)     digitalWrite(PIN_B_HI, r & 128); \
                            digitalWrite(PIN_B_LO, r & 64); \
                            delay(1); \
                            digitalWrite(PIN_R_HI, r & 32); \
                            digitalWrite(PIN_R_LO, r & 16); \
                            digitalWrite(PIN_G_HI, r & 8); \
                            digitalWrite(PIN_G_LO, r & 4); \
                            digitalWrite(PIN_B_HI, r & 2); \
                            digitalWrite(PIN_B_LO, r & 1);
#define HSYNC_BACKPORCH_MICROS 336
#define HSYNC_PULSE_MICROS 672
#define HSYNC_FRONTPORCH_MICROS 112
#define VSYNC_BACKPORCH_MICROS 23312
#define VSYNC_PULSE_MICROS 1504
#define VSYNC_FRONTPORCH_MICROS 8272

unsigned long test_time()
{
    unsigned long time = micros();
    for (int i = 0; i < 1000; i++)
    {
        digitalWrite(PIN_R_HI, HIGH);
        digitalWrite(PIN_R_LO, HIGH);
        digitalWrite(PIN_G_HI, HIGH);
        digitalWrite(PIN_G_LO, HIGH);
        digitalWrite(PIN_B_HI, HIGH);
        digitalWrite(PIN_B_LO, HIGH);
    }
    return ((micros() - time)/1000);
}

unsigned char buf[180][160];
                      
void setup()
{
  Serial.begin(9600);
  pinMode(PIN_R_LO, OUTPUT);
  pinMode(PIN_R_HI, OUTPUT);
  pinMode(PIN_G_LO, OUTPUT);
  pinMode(PIN_G_HI, OUTPUT);
  pinMode(PIN_B_LO, OUTPUT);
  pinMode(PIN_B_HI, OUTPUT);
}

void loop()
{
    Serial.println(test_time());
}
