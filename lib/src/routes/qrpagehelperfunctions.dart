
import 'package:nearby_connections/nearby_connections.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'qr_encryption.dart';
import '../api/model/user.dart';

class RemoteTap {
  String endpointId = 'temp';

  void startDiscovering({
    required void Function(String status) StatusHandler,
    required User profile,
  }) async {
    await Nearby().stopDiscovery();
    await Nearby().stopAdvertising();
    try{
      if (endpointId != 'temp') {
        await Nearby().disconnectFromEndpoint(endpointId);
      }
    } catch (e) {
    }
    Nearby().startDiscovery(
      "student",
      Strategy.P2P_POINT_TO_POINT,
      onEndpointFound: (id, name, serviceId) {
        endpointId = id;

        Nearby().requestConnection(
          "student",
          id,
          onConnectionInitiated: (id, info) {
            Nearby().acceptConnection(id, onPayLoadRecieved: (endpointId, payload) {
              //payload shouldd not be receieved. but if needed for debugging purposes, use payload.toString(); for debugging
            });
          },
          onConnectionResult: (id, status) {
            if (status == Status.CONNECTED) {
              StatusHandler('Connection Successful');
            } else {
              StatusHandler('Connection Failed : $status');
            }
            if (endpointId != 'temp' && status == Status.CONNECTED) {
              Nearby().sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(QREncryption(profile).Encrypt())));
              print('Sent QR Code to $endpointId');
            }
          },
          onDisconnected: (id) {
            endpointId = 'temp';
            Nearby().stopDiscovery();
          },
        );
      },
      onEndpointLost: (id) {
        endpointId = 'temp';
      },
      serviceId: 'mess-i\'s.secret',
    );
  }

  Future<void> permissionsHandler(BuildContext context) async {
    await Permission.nearbyWifiDevices.request();
    var locationPermission = await Permission.location.status;
    if (locationPermission.isDenied) {
      await Permission.location.request();
    } else if (locationPermission.isPermanentlyDenied) {
      await openAppSettings();
    }
    var locationOn = await Permission.location.serviceStatus.isEnabled;
    if (!locationOn) {
      Location.instance.requestService();
    }
    bool granted = !(await Future.wait([
      Permission.bluetooth.isGranted,
      Permission.bluetoothConnect.isGranted,
      Permission.bluetoothScan.isGranted,
      Permission.bluetoothAdvertise.isGranted,
    ])).any((element) => !element);
    if(!granted) {
      await Permission.bluetooth.request();
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();
      await Permission.bluetoothAdvertise.request();
    }
    bool bluetoothOn = await Permission.bluetooth.serviceStatus.isEnabled;
    if (!bluetoothOn) {
      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: const Text('Bluetooth is disabled'),
          content: const Text('Please enable bluetooth '),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }
}
