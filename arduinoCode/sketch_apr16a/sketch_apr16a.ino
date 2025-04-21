#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "Potato";
const char* password = "iloveass";

// Firebase project settings - Use Realtime Database instead of Firestore
// const String databaseURL = "https://firedetect-52cc8-default-rtdb.firebaseio.com"; // Add .firebaseio.com and make sure you have "-default-rtdb" in the URL
const String databaseURL = "https://firedetect-52cc8-default-rtdb.asia-southeast1.firebasedatabase.app"; 
const String firebaseAuth = "AIzaSyDypq6gqHwVpknUWb4eM-5mUJtrvq6GgqY";

void setup() {
  pinMode(4, INPUT);  
  pinMode(5, INPUT);  
  pinMode(13, INPUT); 
  pinMode(14, INPUT); 
  pinMode(22, INPUT); 
  pinMode(23, INPUT); 
  pinMode(18, INPUT); 
  pinMode(19, INPUT); 
  pinMode(21, INPUT); 

  Serial.begin(9600);
  
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.println("Connected to WiFi");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  
  initializeSensorData();
}

void initializeSensorData() {
  DynamicJsonDocument doc(1024);
  
  doc["sensor1"] = false;
  doc["sensor2"] = false;
  doc["sensor3"] = false;
  doc["sensor4"] = false;
  doc["sensor5"] = false;
  doc["sensor6"] = false;
  doc["sensor7"] = false;
  doc["sensor8"] = false;
  doc["sensor9"] = false;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  updateFirebase(jsonString);
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    DynamicJsonDocument doc(1024);
    
    doc["sensor1"] = digitalRead(4) == HIGH;  
    doc["sensor2"] = digitalRead(5) == HIGH;
    doc["sensor3"] = digitalRead(13) == HIGH;
    doc["sensor4"] = digitalRead(14) == HIGH;
    doc["sensor5"] = digitalRead(22) == HIGH;
    doc["sensor6"] = digitalRead(23) == HIGH;
    doc["sensor7"] = digitalRead(18) == HIGH;
    doc["sensor8"] = digitalRead(19) == HIGH;
    doc["sensor9"] = digitalRead(21) == HIGH;
    
    String jsonString;
    serializeJson(doc, jsonString);
    
    
    Serial.println(jsonString);
    
    updateFirebase(jsonString);
  }
  
  delay(100); 
}

void updateFirebase(String jsonData) {
  HTTPClient http;
  
  String url = databaseURL + "/sensor_data/data.json?auth=" + firebaseAuth;
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpResponseCode = http.sendRequest("PATCH", jsonData);
  
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("HTTP Response code: " + String(httpResponseCode));
    Serial.println(response);
  } else {
    Serial.println("Error on HTTP request: " + String(httpResponseCode));
  }
  
  http.end();
}