import 'dart:async';
import 'dart:convert';

import 'package:ble_ota_app/src/core/hardware_info.dart';
import 'package:ble_ota_app/src/core/softwate_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class NetInfoReader extends StatefulStream<SwInfoState> {
  SwInfoState _state = SwInfoState();

  @override
  SwInfoState get state => _state;

  Future<void> _readSoftware(HardwareInfo hwInfo, String hardwarePath) async {
    try {
      final response = await http.get(Uri.parse(hardwarePath));
      if (response.statusCode != 200) {
        return;
      }

      final body = json.decode(response.body);
      final fullList = body.map<SoftwareInfo>(SoftwareInfo.fromJson).toList();
      final filteredByHwList = fullList.where((SoftwareInfo info) {
        return info.hwName == hwInfo.hwName &&
            (info.hwVer != null ? info.hwVer == hwInfo.hwVer : true) &&
            (info.minHwVer != null ? info.minHwVer! <= hwInfo.hwVer : true) &&
            (info.maxHwVer != null ? info.maxHwVer! >= hwInfo.hwVer : true);
      }).toList();
      final filteredBySwList = filteredByHwList.where((SoftwareInfo info) {
        return info.name == hwInfo.swName;
      }).toList();

      state.swInfoList = filteredByHwList;
      if (filteredBySwList.isEmpty) {
        return;
      }
      final max = filteredBySwList.reduce((SoftwareInfo a, SoftwareInfo b) {
        return a.ver >= b.ver ? a : b;
      });
      if (max.ver <= hwInfo.swVer) {
        return;
      }
      state.newest = max;
    } catch (_) {}
  }

  void read(HardwareInfo hwInfo) {
    _state = SwInfoState();
    addStateToStream(state);

    () async {
      final data = await rootBundle.loadString("assets/hardwares.json");
      final body = json.decode(data);
      final hardwarePath = body[hwInfo.hwName];

      if (hardwarePath != null) {
        await _readSoftware(hwInfo, hardwarePath);
      }

      state.ready = true;
      addStateToStream(state);
    }.call();
  }
}

class SwInfoState {
  SwInfoState({
    this.swInfoList = const [],
    this.newest,
    this.ready = false,
  });

  List<SoftwareInfo> swInfoList;
  SoftwareInfo? newest;
  bool ready;
}
