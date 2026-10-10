///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsZh = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zh,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// zh: '待办事项'
	String get appTitle => '待办事项';

	late final Translations$common$zh common = Translations$common$zh._(_root);
	late final Translations$todoList$zh todoList = Translations$todoList$zh._(_root);
	late final Translations$todoCreate$zh todoCreate = Translations$todoCreate$zh._(_root);
	late final Translations$todoFailures$zh todoFailures = Translations$todoFailures$zh._(_root);
}

// Path: common
class Translations$common$zh {
	Translations$common$zh._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '重试'
	String get retry => '重试';
}

// Path: todoList
class Translations$todoList$zh {
	Translations$todoList$zh._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '待办事项'
	String get title => '待办事项';

	/// zh: '新建'
	String get create => '新建';

	/// zh: '还没有待办事项'
	String get emptyTitle => '还没有待办事项';

	/// zh: '点击右下角“${action: String}”添加第一条待办'
	String emptyHint({required String action}) => '点击右下角“${action}”添加第一条待办';

	/// zh: '已完成'
	String get completed => '已完成';

	/// zh: '未完成'
	String get notCompleted => '未完成';

	/// zh: '标记完成'
	String get completeAction => '标记完成';
}

// Path: todoCreate
class Translations$todoCreate$zh {
	Translations$todoCreate$zh._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '新建待办'
	String get title => '新建待办';

	/// zh: '内容'
	String get contentLabel => '内容';

	/// zh: '请输入待办内容'
	String get contentHint => '请输入待办内容';

	/// zh: '内容不能为空'
	String get contentRequired => '内容不能为空';

	/// zh: '保存'
	String get save => '保存';

	/// zh: '保存中…'
	String get saving => '保存中…';

	/// zh: '待办已创建'
	String get created => '待办已创建';
}

// Path: todoFailures
class Translations$todoFailures$zh {
	Translations$todoFailures$zh._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '待办操作失败，请稍后重试'
	String get unknown => '待办操作失败，请稍后重试';

	/// zh: '待办内容不能为空'
	String get contentEmpty => '待办内容不能为空';

	/// zh: '待办内容不能超过 ${maxLength: int} 个字符'
	String contentTooLong({required int maxLength}) => '待办内容不能超过 ${maxLength} 个字符';

	/// zh: '待办数据异常，请稍后重试'
	String get invalidData => '待办数据异常，请稍后重试';

	/// zh: '待办已完成，请勿重复操作'
	String get alreadyCompleted => '待办已完成，请勿重复操作';

	/// zh: '待办不存在或已被移除'
	String get notFound => '待办不存在或已被移除';

	/// zh: '待办加载失败，请稍后重试'
	String get load => '待办加载失败，请稍后重试';

	/// zh: '待办保存失败，请稍后重试'
	String get save => '待办保存失败，请稍后重试';
}

/// The flat map containing all translations for locale <zh>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appTitle' => '待办事项',
			'common.retry' => '重试',
			'todoList.title' => '待办事项',
			'todoList.create' => '新建',
			'todoList.emptyTitle' => '还没有待办事项',
			'todoList.emptyHint' => ({required String action}) => '点击右下角“${action}”添加第一条待办',
			'todoList.completed' => '已完成',
			'todoList.notCompleted' => '未完成',
			'todoList.completeAction' => '标记完成',
			'todoCreate.title' => '新建待办',
			'todoCreate.contentLabel' => '内容',
			'todoCreate.contentHint' => '请输入待办内容',
			'todoCreate.contentRequired' => '内容不能为空',
			'todoCreate.save' => '保存',
			'todoCreate.saving' => '保存中…',
			'todoCreate.created' => '待办已创建',
			'todoFailures.unknown' => '待办操作失败，请稍后重试',
			'todoFailures.contentEmpty' => '待办内容不能为空',
			'todoFailures.contentTooLong' => ({required int maxLength}) => '待办内容不能超过 ${maxLength} 个字符',
			'todoFailures.invalidData' => '待办数据异常，请稍后重试',
			'todoFailures.alreadyCompleted' => '待办已完成，请勿重复操作',
			'todoFailures.notFound' => '待办不存在或已被移除',
			'todoFailures.load' => '待办加载失败，请稍后重试',
			'todoFailures.save' => '待办保存失败，请稍后重试',
			_ => null,
		};
	}
}
