import 'dart:async';
import 'dart:collection';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseReference _databaseRef;
  Map<String, dynamic> fireData = {};
  String end = "9";
  final List<String> items = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String start = "1";
  List<int> currentPath = [];
  late StreamSubscription<DatabaseEvent> _subscription;

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.ref('sensor_data/data');
    _subscription = _databaseRef.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        Map<String, dynamic> newFireData = {};
        data.forEach((key, value) {
          newFireData[key.toString()] = value;
        });
        setState(() {
          fireData = newFireData;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  List<int> _calculatePath() {
    int startNum = int.tryParse(start) ?? 1;
    int endNum = int.tryParse(end) ?? 9;

    // Check if start or end is on fire (Firebase value is false)
    if (fireData["sensor$startNum"] == false ||
        fireData["sensor$endNum"] == false) {
      return [];
    }

    Queue<int> queue = Queue();
    queue.add(startNum);
    Map<int, int?> parent = {startNum: null};
    Set<int> visited = {startNum};

    while (queue.isNotEmpty) {
      int current = queue.removeFirst();
      if (current == endNum) {
        List<int> path = [];
        int? node = endNum;
        while (node != null) {
          path.insert(0, node);
          node = parent[node];
        }
        return path;
      }

      List<int> neighbors = _getNeighbors(current);
      for (int neighbor in neighbors) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          parent[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }
    return [];
  }

  List<int> _getNeighbors(int sensor) {
    List<int> neighbors = [];
    int row = (sensor - 1) ~/ 3;
    int col = (sensor - 1) % 3;

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        int nr = row + dr;
        int nc = col + dc;
        if (nr >= 0 && nr < 3 && nc >= 0 && nc < 3) {
          int neighborSensor = nr * 3 + nc + 1;
          // Check if neighbor is safe (Firebase value is true)
          if (fireData["sensor$neighborSensor"] == true) {
            neighbors.add(neighborSensor);
          }
        }
      }
    }
    return neighbors;
  }

  @override
  Widget build(BuildContext context) {
    currentPath = _calculatePath();

    if (fireData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Fire Protect"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Fire Protect!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              height: 400,
              width: 400,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: 9,
                itemBuilder: (BuildContext context, int index) {
                  final sensorNumber = index + 1;
                  final isOnFire = fireData["sensor$sensorNumber"] == false;
                  final isInPath = currentPath.contains(sensorNumber);
                  return Container(
                    decoration: BoxDecoration(
                      color: isOnFire
                          ? Colors.redAccent
                          : isInPath
                              ? Colors.green
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (int.parse(start) == sensorNumber)
                            const Text(
                              'Start',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (int.parse(end) == sensorNumber)
                            const Text(
                              'End',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (isOnFire)
                            const Icon(
                              Icons.fire_extinguisher,
                              color: Colors.white,
                              size: 40,
                            ),
                          Text(
                            '$sensorNumber',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      "Start Point",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Select Item',
                          style: TextStyle(fontSize: 20),
                        ),
                        items: items
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item,
                                      style: const TextStyle(fontSize: 20)),
                                ))
                            .toList(),
                        value: start,
                        onChanged: (String? value) {
                          setState(() => start = value ?? "1");
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          height: 60,
                          width: 160,
                        ),
                        menuItemStyleData: const MenuItemStyleData(height: 40),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "End Point",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Select Item',
                          style: TextStyle(fontSize: 20),
                        ),
                        items: items
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item,
                                      style: const TextStyle(fontSize: 20)),
                                ))
                            .toList(),
                        value: end,
                        onChanged: (String? value) {
                          setState(() => end = value ?? "9");
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          height: 60,
                          width: 160,
                        ),
                        menuItemStyleData: const MenuItemStyleData(height: 40),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
