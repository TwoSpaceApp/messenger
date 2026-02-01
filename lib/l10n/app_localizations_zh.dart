// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => '正在加载...';

  @override
  String get initializing => '正在初始化...';

  @override
  String get errorGeneric => '发生错误';

  @override
  String get errorInitialization => '初始化错误';

  @override
  String get errorInitializationFull => '初始化错误';

  @override
  String get errorNetwork => '网络错误';

  @override
  String get errorAuth => '认证失败';

  @override
  String get errorInvalidArguments => '无效参数';

  @override
  String get errorInvalidArgumentsProfile => '个人资料的无效参数';

  @override
  String get errorInvalidArgumentsChat => '聊天室的无效参数';

  @override
  String get retry => '重试';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get send => '发送';

  @override
  String get close => '关闭';
}
