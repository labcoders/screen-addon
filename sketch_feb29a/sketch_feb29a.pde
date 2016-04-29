/*
 *
 *    Mapping of port bits to pins on Fubarino Mini.
 *
 *    Omitted pins means that they cannot be set with port registers PORTA, PORTB, or PORTC.
 *
 *    Port | Bit | Pin
 *    -----------------
 *      A  |  7  |  2
 *    -----------------
 *      A  |  0  |  5
 *    -----------------
 *      A  |  1  |  6
 *    -----------------
 *      B  |  0  |  7
 *    -----------------
 *      B  |  1  |  8
 *    -----------------
 *      B  |  2  |  9
 *    -----------------
 *      B  |  3  | 10 
 *    -----------------
 *      C  |  0  | 11 
 *    -----------------
 *      C  |  1  | 12
 *    -----------------
 *      C  |  2  | 13 
 *    -----------------
 *      B  |  4  | 17 
 *    -----------------
 *      A  |  4  | 18 
 *    -----------------
 *      C  |  3  | 20 
 *    -----------------
 *      C  |  4  | 21 
 *    -----------------
 *      C  |  5  | 22 
 *    -----------------
 *      B  |  5  | 23 
 *    -----------------
 *      B  |  7  | 24 
 *    -----------------
 *      C  |  6  | 27 
 *    -----------------
 *      C  |  7  | 28 
 *    -----------------
 *
 *    PORTA controls 4 pins
 *    PORTB controls 6 pins
 *    PORTC controls 8 pins
 *
 */

/* We will encode one pixel in the following format.
 0bRRGGBB
 where each pair of letters denotes, in order, the high bit for the color followed by the low bit for the color.
 Consequently, we can combine four shades of red, four shades of blue, and four shades of green.
 
 Notice that a pixel is coded on six bits. Hence, four pixels are coded on three bytes.
 */

// Make sure the bytes are unsigned types, otherwise right shift
// will result in sign extension.
#define BITWISE_BANG_1(p)        (PORTC=(p >> 2))

#define BITWISE_BANG_2R(p)       (PORTC = (p << 4))
#define BITWISE_BANG_2GB(q)      (PORTC |= (q >> 4))

#define BITWISE_BANG_3RG(q)      (PORTC = (q << 2))
#define BITWISE_BANG_3B(r)       (PORTC |= (r >> 6))

#define BITWISE_BANG_4(r)        (PORTC = r)

#define BITWISE_BLACK            (PORTC = 0)

#define HSYNC_HIGH               (PORTA |= B00000010)
#define HSYNC_LOW                (PORTA &= B11111101)
#define VSYNC_HIGH               (PORTA |= B00000001)
#define VSYNC_LOW                (PORTA &= B11111110)

#define PIXEL_NANOS 150

#define SCREEN_WIDTH_BYTES 99
#define SCREEN_HEIGHT_BYTES 102
const uint16_t SCREEN_WIDTH_PIXELS = SCREEN_WIDTH_BYTES * 4 / 3;
const uint16_t SCREEN_WIDTH_RESIDUAL_PIXELS = 0;
const uint16_t SCREEN_HEIGHT_LINES = SCREEN_HEIGHT_BYTES;
const uint16_t SCREEN_HEIGHT_RESIDUAL_LINES = 480 - SCREEN_HEIGHT_LINES;

const uint16_t HSYNC_BACKPORCH_MICROS = PIXEL_NANOS * 48 / 1000 - 2;
const uint16_t HSYNC_PULSE_MICROS = PIXEL_NANOS * 96 / 1000 - 2;
const uint16_t HSYNC_FRONTPORCH_MICROS = PIXEL_NANOS * 16 / 1000 - 2;
const uint16_t VSYNC_BACKPORCH_MICROS = PIXEL_NANOS * 800 * 31 / 1000 - 2;
const uint16_t VSYNC_PULSE_MICROS = PIXEL_NANOS * 800 * 2 / 1000 - 2;
const uint16_t VSYNC_FRONTPORCH_MICROS = PIXEL_NANOS * 800 * 11 / 1000 - 2;

unsigned char buf[SCREEN_WIDTH_BYTES][SCREEN_HEIGHT_BYTES];

unsigned long test_time()
{
  unsigned long time = micros();
  for (int a = 0; a < 100; a++)
  {
    for (int i = 0; i < 102; i+=3)
    {
      BITWISE_BANG_1(buf[a][i]);
      BITWISE_BANG_2R(buf[a][i]);
      BITWISE_BANG_2GB(buf[a][i+1]);
      BITWISE_BANG_3RG(buf[a][i+1]);
      BITWISE_BANG_3B(buf[a][i+2]);
      BITWISE_BANG_4(buf[a][i+2]);
    }
  }
  return ((micros() - time));
}


void setup()
{
  Serial.begin(9600);
  for (int i = 0; i < 32; i++) 
  {
    pinMode(i, OUTPUT);
  }
  
  for(int i = 0; i < SCREEN_WIDTH_BYTES; i++) {
    for(int j = 0; j < SCREEN_HEIGHT_BYTES; j++) {
      buf[i][j] = 0xff;
    }
  }
}

void loop()
{
  int i, j;
  
//  unsigned long time = micros();
  
  VSYNC_HIGH;
  delayMicroseconds(VSYNC_BACKPORCH_MICROS);
  
  for(j = 0; j < SCREEN_HEIGHT_BYTES; j++) {
    HSYNC_HIGH;
    delayMicroseconds(HSYNC_BACKPORCH_MICROS);
    
    for(i = 0; i < SCREEN_WIDTH_BYTES; i += 3) {
      BITWISE_BANG_1(buf[i][j]);
      BITWISE_BANG_2R(buf[i][j]);
      BITWISE_BANG_2GB(buf[i+1][j]);
      BITWISE_BANG_3RG(buf[i+1][j]);
      BITWISE_BANG_3B(buf[i+2][j]);
      BITWISE_BANG_4(buf[i+2][j]);
    }
    
    for(i = 0; i < SCREEN_WIDTH_RESIDUAL_PIXELS; i++) {
      BITWISE_BLACK;
    }
    
    HSYNC_LOW;
    delayMicroseconds(HSYNC_PULSE_MICROS);
    HSYNC_HIGH;
    delayMicroseconds(HSYNC_FRONTPORCH_MICROS);
  }
  
  for(j = 0; j < SCREEN_HEIGHT_RESIDUAL_LINES; j++) {
    for(i = 0; i < 400; i++) {
      BITWISE_BLACK;
    }
  }
  
  VSYNC_LOW;
  delayMicroseconds(VSYNC_PULSE_MICROS);
  VSYNC_HIGH;
  delayMicroseconds(VSYNC_FRONTPORCH_MICROS);
  
//  Serial.println((micros() - time));
}
