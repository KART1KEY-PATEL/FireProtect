void setup() {
  // Initialize all pins as INPUT
  for (int pin = 2; pin <= 10; pin++) {
    pinMode(pin, INPUT);
  }

  // Begin serial communication
  Serial.begin(9600);
}

void loop() {
  // Read values from pins
  int val2 = digitalRead(2);
  int val3 = digitalRead(3);
  int val4 = digitalRead(4);
  int val5 = digitalRead(5);
  int val6 = digitalRead(6);
  int val7 = digitalRead(7);
  int val8 = digitalRead(8);
  int val9 = digitalRead(9);
  int val10 = digitalRead(10);

  // Create JSON string
  String jsonData = "{";
  jsonData += "\"Val2\":" + String(val2) + ",";
  jsonData += "\"Val3\":" + String(val3) + ",";
  jsonData += "\"Val4\":" + String(val4) + ",";
  jsonData += "\"Val5\":" + String(val5) + ",";
  jsonData += "\"Val6\":" + String(val6) + ",";
  jsonData += "\"Val7\":" + String(val7) + ",";
  jsonData += "\"Val8\":" + String(val8) + ",";
  jsonData += "\"Val9\":" + String(val9) + ",";
  jsonData += "\"Val10\":" + String(val10);
  jsonData += "}";

  // Send JSON data over Serial
  Serial.println(jsonData);

  // Wait 1 second before sending the next update
  delay(1000);
}
