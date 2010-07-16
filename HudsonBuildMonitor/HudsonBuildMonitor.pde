#include <Ethernet.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 140 };
byte server[] = { 192, 168, 1, 69 };
byte gateway[] = { 192, 168, 1, 254 };
byte subnet[] = {255, 255, 255, 0 };

Client client(server, 8080);

#define SUCCESS 2 // SUCCESS LED
#define FAILURE 3 // FAILURE LED
#define CHIRP 4 // HIGH ON FAILURE

void setSuccess(boolean success)
{
  if(!success) {
    digitalWrite(FAILURE, HIGH);
    digitalWrite(SUCCESS, LOW);
    digitalWrite(CHIRP, HIGH); 
    delay(100);
    digitalWrite(CHIRP, LOW);
    delay(100);
    digitalWrite(CHIRP, HIGH);
    Serial.println("Fail");
    
    boolean state = LOW;
    int count = 0;
    while(count < 24) {
     if(state == HIGH) {
       digitalWrite(FAILURE, LOW);
       state = LOW;
     }else{
       digitalWrite(FAILURE, HIGH);
       state = HIGH;
     }
     count++;
     delay(250);
   }
  }else{
    digitalWrite(SUCCESS, HIGH);
    digitalWrite(FAILURE, LOW);
    digitalWrite(CHIRP, LOW);
    Serial.println("Win");
    delay(6000);
  }
}

char success[] = "SUCCESS";
char failure[] = "FAILURE";
int length = 7;
int nextSuccess = 0;
int nextFailure = 0;

boolean matchSuccess(char c)
{
  if(c == success[nextSuccess]) {
    nextSuccess++;
    if(nextSuccess == length){
        return true;
    }
  }
  return false;
}

boolean matchFailure(char c)
{
  if(c == failure[nextFailure]) {
    nextFailure++;
    if(nextFailure == length){
        return true;
    }
  }
  return false;
}

void setup() {
  Ethernet.begin(mac, ip, gateway, subnet);
  Serial.begin(9600);
  
  pinMode(SUCCESS, OUTPUT);
  pinMode(FAILURE, OUTPUT);
  pinMode(CHIRP, OUTPUT);
  
  delay(1000);
}

void loop() {
  if(client.available()) {
    char c = client.read();
    
    if(matchSuccess(c)) {
      setSuccess(true);
    }else if(matchFailure(c)) {
      setSuccess(false);
    }
  }
  
  if (!client.connected()) {
    Serial.println();
    Serial.println("Disconnecting");
    client.stop();
    nextSuccess = 0;
    nextFailure = 0;
    delay(1000);
    Serial.println("Connecting...");
  
    if (client.connect()){
      Serial.println("Connected");
      client.println("GET /rssLatest HTTP/1.0");
      client.println();
    }else{
      Serial.println("FAIL");
    }
  }
}
