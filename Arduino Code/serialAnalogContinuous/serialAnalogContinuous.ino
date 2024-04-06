const int sensorPin = A0; // Analog pin connected to the sensor
int a; // analog pin value between 0 and 1023
float voltage; // voltage output from the pressure sensor, from 0 to 5 volts

// Note: a float is 32 bits. Therefore, for a baud rate of 9600, 
// the arduino can theoretically send a maximum of 9600/32 = 300 values per second. 
// For a 19200 baud rate, the max would be 600 values per second. 
// However, in practice, the output rate may be lower (see "serialPlotterRandom" code). 
void setup() {
  Serial.begin(19200); // Initialize serial communication
}

void loop() {
  a = analogRead(sensorPin); // get value from analog pin
  voltage = a*5.0/1023.0; // convert to a decimal value between 0 and 5
  Serial.print("Voltage:");
  Serial.print("/t"); 
  Serial.println(voltage);
}