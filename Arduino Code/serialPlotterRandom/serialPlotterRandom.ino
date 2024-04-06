int random_variable; // random value between 0 and 1000
float scaled; // random value scaled to be from 0 to 5

// Note: a float is 32 bits. Therefore, for a baud rate of 9600, 
// the arduino can theoretically send a maximum of 9600/32 = 300 values per second. 
// For a 19200 baud rate, the max would be 600 values per second. 
// However, in practice, the serial output rate appears to be 1/10 of the above. 
// I.e. for a 9600 bit rate, the time between output values (as viewed with timestamps
// in the serial monitor) is approximately 33ms, which gives 30 values per second. 
// I'm not sure if this is because of the speed of the "random" function or something else. 
// On later attempts, some of the timestamps repeat, so it's possible that the clock 
// just can't output timestamps faster than about 30Hz. 
// Just re-uploaded it, now the serial plotter plots ~500 points every 10 sec (50Hz)
// when I'm using 9600. Idek. 
// Yep, using 19200 baud, serial plotter shows ~1k points per 10 sec (100Hz)

void setup() {
  Serial.begin(19200);
}

void loop() {
  random_variable = random(0, 1000);
  scaled = random_variable/200.0; 

  Serial.print("Random_value:");
  Serial.print("\t");
  Serial.println(scaled);
}