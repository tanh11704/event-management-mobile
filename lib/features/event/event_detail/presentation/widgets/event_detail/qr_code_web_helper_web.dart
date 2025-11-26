import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';

Future<String?> decodeQrFromBytesWeb(Uint8List bytes) async {
  try {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final img = html.ImageElement();
    final completer = Completer<String?>();

    img.onLoad.listen((_) {
      try {
        final canvas = html.CanvasElement(width: img.width, height: img.height);
        final ctx = canvas.context2D;
        ctx.drawImage(img, 0, 0);

        // Lấy ImageData từ canvas
        final imageData = ctx.getImageData(0, 0, canvas.width!, canvas.height!);

        final qrCode = _callJsQRWithImageData(imageData);

        html.Url.revokeObjectUrl(url);
        completer.complete(qrCode);
      } catch (e) {
        html.Url.revokeObjectUrl(url);
        completer.complete(null);
      }
    });

    img.onError.listen((_) {
      html.Url.revokeObjectUrl(url);
      completer.complete(null);
    });

    img.src = url;

    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        html.Url.revokeObjectUrl(url);
        return null;
      },
    );
  } catch (e) {
    return null;
  }
}

String? _callJsQRWithImageData(html.ImageData imageData) {
  try {
    final jsQRFunction = js.context['jsQR'];

    if (jsQRFunction == null) {
      return null;
    }

    try {
      final result = jsQRFunction.apply([imageData]);
      if (result != null && result != js.context['undefined']) {
        final dataProperty = result['data'];
        if (dataProperty != null && dataProperty != js.context['undefined']) {
          final qrText = dataProperty.toString();
          return qrText;
        }
      }
    } catch (e1) {
      try {
        final result = jsQRFunction.apply([
          imageData.data,
          imageData.width,
          imageData.height,
        ]);
        if (result != null && result != js.context['undefined']) {
          final dataProperty = result['data'];
          if (dataProperty != null && dataProperty != js.context['undefined']) {
            var qrText = dataProperty.toString();

            qrText = qrText.trim();

            if (qrText.contains(' ')) {
              final parts = qrText.split(' ');
              qrText = parts.first.trim();
            }

            qrText = qrText
                .replaceAll('\n', '')
                .replaceAll('\r', '')
                .replaceAll('\t', '')
                .trim();

            return qrText;
          }
        }
      } catch (e2) {
        // Method 2 failed, continue
      }
    }

    return null;
  } catch (e) {
    return null;
  }
}
