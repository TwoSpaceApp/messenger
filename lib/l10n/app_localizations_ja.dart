// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => '読み込み中...';

  @override
  String get initializing => '初期化中...';

  @override
  String get errorGeneric => 'エラーが発生しました';

  @override
  String get errorInitialization => '初期化エラー';

  @override
  String get errorInitializationFull => '初期化エラー';

  @override
  String get errorNetwork => 'ネットワークエラー';

  @override
  String get errorAuth => '認証エラー';

  @override
  String get errorInvalidArguments => '無効な引数';

  @override
  String get errorInvalidArgumentsProfile => 'プロファイルの引数が無効です';

  @override
  String get errorInvalidArgumentsChat => 'チャットの引数が無効です';

  @override
  String get retry => '再試行';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get send => '送信';

  @override
  String get close => '閉じる';
}
