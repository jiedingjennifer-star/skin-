#======================================
# 此文件用于微调皮肤设置。
# 可根据需要修改下方内容，调整皮肤的相关参数。
# 修改完成后，保存本文件，然后回到皮肤界面，
# 长按皮肤，选择「运行 main.jsonnet」生效。
# =====================================
# 本皮肤改动记录（空山素影-calf / 中文18键）jjd
# 最后更新：2026-11-01
# 状态图例：✅ 已验证生效 / ⚠️ 未验证 / ❌ 未生效待修
# =====================================
#
# 【Settings.libsonnet】本文件
#   ✅ shiftButtonParams 新增：
#      swipeUp   → #行首（arrow.left.to.line）
#      swipeDown → #行尾（arrow.right.to.line）
#      副作用：助记（双拼提示）因手势被占用而自动失效，符合预期
#
# 【Buttons/Common.libsonnet】
#   ✅ alphabeticButton（第四排 space 右侧那个键）新增：
#      swipeUp  → nextKeyboard 地球，切换输入法
#      longPress → #paste 粘贴
#      注意：原本改在 asciiModeButton 上无效——该键未被 18 键布局引用
#
# 【Buttons/Layout18.libsonnet】
#   ✅ u 键 longPress：U、命令面板（#toggleCommandView）、脚本、万象面板
#      ⚠️ 后两项 shortcut 名为推测，未核实
#   ✅ m 键 longPress：M、常用语（#showPhraseView）、剪贴板（#showPasteboardView）
#   ⚠️ l 键 longPress：L、AI 润色（action: { ai: '润色' }）、右手模式
#      → 需在 App 命令面板 → AI 指令 中新建名为「润色」的指令
#   ❌ h 键 longPress：H、黄底 \hl、纯加粗 \bd、淡绿 \gl
#   ❌ v 键 longPress：V、蓝粗 \bbb、红粗 \rb、绿粗 \gb、粉粗 \pb
#      → 当前用 character 会直接上屏、绕开 Rime；待改 sendKeys 验证
#
# 【万象方案 custom.yaml】
#   ✅ 新增纯加粗配对（加完需重新部署方案）：
#      paired_symbols/symkey/bd: '<span style="font-weight:bold">|</span>'
#   原有：rb 红粗 / gb 绿粗 / bbb 蓝粗 / pb 粉粗 / hl 黄底 / gl 淡绿底
#
# 【未改动】
#   - 键盘布局顺序、Toolbar 相关 Settings 配置
#   - u 键 swipeUp '/'、swipeDown '\'（symkey 引导键，保留）
# =====================================
// 音频在mainjsonnet
#======================================
{
  # 主键盘布局选择，可选值如下：
  # 26 : 常规26键布局
  # 26b: 左移26键布局(zxcvbnm行左移半格)
  # 9  : 拼音9键布局
  # 14 : 14键布局（双键布局）
  # 17 : 17键布局
  # 18 : 18键布局
  # bopomofo : 注音佈局
  # sigma : 西戈拼音布局
  keyboardLayout: '18',


  # 双拼助记词方案
  # 启用后：在 14/18/26 键的中文拼音键盘上：
  #   - shift 键的 swipeUp 用于触发显示助记（若用户已自行配置 shiftButtonParams.swipeUp，则尊重用户设置）
  #   - 触发后字母键的 swipeUp/swipeDown 显示对应韵母提示，按一次按键即恢复
  # 可选值：
  #   'none'  : 关闭
  #   'flypy' : 小鹤双拼
  doublePinyinHints: 'flypy',


  # 数字键盘布局选择，可选值如下：
  # 9 : 九宫格布局
  # row : 数字显示在一行
  # hex : 十六进制布局
  numericLayout: 'hex',


  # 输入时空格键上的内容，支持固定内容和变量
  # 注意：bopomofo 佈局下此項不生效，因為空格鍵打字中用於選聲調（一聲）
  # 变量可选如下：
  # $rimePreedit：Rime 预编辑文本
  # $rimeCandidate：Rime 首个候选字
  # $rimeCandidateComment: Rime 首个候选字的 comment 信息
  spaceButtonComposingText: '选定',


  # 是否为 iPad 设备，目前仅用于调整高度
  # true 是 iPad，false 是 iPhone
  iPad: false,


  # 空格键方案名称显示位置
  # x, y 取值范围为 [0, 1]
  # x 值越小越靠左，y 值越小越靠上
  # 特殊值 null 表示不显示方案名称
  spaceButtonSchemaNameCenter:
    # { x: 0.2, y: 0.7 }, # 左下角
    # { x: 0.5, y: 0.5 }, # 中间
    { x: 0.5, y: 0.7 },   # 居中靠下
    # null,               # 不显示


  # 上下滑动提示文字显示位置
  # hide      🙈不显示
  # topLeft   ↖️左上角
  # top       ⬆️正上方
  # topRight  ↗️右上角
  # bottomLeft   ↙️左下角
  # bottom       ⬇️正下方
  # bottomRight  ↘️右下角
  swipeUpTextCenter: 'top',
  swipeDownTextCenter: 'bottom',


  # toolbar 按钮配置
  # 注意第一个和最后一个按键是固定的，不可配置
  # 按钮代号列表如下：
  # 【元书相关】
  # 1-脚本  2-常用语  3-剪贴板
  # 4-皮肤  5-文件管理器  6-方案切换
  # 7-数字键盘  8-符号键盘  9-表情键盘
  # 10-查看性能  11-左手模式  12-右手模式
  # 【Rime 相关】
  # 13-Rime同步  14-Rime部署  15-方案管理
  # 16-快符  17-RimeSwitcher
  # 【皮肤相关】
  # 18-皮肤微调  19-按键功能定义
  # 【文本编辑相关】
  # 20-全选  21-复制  22-剪切
  # 23-粘贴  24-撤销  25-重做
  # 26-左移  27-右移
  #
  # 将上述代号填入下面的数组即可
  toolbarSlideButtons: [ 24, 20, 21, 23, 3, 1, 17 ],

  # 滑动按钮区域占几个按键宽度
  toolbarSlideButtonsMaxCount: {
    portrait: 5,   # 竖屏
    landscape: 8,  # 横屏
  },


  # 同时配了图标和文字的，优先显示图标还是文字
  # true 显示图标，false 显示文字
  preferIcon: true,


  # 主题色
  # 0-无  1-红色  2-绿色  3-橙色  4-蓝色  5-紫色
  accentColor: 1,


  # 中文模式下，字母键是否大写显示
  # 注意：17键布局、注音佈局、西戈码布局下此设置无效
  # true 大写，false 小写
  uppercaseForChinese: true,


  # shiftButton 的功能定义 jjd 上滑下滑是我自己加的
  shiftButtonParams: {
    systemImageName: 'shift',
    action: 'shift',
    swipeUp: { action: { shortcut: '#行首' }, systemImageName: 'arrow.left.to.line', text: '行首' },
    swipeDown: { action: { shortcut: '#行尾' }, systemImageName: 'arrow.right.to.line', text: '行尾' },


    uppercased: { systemImageName: 'shift.fill', },
    capsLocked: { systemImageName: 'capslock.fill', },

    # 「分词」仅在全拼模式下有意义；启用双拼助记词时（即 doublePinyinHints != 'none'），
    # 双拼每个音都是固定两个字母，不需要分词，故不启用此键。
    [if $.doublePinyinHints == 'none' then 'whenPreeditChanged']: {
      action: { character: "'" },
      systemImageName: 'square.and.line.vertical.and.square',
      text: '分词',

      # action: 'tab',
      # systemImageName: 'arrow.right.to.line',
      # text: 'Tab',
    },
  },


  # Rime 方案中的快符
  quickAction:
    { character: ';' },
    # { character: '/' },

}
