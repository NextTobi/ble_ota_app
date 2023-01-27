import 'package:ble_ota_app/src/core/hardware_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/core/version.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';

class BleInfoReader extends StatefulStream<HwInfoState> {
  BleInfoReader({required String deviceId})
      : _characteristicHwName =
            _crateCharacteristic(characteristicUuidHwName, deviceId),
        _characteristicHwVer =
            _crateCharacteristic(characteristicUuidHwVer, deviceId),
        _characteristicSwName =
            _crateCharacteristic(characteristicUuidSwName, deviceId),
        _characteristicSwVer =
            _crateCharacteristic(characteristicUuidSwVer, deviceId);

  final QualifiedCharacteristic _characteristicHwName;
  final QualifiedCharacteristic _characteristicHwVer;
  final QualifiedCharacteristic _characteristicSwName;
  final QualifiedCharacteristic _characteristicSwVer;
  final HwInfoState _state = HwInfoState();

  @override
  HwInfoState get state => _state;

  void read() {
    state.ready = false;
    addStateToStream(state);

    () async {
      state.hwInfo = HardwareInfo(
        hwName: String.fromCharCodes(
            await ble.readCharacteristic(_characteristicHwName)),
        hwVer: Version.fromList(
            await ble.readCharacteristic(_characteristicHwVer)),
        swName: String.fromCharCodes(
            await ble.readCharacteristic(_characteristicSwName)),
        swVer: Version.fromList(
            await ble.readCharacteristic(_characteristicSwVer)),
      );
      state.ready = true;

      addStateToStream(state);
    }.call();
  }

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
}

class HwInfoState {
  HwInfoState({
    this.hwInfo = const HardwareInfo(),
    this.ready = false,
  });

  String _toString(name, ver) => ready ? "$name v$ver" : "reading..";
  String toHwString() => _toString(hwInfo.hwName, hwInfo.hwVer);
  String toSwString() => _toString(hwInfo.swName, hwInfo.swVer);

  HardwareInfo hwInfo;
  bool ready;
}
