local iPhonePinyin = import 'Components/iPhonePinyin.libsonnet';
// 【浮动键盘】不分体版布局，内容与 iPhonePinyin 唯一的区别是不含任何 split 配置。
// 为什么要单独一份：iPad 浮动小窗本身很窄，再分体就没法用了。
//   而 split 是编译期写死在按键上的，无法按场景开关，只能准备两份 layout。
//   （元书默认皮肤用的是同一套做法）
local iPhonePinyinFloating = import 'Components/iPhonePinyinFloating.libsonnet';
local temp26KeyLayout = import 'Components/Temp26KeyLayout.libsonnet';
local iPhoneAlphabetic = import 'Components/iPhoneAlphabetic.libsonnet';
local iPhoneNumeric = import 'Components/iPhoneNumeric.libsonnet';
local iPhoneNumericRowEn = import 'Components/iPhoneNumericRowEn.libsonnet';
local panel = import 'Components/Panel.libsonnet';
local settings = import 'Settings.libsonnet';

local nameToComponent = {
  pinyin: iPhonePinyin,
  // 【浮动键盘】新增：只为生成一份「不分体」的 yaml 产物，
  //   它不出现在下面的 config 映射里（pinyin 的 iPad.floating 单独指向它）。
  pinyinFloating: iPhonePinyinFloating,
  alphabetic: iPhoneAlphabetic,
  numeric: iPhoneNumeric,
  panel: panel,
  [if !std.startsWith(settings.keyboardLayout, '26') then 'temp26Key']: temp26KeyLayout,
  [if settings.numericLayout == 'row' then 'numericRowEn']: iPhoneNumericRowEn,
};

local getFileName(componentName, isPortrait) =
  componentName + (if isPortrait then 'Portrait' else 'Landscape');

local config = {
  [name]: {
    iPhone: {
      portrait: getFileName(name, isPortrait=true),
      landscape: getFileName(name, isPortrait=false),
    },
    iPad: {
      portrait: getFileName(name, isPortrait=true),
      landscape: getFileName(name, isPortrait=false),
      floating: getFileName(name, isPortrait=true),
    },
  } for name in std.objectFields(nameToComponent)
}
// 【浮动键盘】覆盖 pinyin 这一项：iPad 浮动小窗改指向不分体那份
// 为什么只改 iPad.floating：iPhone 竖屏/横屏、iPad 竖屏/横屏全部照旧用
//   带分体的 pinyinPortrait / pinyinLandscape，只有浮动小窗走 pinyinFloatingPortrait。
// 若实测发现浮动小窗仍然分体，说明引擎没有读取 iPad.floating 这一项，
//   那就需要换思路（比如向开发者反馈，或把缝宽调小）。
+ {
  pinyin: {
    iPhone: {
      portrait: 'pinyinPortrait',
      landscape: 'pinyinLandscape',
    },
    iPad: {
      portrait: 'pinyinPortrait',
      landscape: 'pinyinLandscape',
      floating: 'pinyinFloatingPortrait',
    },
  },
} + {
  // ===== 按键音配置 =====
  // 音频文件放在皮肤根目录下的 sound 文件夹内：
  //   Skins/空山素影-calf/sound/Input.wav
  //   Skins/空山素影-calf/sound/Delete.wav
  //   Skins/空山素影-calf/sound/System.wav
  // 文件名需与 sound 文件夹内的实际文件名（含扩展名、大小写）完全一致，
  // 对不上则该类型回退到元书系统默认音。
  keySound: {
    input: 'Input.wav',
    delete: 'Delete.wav',
    system: 'System.wav',
  },
};

// std.toString 生成的内容紧凑，生成速度快，但不易阅读，适合发布时使用
// std.manifestYamlDoc 生成的内容格式化良好，易于阅读，但生成速度慢，也更占用内存，适合在电脑上调试时使用
// 如果想让 debug=true，需要在命令行中使用 --tla-code debug=true 参数传入
function(debug=false)
  local toString =
    if debug then
      function(x) std.manifestYamlDoc(x, indent_array_in_object=false, quote_keys=false)
    else
      function(x) std.toString(x);
{
  'config.yaml': std.manifestYamlDoc(config, indent_array_in_object=true, quote_keys=false),
}
// 键盘布局文件: light/dark × portrait/landscape
// 注：pinyinFloating 也在 nameToComponent 里，所以这里会自动多生成
//     light/dark × pinyinFloatingPortrait / pinyinFloatingLandscape 四份产物，无需额外代码。
+ std.foldl(function(acc, x) acc + x, [
  {
    [theme + '/' + getFileName(name, isPortrait=isPortrait) + '.yaml']:
      toString(nameToComponent[name].new(isDark=(theme == 'dark'), isPortrait=isPortrait))
    for name in std.objectFields(nameToComponent)
  }
  for theme in ['light', 'dark']
  for isPortrait in [true, false]
], {})
