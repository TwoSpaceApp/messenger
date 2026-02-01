// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => '로드 중...';

  @override
  String get initializing => '초기화 중...';

  @override
  String get errorGeneric => '오류가 발생했습니다';

  @override
  String get errorInitialization => '초기화 오류';

  @override
  String get errorInitializationFull => '초기화 오류';

  @override
  String get errorNetwork => '네트워크 오류';

  @override
  String get errorAuth => '인증 오류';

  @override
  String get errorInvalidArguments => '잘못된 인수';

  @override
  String get errorInvalidArgumentsProfile => '프로필에 대한 잘못된 인수';

  @override
  String get errorInvalidArgumentsChat => '채팅에 대한 잘못된 인수';

  @override
  String get retry => '다시 시도';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get send => '보내기';

  @override
  String get close => '닫기';
}
