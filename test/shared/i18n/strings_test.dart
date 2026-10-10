import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/shared/i18n/strings.g.dart';

void main() {
  group('generated translations', () {
    test('use Chinese as the base locale', () {
      expect(AppLocaleUtils.instance.baseLocale, AppLocale.zh);
      expect(t.appTitle, '待办事项');
    });

    test('build parameterised copy from their arguments', () {
      expect(t.todoFailures.contentTooLong(maxLength: 200), '待办内容不能超过 200 个字符');
      expect(
        t.todoList.emptyHint(action: t.todoList.create),
        '点击右下角“新建”添加第一条待办',
      );
    });

    test('declare only locales Flutter can localise', () {
      for (final locale in AppLocale.values) {
        expect(kMaterialSupportedLanguages, contains(locale.languageCode));
      }
    });
  });
}
