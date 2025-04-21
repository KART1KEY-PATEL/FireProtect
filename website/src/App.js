import './App.css';
import Grid from './components/Grid';
import { useState, useEffect } from 'react';

function App() {
  // Initial sensor values (default to all "safe" with 1)
  const [vals, setVals] = useState({
    "Val2": 1,
    "Val3": 1,
    "Val4": 1,
    "Val5": 1,
    "Val6": 1,
    "Val7": 1,
    "Val8": 1,
    "Val9": 1,
    "Val10": 1,
  });
  const [path, setPath] = useState(Array(9).fill("normal"));

  useEffect(() => {
    // Connect to WebSocket server
    const ws = new WebSocket("ws://localhost:8080");

    ws.onopen = () => {
      console.log("Connected to WebSocket server");
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data); // Parse the JSON data
        console.log("Sensor Data Received:", data);
        setVals(data); // Update the sensor values
        getPath(data); // Update the grid based on the new data
      } catch (err) {
        console.error("Error parsing WebSocket data:", err.message);
      }
    };

    ws.onclose = () => {
      console.log("WebSocket connection closed");
    };

    return () => {
      ws.close(); // Cleanup WebSocket connection on component unmount
    };
  }, []);

  function getPath(sensorData) {
    console.log("Recomputing path...");
    const graph = [
      [0, 1, 0, 1, 0, 0, 0, 0, 0],
      [1, 0, 1, 0, 1, 0, 0, 0, 0],
      [0, 1, 0, 0, 0, 1, 0, 0, 0],
      [1, 0, 0, 0, 1, 0, 1, 0, 0],
      [0, 1, 0, 1, 0, 1, 0, 1, 0],
      [0, 0, 1, 0, 1, 0, 0, 0, 1],
      [0, 0, 0, 1, 0, 0, 0, 1, 0],
      [0, 0, 0, 0, 1, 0, 1, 0, 1],
      [0, 0, 0, 0, 0, 1, 0, 1, 0],
    ];

    const selectElement = document.querySelector('#SourceForm');
    const src = parseInt(selectElement.value);

    const destElement = document.querySelector('#DestForm');
    const dest = parseInt(destElement.value);

    const temp = Array(9).fill("normal");
    let ctr = 0;

    for (const [, value] of Object.entries(sensorData)) {
      if (value === 0 && ctr !== src) {
        temp[ctr] = "fire";
        for (let i = 0; i < 9; i++) graph[i][ctr] = 0;
      }
      ctr++;
    }

    const dist = Array(9).fill(Number.MAX_VALUE);
    const path = Array(9).fill(-1);
    dist[src] = 0;
    path[src] = src;

    for (let i = 0; i < 8; i++) {
      for (let j = 0; j < 9; j++) {
        if (dist[j] !== Number.MAX_VALUE) {
          for (let k = 0; k < 9; k++) {
            if (graph[j][k] === 1 && dist[j] + 1 < dist[k]) {
              dist[k] = dist[j] + 1;
              path[k] = j;
            }
          }
        }
      }
    }

    ctr = dest;
    const path_to_dest = [dest];
    while (ctr !== src) {
      if (path[ctr] === -1) {
        console.log("Path not possible");
        break;
      }
      path_to_dest.push(path[ctr]);
      ctr = path[ctr];
    }

    if (ctr === src) {
      for (let i = 0; i < path_to_dest.length; i++) {
        temp[path_to_dest[i]] = "path";
      }
    } else {
      for (let i = 0; i < 9; i++) {
        temp[i] = "fire";
      }
    }
    setPath(temp);
    console.log("Updated path state:", temp);
  }

  return (
    <>
      <div className="Background">
        <div className="Header"> Smart Fire Evacuation System</div>
        <div className="Items">
          <Grid path={path} />
          <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-around', alignItems: 'flex-start' }}>
            <div className="DropDown">
              Source
              <select className="form-select" id="SourceForm" aria-label="Default select example" style={{ margin: "5px", marginLeft: "0px" }}>
                <option value="0">1</option>
                <option value="1">2</option>
                <option value="2">3</option>
                <option value="3">4</option>
                <option value="4">5</option>
                <option value="5">6</option>
                <option value="6">7</option>
                <option value="7">8</option>
                <option value="8">9</option>
              </select>
              Destination
              <select className="form-select" id="DestForm" aria-label="Default select example" defaultValue={"8"} style={{ margin: "5px", marginLeft: "0px" }}>
                <option value="0">1</option>
                <option value="1">2</option>
                <option value="2">3</option>
                <option value="3">4</option>
                <option value="4">5</option>
                <option value="5">6</option>
                <option value="6">7</option>
                <option value="7">8</option>
                <option value="8">9</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default App;
