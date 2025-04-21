const { SerialPort } = require("serialport");
const { ReadlineParser } = require('@serialport/parser-readline');
const WebSocket = require("ws");

const port = new SerialPort({
  path: "/dev/cu.usbserial-567E0504091",
  baudRate: 9600,
});

// Create parser that splits on newlines
const parser = port.pipe(new ReadlineParser({ delimiter: '\n' }));

const wss = new WebSocket.Server({ port: 8080 });
console.log("WebSocket server running at ws://localhost:8080");

parser.on("data", (data) => {
  try {
    // Try to parse the JSON data
    const parsedData = JSON.parse(data);
    console.log("Parsed Data from Arduino:", parsedData);

    // Send parsed data to WebSocket clients
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify(parsedData));
      }
    });
  } catch (err) {
    console.error("Error parsing JSON:", err.message, "Raw data:", data);
  }
});

port.on("error", (err) => {
  console.error("Serial Port Error:", err.message);
});