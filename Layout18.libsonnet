# =====================================
# 此文件用于自定义键盘按键功能。
# 可根据需要修改下方内容，调整各类按键的行为
# 修改完成后，保存本文件，然后回到皮肤界面，
# 长按皮肤，选择「运行 main.jsonnet」生效。
#
# 包含中文18键布局的按键
#
# 行式 spec 写法（详见 _mkButton.libsonnet 注释）：
#   { chars: 'q',  swipeUp: '#' }            # 字符简写
#   { chars: 'we', swipeUp: '1' }            # 双字符按键，text 默认 'w e'
#   { chars: 'a',  swipeUp: sym('！') }      # 符号简写
#   longPress 条目同样支持字符串 / sym(...) / 完整对象
# =====================================

local mk = import '_mkButton.libsonnet';
local settings = import '../Settings.libsonnet';
local doublePinyinHints = (import '../Constants/DoublePinyinHints.libsonnet').getHints(settings.doublePinyinHints);

# 【分体键盘】V 键的 spec 提取成变量
# 为什么要提取：第三行左侧要再放一颗 V（vButton2），两颗键功能必须完全一致。
#   把 spec 提出来让两颗键共用同一份定义，以后改 V 的上滑 / 下滑 / 长按，
#   两颗自动同步，不用改两处、也不会改漏。
local vSpec = { chars: 'v',  swipeUp: '8',  swipeDown: '*',
    longPress: [
      'V',
      { action: { runScriptSilently: 'MBBB' }, systemImageName: 'b.circle.fill', text: '蓝粗' },
      { action: { runScriptSilently: 'MRB' }, systemImageName: 'r.circle.fill', text: '红粗' },
      { action: { runScriptSilently: 'MGB' }, systemImageName: 'g.circle.fill', text: '绿粗' },
      { action: { runScriptSilently: 'MPB' }, systemImageName: 'p.circle.fill', text: '粉粗' },
    ] };

# 键位顺序即为键盘上的显示顺序
#
# swipeUp / swipeDown 排布原则（参考 PC 物理键盘）：
#   - 数字键：上滑出数字、下滑出对应 shift 符号（w 1!、r 2@ ...）。
#   - 整键搬运：常见符号键的 normal/shift 对（q `~、i -_、p =+、j ;:、l '"）。
#   - 自动补全的右半边（) ] } > " '）不占用滑动位，由输入法补齐。
#   - z 安排开括号 { / [（{ 在中文模式下还会被翻译成「）。
#   - u 走斜杠对 / \；a 留 < / |（< 兼顾《》），m 下滑给到最常用的 ?。
local specs = [
  # 第一行
  { chars: 'q',  swipeUp: '`',  swipeDown: '~', longPress: ['Q'] },
  { chars: 'we', swipeUp: '1',  swipeDown: '!', longPress: ['e', 'W', 'E'] },
  { chars: 'rt', swipeUp: '2',  swipeDown: '@', longPress: ['t', 'R', 'T'] },
  { chars: 'y', swipeUp: '3', swipeDown: '#', longPress: ['Y', { text: 'F1', action: { sendKeys: 'F1' } }] },

  { chars: 'u',  swipeUp: '/',  swipeDown: '\\',
    longPress: [
      'U',
      { action: { shortcut: '#toggleCommandView' }, systemImageName: 'command', text: '命令' },
      { action: { shortcut: '#showScriptView' }, systemImageName: 'terminal', text: '脚本' },
      { action: { shortcut: '#RimeSwitcher' }, systemImageName: 'switch.2', text: '开关' },
      { action: { shortcut: '#toggleSplitState' }, systemImageName: 'rectangle.split.2x1', text: '分体' },
    ] },
  { chars: 'io', swipeUp: '-',  swipeDown: '_', longPress: ['o', 'I', 'O'] },
  { chars: 'p',  swipeUp: '=',  swipeDown: '+', longPress: ['P'] },

  # 第二行
  { chars: 'a',  swipeUp: '<',  swipeDown: '|',
    longPress: [
      'A',
      { action: { shortcut: '#左手模式' }, systemImageName: 'keyboard.onehanded.left' },
      { action: 'tab', systemImageName: 'arrow.right.to.line', text: 'Tab' },
      '>',
    ] },
  { chars: 'sd', swipeUp: '4',  swipeDown: '$', longPress: ['d', 'S', 'D'] },
  { chars: 'fg', swipeUp: '5',  swipeDown: '%', longPress: ['g', 'F', 'G'] },
  { chars: 'h',  swipeUp: '6',  swipeDown: '^',
    longPress: [
      'H',
      { action: { runScriptSilently: 'MHL' }, systemImageName: 'highlighter', text: '黄底' },
      { action: { runScriptSilently: 'MBD' }, systemImageName: 'bold', text: '加粗' },
      { action: { runScriptSilently: 'MGL' }, systemImageName: 'g.square.fill', text: '淡绿' },
    ] },
  { chars: 'jk', swipeUp: ';',  swipeDown: ':', longPress: ['k', 'J', 'K'] },
  { chars: 'l',  swipeUp: "'",  swipeDown: '"',
    longPress: [
      'L',
      { action: { ai: '润色' }, systemImageName: 'wand.and.stars', text: '润色' },
      { action: { shortcut: '#右手模式' }, systemImageName: 'keyboard.onehanded.right' },
    ] },

  # 第三行
  { chars: 'z',  swipeUp: '{',  swipeDown: '[', longPress: ['Z', '}', ']'] },
  { chars: 'xc', swipeUp: '7',  swipeDown: '&', longPress: ['c', 'X', 'C'] },
  # 【分体键盘】V 键改为引用 vSpec（内容与原文件完全一致，只是换了个写法）
  vSpec,
  { chars: 'bn', swipeUp: '9',  swipeDown: '(', longPress: ['n', 'B', 'N' ] },
  { chars: 'm',  swipeUp: '0',  swipeDown: '?',
    longPress: [
      'M',
      { action: { shortcut: '#showPhraseView' }, systemImageName: 'heart', text: '常用语' },
      { action: { shortcut: '#showPasteboardView' }, systemImageName: 'doc.on.clipboard', text: '剪贴板' },
    ] },
];

# 【分体键盘】第二颗 V（vButton2）
# 为什么需要：分体后键盘从中间裂开，V 在右侧，左手够不到。
#   在第三行中缝左侧补一颗，左右各一个 V。
# 为什么必须换个名字：mk.name() 是按 chars[0] 推导的（'v' -> 'vButton'），
#   两颗键若同名，样式节点和通知会互相覆盖。这里手动把 name 改成 'vButton2'，
#   成为独立按键；功能则通过共用同一个 vSpec 保证与原 V 完全一致
#   （上滑 8、下滑 *、长按的蓝粗/红粗/绿粗/粉粗全都一样）。
local vButton2 = mk.button(vSpec, doublePinyinHints) { name: 'vButton2' };

{
  [mk.name(s)]: mk.button(s, doublePinyinHints) for s in specs
} + {
  vButton2: vButton2,
} + {
  # 【分体键盘】letterButtons 必须包含 vButton2
  # 为什么：iPhonePinyin.libsonnet 用这个数组遍历生成按键的样式节点。
  #   只放进布局、不进这个数组的话，vButton2 没有对应样式，会显示异常或报错。
  letterButtons: [mk.button(s, doublePinyinHints) for s in specs] + [vButton2],
}
