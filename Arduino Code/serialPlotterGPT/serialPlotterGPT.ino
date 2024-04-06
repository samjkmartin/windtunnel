const int sensorPin = A0; // Analog pin connected to the sensor
const int numSamples = 1000; // Number of samples to record
int samples[numSamples]; // Array to store the samples

void setup() {
  Serial.begin(9600); // Initialize serial communication
}

void loop() {
  // Record analog voltage samples
  for (int i = 0; i < numSamples; i++) {
    samples[i] = analogRead(sensorPin);
    delay(10); // Delay between samples
  }

  // Output recorded samples
  for (int i = 0; i < numSamples; i++) {
    Serial.println(samples[i]);
  }

  // Plot data on serial plotter
  for (int i = 0; i < numSamples; i++) {
    Serial.print(i);
    Serial.print("\t");
    Serial.println(samples[i]);
  }
  
  delay(1000); // Delay before starting again
}
