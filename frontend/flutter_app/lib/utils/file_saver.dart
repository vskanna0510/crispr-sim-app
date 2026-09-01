// Universal file saver interface with conditional web/native export.

export 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart';
