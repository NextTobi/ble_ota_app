enum UploadError {
  unknown,
  generalDeviceError,
  incorrectPackageFormat,
  incorrectFirmwareSize,
  incorrectChecksum,
  internalSrorageError,
  noDeviceResponse,
  unexpectedDeviceResponse,
  unexpectedNetworkResponse,
  generalNetworkError,
}

enum InfoError {
  unknown,
  incorrectJsonFileFormat,
  unexpectedNetworkResponse,
  generalNetworkError,
}