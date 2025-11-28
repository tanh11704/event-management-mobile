import 'package:json_annotation/json_annotation.dart';

enum ExportFormat {
  @JsonValue('EXCEL')
  excel,
}

extension ExportFormatExtension on ExportFormat {
  String get value {
    switch (this) {
      case ExportFormat.excel:
        return 'EXCEL';
    }
  }
}
