import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class App extends StatefulWidget {
  const App({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  BluetoothDevice? selectedDevice;
  StreamSubscription<BluetoothDeviceState>? deviceStateSubscription;

  int scan_mode = 2; // scan mode
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    deviceStateSubscription = selectedDevice?.state.listen((state) {
      if (state == BluetoothDeviceState.connected) {
        _handleConnectionSuccess();
      } else if (state == BluetoothDeviceState.disconnected) {
        _handleDisconnection();
      }
      setState(() {});
    });
  }

  void _handleConnectionSuccess() {
    print('Device connected successfully.');
    // 연결이 성공한 경우 처리할 로직 추가
  }

  void _handleDisconnection() {
    print('Device disconnected.');
    // 연결이 해제된 경우 처리할 로직 추가
  }

  @override
  void dispose() {
    deviceStateSubscription?.cancel();
    // deviceStateSubscription = null;
    super.dispose();
  }

  void toggleState() {
    setState(() {
      isScanning = !isScanning;
    });

    if (isScanning) {
      flutterBlue.startScan(timeout: const Duration(seconds: 5));
      scan();
    } else {
      flutterBlue.stopScan();
    }
    setState(() {});
  }

  void scan() async {
    if (isScanning) {
      flutterBlue.scanResults.listen((results) {
        setState(() {
          // scanResultList = results;
          scanResultList = results
              .where((e) => e.device.name == '202316705 KIM DONG WOOK')
              .toList();
        });
      });
    }
  }

  void connect(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        selectedDevice = device;
      });
      _showConnectionSuccessDialog();
    } catch (e) {
      print('Error connecting to device: $e');
      _showConnectionFailureDialog();
    }
  }

  void _showConnectionSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Device connected successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConnectionFailureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to connect to the device.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.id.id);
  }

  Widget deviceName(ScanResult r) {
    String name;
    if (r.device.name.isNotEmpty) {
      name = r.device.name;
    } else if (r.advertisementData.localName.isNotEmpty) {
      name = r.advertisementData.localName;
    } else {
      name = 'N/A';
    }
    return Text(name);
  }

  Widget leading(ScanResult r) {
    return const CircleAvatar(
      backgroundColor: Colors.cyan,
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
    );
  }

  void onTap(ScanResult r) {
    setState(() {
      selectedDevice = r.device;
    });
    connect(r.device);
  }

  void toggleLED(int led) async {
    if (selectedDevice != null) {
      final serviceId = Guid('4fafc201-1fb5-459e-8fcc-c5c9c331914b');
      final characteristicId = Guid('beb5483e-36e1-4688-b7f5-ea07361b26a8');

      final services = await selectedDevice!.discoverServices();
      final service = services.firstWhere((s) => s.uuid == serviceId);
      final characteristics = await service.characteristics;
      final characteristic =
          characteristics.firstWhere((c) => c.uuid == characteristicId);

      try {
        if (led == 1) {
          List<int> value = utf8.encode("1");
          await characteristic.write(value);
        } else if (led == 2) {
          List<int> value = utf8.encode("2");
          await characteristic.write(value);
        } else if (led == 3) {
          List<int> value = utf8.encode("3");
          await characteristic.write(value);
        } else if (led == 4) {
          List<int> value = utf8.encode("4");
          await characteristic.write(value);
        }
      } catch (e) {
        print('Error');
      }
    }
  }

  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => onTap(r),
      leading: leading(r),
      title: deviceName(r),
      subtitle: deviceMacAddress(r),
      trailing: deviceSignal(r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.separated(
          itemCount: scanResultList.length,
          itemBuilder: (context, index) {
            return listItem(scanResultList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleState,
        child: Icon(isScanning ? Icons.stop : Icons.search),
      ),
      bottomNavigationBar: selectedDevice != null
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => toggleLED(1),
                      child: const Text('LED 1'),
                    ),
                    ElevatedButton(
                      onPressed: () => toggleLED(2),
                      child: const Text('LED 2'),
                    ),
                    ElevatedButton(
                      onPressed: () => toggleLED(3),
                      child: const Text('LED 3'),
                    ),
                    ElevatedButton(
                      onPressed: () => toggleLED(4),
                      child: const Text('STOP'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
