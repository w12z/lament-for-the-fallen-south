# 基础项目说明

本项目使用 Godot 4.7.2 和 GDScript。当前是可运行的流程骨架：开始页 → 过场 CG → 晚年书房；书房是固定的轮次枢纽，每轮从书房进入回忆，再进入创作，完成后返回书房。具体记忆内容、意象选择、拼贴规则与灵感涌现尚未实现，设计见 `project.md`。

## 打开与运行

1. 用 Godot 4 打开本目录的 `project.godot`。
2. 按 **F6** 可运行当前打开的场景；按 **F5** 可从主场景 `scenes/start.tscn` 开始。
3. 点击“提笔 · 入梦”→“梦醒 · 入书房”→“回望 · 进入记忆”，选择一个意象后点击“携此意象 · 落笔”，最后点击“收卷 · 返回书房”，即可看到轮数增加；“搁笔 · 返回首页”重置轮数并返回开始页。

Windows 本机若命令行别名不可用，可以直接打开 `C:\Users\lpr\Godot\Godot_v4.7.2-stable_win64.exe`，然后导入本目录的 `project.godot`。

## 文件结构

```text
project.godot             Godot 项目设置、主场景和全局状态注册
project.md                游戏设计与 18 天计划
basic.md                  本说明
core.txt                  已有的原文资料；尚未接入游戏
assets/                   字体、图片、音乐和声音（详见 assets/README.md）
scenes/
  start.tscn              开始页：start_background.png 背景、标题与开始按钮
  intro.tscn              过场 CG：留给玩家制作的画面容器和继续按钮
  study.tscn              书房：固定的写作现在与轮次枢纽
  memory.tscn             回忆：每轮记忆场景的占位界面
  writing.tscn            创作：每轮拼贴阶段的占位界面
scripts/
  game_state.gd           自动加载的 GameState，当前只记录轮数
  start.gd                开始页到过场的切换与轮数重置
  intro.gd                过场到书房的切换
  study.gd                书房显示、进入下一轮和重开
  memory.gd               回忆界面到创作界面的切换
  writing.gd              结束本轮并返回书房
.gitignore                忽略 Godot 生成的 .godot 缓存
themes/ink_theme.tres      全局纸墨 UI 主题、字体与按钮状态
scenes/ui/                可复用的纸面背景
```

所有场景都使用 `Control` UI；当前文字和按钮仅用于验证导航，没有实现剧情分支。`GameState` 是 Godot 的自动加载节点，在切换场景时保留轮数，重新启动游戏时从第 1 轮开始。

## 填充开场画面

### 开场梦境闪回

`intro.gd` 自动播放约 45 秒的梦境：全黑 → 入梦画面渐亮 → 依次闪回攻城、洞庭落木、败走渡河、水毒山高、黑水冰雪、陆机王粲 → 加速重现并叠化 → 庾信书房 CG → 淡黑进入书房。右下角可随时跳过。图片在脚本的导出属性中设置，也可在 Godot 选中 Intro 根节点直接替换：

- `assets/images/cg/dream_opening.png`：原 3.png，梦境初现。
- `assets/images/cg/memory_siege.png`：原 4.png，攻城文段；也用于第一轮回忆。
- `assets/images/cg/memory_dongting.png`：原 5.png，洞庭落木文段；也用于第二轮回忆。
- `assets/images/cg/memory_zhangmanzhi.png`：原 6_2x.png，败走、渡河与鸡鸣；接入后续回忆。
- `assets/images/cg/memory_water_mountains.png`：原 7_2x.png，水毒山高与长亭短亭；接入后续回忆。
- `assets/images/cg/memory_black_water_ice.png`：原 8_2x.png，黑水、冰雪与天地失序；接入后续回忆。
- `assets/images/cg/memory_luji_wangcan.png`：原 9_2x.png，陆机、王粲与关山长叹；接入后续回忆。
- `assets/images/cg/study_intro.png`：梦境末尾回到庾信书房。

第一、二轮回忆通过 `GameState.memories` 的 `cg` 字段加载图片，覆盖一层淡纸色以保持正文可读。后续记忆可在同一字段填写自己的素材路径。

### 当前纸墨 UI

- 开始页引用 `assets/images/backgrounds/start_background.png`。图片等比填满窗口，宽屏显示会裁掉部分上下区域；在 `Background` 的 Stretch Mode 中可切换为 Keep Aspect Centered，以完整显示图片。
- 默认设计尺寸为 1280×800，使用 `canvas_items` 缩放。开始页标题放在上半部留白，避开桌面主体。
- 全局主题位于 `themes/ink_theme.tres`，通过项目设置 GUI → Theme → Custom 应用于所有界面和动态创建的按钮。
- 默认正文使用 `SourceHanSerifSC-Medium.otf`，开始页标题使用 Bold；`InkNote` 类型变体使用文楷，应用于副标题、批注及提示。ExtraLight 暂未使用，以保证正文对比度。
- 其他界面使用可复用的 `scenes/ui/paper_background.tscn`，背景脚本绘制暖纸底色、细微颗粒和淡墨晕染；以后可在场景中替换成自己的美术背景。
- 按钮使用细墨线、暖纸底色和朱红悬停／选中态，键盘焦点有轮廓提示。意象选中状态只表示当前选择，正式意象染色机制仍需后续接入。

- `scenes/start.tscn`：可替换 `Title`、`Subtitle`，并自行加入背景、主题音乐和开始页美术；保留 `BeginButton` 节点名称以维持现有脚本连接。
- `scenes/intro.tscn`：将 CG 放入 `assets/images/cg/`，选中 `CGImage`（`TextureRect`），在检查器中把图片拖到 **Texture**。按画面比例调整 **Stretch Mode**；添加多张 CG 时可自行增加图片节点或动画。
- 过场的 `BlackOverlay` 控制淡黑，`EchoImage` 控制叠化，`BottomMargin/ContinueButton` 用于跳过；保留这些节点名称以维持动画脚本连接。完成播放后自动进入书房。
- 书房视觉内容仍在 `scenes/study.tscn` 中填充；`scripts/intro.gd` 只负责过场到书房的场景切换。

## 下一步怎么扩展

1. `text.md` 中在段落末尾标记 `x` 的 6 段已接入为当前回忆骨架；书房不计入片段数。
2. 选中段落的标题、占位释义和 3 个注意对象暂时写在 `scripts/game_state.gd` 的 `memories` 数组中。
3. 在 `GameState` 中加入心境、已见记忆、关注意象及每轮残卷数据；由这些状态影响下一轮的记忆抽取。
4. 在 `writing.tscn` 和 `writing.gd` 中加入意象／词句拼贴、撤回和留白，将创作结果保存到全局状态。
5. 让 `study.tscn` 展示逐轮积累的残卷，再根据多轮组合规则实现灵感涌现。
6. 等玩法跑通后再添加纸张、墨迹、中文字体和音频资源；素材清单见 `project.md`。

`core.txt` 和 `text.md` 是既有资料，当前显示可能受文本编码影响；接入正式运行时文案前先核对原文、版本和编码。当前骨架使用 `text.md` 的行号作为来源标记，并使用脚本中的可读占位文本，避免把编码损坏的文件直接显示给玩家。
