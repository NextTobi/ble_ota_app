import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble_ota/ble_ota_upload_error.dart';
import 'package:ble_ota_app/src/ble/ble_uploader.dart';

class Uploader extends StatefulStream<UploadState> {
  Uploader({required deviceId})
      : _bleUploader = BleUploader(deviceId: deviceId) {
    _bleUploader.stateStream.listen(_onBleUploadStateChanged);
  }

  final BleUploader _bleUploader;
  UploadState _state = UploadState();

  @override
  UploadState get state => _state;

  void _onBleUploadStateChanged(BleUploadState bleUploadState) {
    if (bleUploadState.status == BleUploadStatus.success) {
      state.status = UploadStatus.success;
    } else if (bleUploadState.status == BleUploadStatus.error) {
      state.status = UploadStatus.error;
      state.error = bleUploadState.error;
      state.errorCode = bleUploadState.errorCode;
    }
    state.progress = bleUploadState.progress;
    addStateToStream(state);
  }

  Future<void> uploadLocalFile(String localPath) async {
    _state = UploadState(status: UploadStatus.upload);
    addStateToStream(state);

    File file = File(localPath);
    var data = await file.readAsBytes();
    _bleUploader.upload(data);
  }

  Future<void> uploadHttpFile(String url) async {
    try {
      _state = UploadState(status: UploadStatus.upload);
      addStateToStream(state);

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        _state.status = UploadStatus.error;
        _state.error = BleOtaUploadError.unexpectedNetworkResponce;
        _state.errorCode = response.statusCode;
        addStateToStream(state);
        return;
      }

      _bleUploader.upload(response.bodyBytes);
    } catch (_) {
      _state.status = UploadStatus.error;
      _state.error = BleOtaUploadError.generalNetworkError;
      addStateToStream(state);
    }
  }
}

class UploadState {
  UploadState({
    this.status = UploadStatus.idle,
    this.progress = 0.0,
    this.error = BleOtaUploadError.unknown,
    this.errorCode = 0,
  });

  UploadStatus status;
  double progress;
  BleOtaUploadError error;
  int errorCode;
}

enum UploadStatus {
  idle,
  upload,
  success,
  error,
}
