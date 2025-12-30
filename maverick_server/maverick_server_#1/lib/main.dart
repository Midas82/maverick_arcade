import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

void main() {
  runApp(const MaverickServerApp());
}

class MaverickServerApp extends StatefulWidget {
  const MaverickServerApp({super.key});

  @override
  State<MaverickServerApp> createState() => _MaverickServerAppState();
}

class _MaverickServerAppState extends State<MaverickServerApp> {
  String _status = 'Starting Server...';
  String _ipAddress = 'Unknown';

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    final router = Router();

    // Endpoint: /tasks
    router.get('/tasks', (Request request) async {
      try {
        final content = await rootBundle.loadString('assets/global_tasks.json');
        return Response.ok(content, headers: {'content-type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Error loading tasks: $e');
      }
    });

    // Endpoint: /ping
    router.get('/ping', (Request request) => Response.ok('pong'));

    try {
      // Listen on all interfaces
      final server = await shelf_io.serve(
        logRequests().addHandler(router.call), 
        InternetAddress.anyIPv4, 
        8080
      );
      
      // Get IP Address
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      String ip = 'Unknown';
      for (var interface in interfaces) {
        if (interface.name.contains('wlan') || interface.name.contains('eth')) {
          for (var addr in interface.addresses) {
            if (!addr.isLoopback) {
              ip = addr.address;
              break;
            }
          }
        }
      }

      setState(() {
        _status = 'Server Running on port 8080';
        _ipAddress = ip;
      });
    } catch (e) {
      setState(() {
        _status = 'Error starting server: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dns, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'MAVERICK BRAIN',
                style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Text(
                _status,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'IP: $_ipAddress',
                style: const TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
