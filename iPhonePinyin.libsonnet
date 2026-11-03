local buttons = import '../Buttons/Layout18.libsonnet';
local commonButtons = import '../Buttons/Common.libsonnet';
local mk = import '../Buttons/_mkButton.libsonnet';
local toolbarParams = import '../Buttons/Toolbar.libsonnet';
local settings = import '../Settings.libsonnet';
local basicStyle = import 'BasicStyle.libsonnet';
local preedit = import 'Preedit.libsonnet';
local toolbar = import 'Toolbar.libsonnet';
local utils = import 'Utils.libsonnet';

// 【分体键盘】中缝键的按键名
// 为什么要加：分体后键盘从中间裂开，这条缝在元书里是靠一颗「平时零宽、
//   分体态撑开」的按键实现的（官方文档称「中缝写法」）。它不是真按键，只占位置。
// 在这里统一定义，是为了让下面三行都能引用同一个名字，改缝宽也只需改一处。
local splitGapName = 'splitGap';

local doublePinyinHints = (import '../Constants/DoublePinyinHints.libsonnet').getHints(settings.doublePinyinHints);
local shiftParams =
  if doublePinyinHints != null && !std.objectHas(commonButtons.shiftButton.params, 'swipeUp') then
    commonButtons.shiftButton.params + {
      swipeUp: { action: { shortcut: mk.doublePinyinHintsShortcut }, text: '助记' },
    }
  else commonButtons.shiftButton.params;

local keyboardLayout = {
  keyboardLayout: [
    {
      HStack: {
        subviews: [
          { Cell: buttons.qButton.name },
          { Cell: buttons.wButton.name },
          { Cell: buttons.rButton.name },
          // 【分体键盘】中缝：第 1 行从这里裂开，左侧 q w r，右侧 y u i p（3|4）
          // 这样 Y 归到右侧，与第 3 行的缝位置对齐。
          { Cell: splitGapName },
          { Cell: buttons.yButton.name },
          { Cell: buttons.uButton.name },
          { Cell: buttons.iButton.name },
          { Cell: buttons.pButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: buttons.aButton.name },
          { Cell: buttons.sButton.name },
          { Cell: buttons.fButton.name },
          // 【分体键盘】中缝：第 2 行从这里裂开，左右各 3.5 份（a、l 各占 1.5），缝正好居中
          { Cell: splitGapName },
          { Cell: buttons.hButton.name },
          { Cell: buttons.jButton.name },
          { Cell: buttons.lButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: commonButtons.shiftButton.name },
          { Cell: buttons.zButton.name },
          { Cell: buttons.xButton.name },
          // 【分体键盘】左侧的 V：与右侧 vButton 功能完全相同（共用 Layout18 里的 vSpec），
          //   只是按键名叫 vButton2。分体后左手按这颗，右手按右边那颗。
          // 宽度在 getAlphabeticButtonSize 里定义：常态 0（完全不出现），
          //   分体时才撑到 9.375%，所以平时第三行跟原来一模一样。
          { Cell: buttons.vButton2.name },
          // 【分体键盘】中缝：第 3 行从这里裂开，左侧 ⇧ z x V，右侧 v b m ⌫
          { Cell: splitGapName },
          { Cell: buttons.vButton.name },
          { Cell: buttons.bButton.name },
          { Cell: buttons.mButton.name },
          { Cell: commonButtons.backspaceButton.name },
        ],
      },
    },
    {
      // 【分体键盘】底行不做任何改动：不裂开，宽度全部保持默认
      //   （123 20% / 逗号 12% / 空格 34% / 中英 12% / 回车 22%）
      // 为什么不动：底行裂开会额外增加按键，且空格被压缩后手感变差；
      //   保持整行横跨，分体时只有上面三行左右分开，底行照常用。
      HStack: {
        subviews: [
          { Cell: commonButtons.numericButton.name },
          { Cell: commonButtons.commaButton.name },
          { Cell: commonButtons.spaceButton.name },
          { Cell: commonButtons.alphabeticButton.name },
          { Cell: commonButtons.enterButton.name },
        ],
      },
    },
  ],
};

local getAlphabeticButtonSize(name) =
  local extra = {
    [buttons.aButton.name]: {
      size:
        { width: '1.5/7' },
      bounds:
        { width: '1/1.5', alignment: 'right' },
      // 【分体键盘】a 键：1.5/7 → 1.125/7
      // 为什么只改 a 和 l：第 2 行里只有这两颗显式写了宽度（各 1.5 份），
      //   s f h j 都没写宽度，按元书规则会自动分掉剩余空间，不用管也不会算错。
      // 数值怎么来的：分体后中缝拿走 25%，这一行只剩 75% 可分，
      //   所以 1.5 × 0.75 = 1.125，a 与 l 的粗细比例完全不变。
      split: { size: { width: '1.125/7' } },
    },
    [buttons.lButton.name]: {
      size:
        { width: '1.5/7' },
      bounds:
        { width: '1/1.5', alignment: 'left' },
      // 【分体键盘】l 键：1.5/7 → 1.125/7（理由同上）
      split: { size: { width: '1.125/7' } },
    },
    [buttons.vButton2.name]: {
      // 【分体键盘】左侧的 V：常态完全隐藏，只在分体时出现
      // 为什么常态是 0：这颗键只在分体时才有意义（左手够不到右侧的 V）。
      //   平时不出现，第三行就还是原来的 7 颗，宽度、手感一点不变。
      size: { width: 0 },
      // 分体时：75% ÷ 8 = 9.375%，与第三行其他 7 颗完全等宽。
      //   校验：缝 25% + 8 颗 × 9.375% = 25% + 75% = 100%，正好闭合。
      split: { size: { width: { percentage: 0.09375 } } },
    },
  };
  (
  if std.objectHas(extra, name) then
    extra[name]
  else
    {}
  );

local newKeyLayout(isDark=false, isPortrait=true) =
  {
    keyboardHeight: if isPortrait then commonButtons.keyboardHeight.portrait else commonButtons.keyboardHeight.landscape,
    keyboardStyle: utils.newBackgroundStyle(style=basicStyle.keyboardBackgroundStyleName),
  }
  + keyboardLayout

  // 【分体键盘】中缝键本体
  // 为什么要手写裸节点、不走 basicStyle 的构造函数：中缝键没有图标、没有文字、
  //   也没有 action，一旦走 newAlphabeticButton / newSystemButton，就会在
  //   BasicStyle 的 newStyleByPriority 里触发 assert false，整个皮肤编译失败。
  //   同时按官方要求「中缝键不应绑定 action」，点到缝隙时不会有任何反应。
  // 宽度：常态 0（完全隐形，不影响现在的手感）；分体态 25%（你要的缝宽）。
  // 已知风险：若真机上缝隙处出现白块，说明系统给它套了默认键背景，
  //   需要在这里补一句透明背景，到时候告诉我，我给你具体写法。
  + {
    [splitGapName]: {
      size: { width: 0 },
      split: { size: { width: { percentage: 0.25 } } },
    },
  }

  // letter Buttons
  // 注：vButton2 已加入 Layout18.libsonnet 的 letterButtons 数组，
  //   所以这里会自动为它生成样式节点，无需额外处理。
  + std.foldl(function(acc, button)
      acc +
      basicStyle.newAlphabeticButton(
        button.name,
        isDark,
        getAlphabeticButtonSize(button.name) + button.params + basicStyle.hintStyleSize + basicStyle.textCenterWhenShowSwipeText +
        {
          [if settings.uppercaseForChinese then 'text']: std.asciiUpper(button.params.text)
        }),
      buttons.letterButtons,
      {})

  // Third Row
  + basicStyle.newSystemButton(
    commonButtons.shiftButton.name,
    isDark,
    shiftParams
  )

  + basicStyle.newSystemButton(
    commonButtons.backspaceButton.name,
    isDark,
    commonButtons.backspaceButton.params,
  )

    // Fourth Row
  // 【分体键盘】底行不裂开（没有中缝），只调整 123 键在分体态下的宽度
  + basicStyle.newSystemButton(
    commonButtons.numericButton.name,
    isDark,
    { size: { width: { percentage: 0.2 } } }
    // 【分体键盘】123 键：常态 20% 不变；分体态 20% → 12%，与逗号键等宽
    // 为什么只在 split 块里改：常态（大键盘未分体）与浮动键盘的尺寸完全不受影响，
    //   浮动键盘读的是 iPhonePinyinFloating.libsonnet，那份不含任何 split，自然不变。
    // 多出来的 8% 去哪了：空格键没有显式宽度，按元书规则自动吃掉行内剩余空间，
    //   所以分体后 12+12+12+22 = 58%，空格自动从 34% 涨到 42%，无需另写一行。
    + { split: { size: { width: { percentage: 0.12 } } } }
    + commonButtons.numericButton.params
  )

  + basicStyle.newAlphabeticButton(
    commonButtons.commaButton.name,
    isDark,
    { size: { width: { percentage: 0.12 } } }
    + commonButtons.commaButton.params + basicStyle.hintStyleSize,
    swipeTextFollowSetting=false,
  )
  + basicStyle.newAlphabeticButton(
    commonButtons.spaceButton.name,
    isDark,
    basicStyle.newSpaceButtonForegroundStyle(commonButtons.spaceButton.params, '$rimeSchemaName', isDark),
    needHint=false,
  )
  + basicStyle.newSystemButton(
    commonButtons.alphabeticButton.name,
    isDark,
    { size: { width: { percentage: 0.12 } } }
    + commonButtons.alphabeticButton.params
  )
  + basicStyle.newColorButton(
    commonButtons.enterButton.name,
    isDark,
    { size: { width: { percentage: 0.22 } } }
    + commonButtons.enterButton.params
  )
;

{
  new(isDark, isPortrait):
    local insets = if isPortrait then commonButtons.backgroundInsets.portrait else commonButtons.backgroundInsets.landscape;

    local extraParams = {
      insets: insets,
    };

    preedit.new(isDark)
    + toolbar.new(isDark, isPortrait)
    + basicStyle.newKeyboardBackgroundStyle(isDark)
    + basicStyle.newAlphabeticButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newSystemButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newColorButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newAlphabeticHintBackgroundStyle(isDark, { cornerRadius: 10 })
    + basicStyle.newLongPressSymbolsBackgroundStyle(isDark, extraParams)
    + basicStyle.newLongPressSymbolsSelectedBackgroundStyle(isDark, extraParams)
    + basicStyle.newButtonAnimation()
    + newKeyLayout(isDark, isPortrait)
    // Notifications
    + basicStyle.rimeSchemaChangedNotification
    + basicStyle.returnKeyTypeChangedNotification,
}
