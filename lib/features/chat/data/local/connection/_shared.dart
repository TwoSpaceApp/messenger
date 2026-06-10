// Conditional export that selects the right implementation based on platform
export '_native.dart'
    if (dart.library.html) '_web.dart'
    show openDatabase;
