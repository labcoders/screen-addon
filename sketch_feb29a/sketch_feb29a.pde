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


#define HSYNC_BACKPORCH_MICROS 336
#define HSYNC_PULSE_MICROS 672
#define HSYNC_FRONTPORCH_MICROS 112
#define VSYNC_BACKPORCH_MICROS 23312
#define VSYNC_PULSE_MICROS 1504
#define VSYNC_FRONTPORCH_MICROS 8272

unsigned char buf[100][102];

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
}

void loop()
{
}
