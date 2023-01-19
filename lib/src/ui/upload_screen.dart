import 'package:arduino_ble_ota_app/src/ble/ble_info_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  UploadScreen({required this.deviceId, required this.deviceName, Key? key})
      : bleInfoReader = BleInfoReader(deviceId: deviceId),
        super(key: key);

  final String deviceId;
  final String deviceName;
  final BleInfoReader bleInfoReader;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  void _onInfoReady(Info info) {
    setState(() {});
  }

  @override
  void initState() {
    widget.bleInfoReader.infoStream.listen(_onInfoReady);
    widget.bleInfoReader.update();
    super.initState();
  }

  String _buildVerStr(Version ver) => "${ver.major}.${ver.minor}.${ver.patch}";
  String _buildHwStr(Info info) =>
      "${info.hwName} v${_buildVerStr(info.hwVer)}";
  String _buildSwStr(Info info) =>
      "${info.swName} v${_buildVerStr(info.swVer)}";

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      // File file = File(result.files.single.path);
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 35.0, 25.0, 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(widget.deviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Hardware: ${_buildHwStr(widget.bleInfoReader.info)}"),
              Text("Software: ${_buildSwStr(widget.bleInfoReader.info)}"),
              ElevatedButton(
                  onPressed: _pickFile, child: const Text('Upload from file'))
            ],
          ),
        ),
      );
}
