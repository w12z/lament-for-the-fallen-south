extends Node

const TOTAL_ROUNDS: int = 4
const MAX_SLOTS: int = 12
const THEME_NAMES: Dictionary = {
	"war": "烽火", "home": "故国", "water": "江水", "people": "故人",
	"silence": "失语", "road": "羁旅", "cold": "寒意", "return": "归返"
}
const THEME_MOODS: Dictionary = {
	"war": "记事", "home": "怀旧", "water": "羁旅", "people": "记事",
	"silence": "自守", "road": "羁旅", "cold": "羁旅", "return": "怀旧"
}

var round_number: int = 1
var memory_index: int = 0
var selected_memory_title: String = ""
var selected_attention: String = ""
var selected_attention_index: int = 0
var manuscript: Array[Dictionary] = []
var materials: Array[Dictionary] = []
var history: Array[Dictionary] = []
var visited_memories: Array[int] = [0]
var mood: Dictionary = {"怀旧": 0, "羁旅": 0, "记事": 0, "自守": 0}
var avoided: Dictionary = {}
var memory_reason: String = "最先浮起的，是旧营的烽火。"
var inspiration: String = ""

var attention_themes: Array = [
	["war", "war", "home"], ["water", "home", "road"],
	["people", "silence", "people"], ["road", "return", "water"],
	["water", "cold", "road"], ["water", "road", "cold"],
	["people", "water", "home"], ["road", "return", "silence"]
]
var phrases: Array = [
	["梯冲乱舞", "冀马云屯", "汉鼓于雷门"],
	["辞洞庭兮落木", "落木", "去涔阳兮极浦"],
	["忠臣解骨", "君子吞声", "忠臣"],
	["章曼支以毂走", "关未晓而鸡鸣", "河无冰而马渡"],
	["水毒秦泾", "山高赵陉", "长亭短亭"],
	["秦中水黑", "淄渑一乱", "雪暗如沙"],
	["见离家之王粲", "闻陇水而掩泣", "向关山而长叹"],
	["李陵之双凫永去", "苏武之一雁空飞", "一雁空飞"]
]
var echoes: Dictionary = {
	"war": ["烽火犹在，旧营已空", "鼓声盖过了姓名"],
	"home": ["故国仍在梦中", "旧岸不认归人"],
	"water": ["水向故乡流去", "此水不能渡我"],
	"people": ["有人未能同行", "名字留在纸外"],
	"silence": ["欲言而止", "未写下的仍在此处"],
	"road": ["此身仍在途中", "前路没有归期"],
	"cold": ["寒意入纸", "冰横断了来路"],
	"return": ["我还记得归路", "归路已无人等候"]
}

var memories: Array[Dictionary] = [
	{
		"title": "烽火与旧营",
		"source_line": 3,
		"text": "俄而梯冲乱舞，冀马云屯。俴秦车于畅毂，沓汉鼓于雷门。\n下陈仓而连弩，渡临晋而横船。",
		"cg": "res://assets/images/cg/memory_siege.png",
		"attention": ["攻城的声势", "火中的旗帜", "远处的旧营"]
	},
	{
		"title": "洞庭与落木",
		"source_line": 7,
		"text": "辞洞庭兮落木，去涔阳兮极浦。",
		"cg": "res://assets/images/cg/memory_dongting.png",
		"attention": ["洞庭的水面", "落下的木叶", "远去的水岸"]
	},
	{
		"title": "忠臣吞声",
		"source_line": 13,
		"text": "忠臣解骨，君子吞声。没有写下的名字停在残卷之外。",
		"attention": ["无名的死者", "未出口的话", "仍在观看的人"]
	},
	{
		"title": "败走与鸡鸣",
		"source_line": 18,
		"text": "章曼支以毂走，宫之奇以族行。河无冰而马渡，关未晓而鸡鸣。",
		"cg": "res://assets/images/cg/memory_zhangmanzhi.png",
		"attention": ["仓促的车轮", "未晓的关门", "渡河的马蹄"]
	},
	{
		"title": "水毒山高",
		"source_line": 21,
		"text": "水毒秦泾，山高赵陉。十里五里，长亭短亭。饥随蛰燕，暗逐流萤。",
		"cg": "res://assets/images/cg/memory_water_mountains.png",
		"attention": ["有毒的江水", "不可逾越的山", "长亭与短亭"]
	},
	{
		"title": "黑水与冰雪",
		"source_line": 25,
		"text": "秦中水黑，关上泥青。于时瓦解冰泮，风飞雹散，浑然千里，淄渑一乱。雪暗如沙，冰横似岸。",
		"cg": "res://assets/images/cg/memory_black_water_ice.png",
		"attention": ["黑水的颜色", "混乱的边界", "冰上的微光"]
	},
	{
		"title": "洛水与关山",
		"source_line": 27,
		"text": "逢赴洛之陆机，见离家之王粲，莫不闻陇水而掩泣，向关山而长叹。",
		"cg": "res://assets/images/cg/memory_luji_wangcan.png",
		"attention": ["离家的名字", "陇水的哭声", "关山的长叹"]
	},
	{
		"title": "一雁空飞",
		"source_line": 29,
		"text": "李陵之双凫永去，苏武之一雁空飞。归返只剩下远处的方向。",
		"attention": ["离去的飞鸟", "等待归返的人", "空着的远方"]
	}
]


func finish_round(draft: Array[Dictionary]) -> void:
	if is_complete() or draft.is_empty():
		return
	manuscript = draft.duplicate(true)
	var omitted: Array[Dictionary] = []
	for material in materials:
		var retained: bool = false
		for fragment in manuscript:
			if fragment.get("id", "") == material["id"]:
				retained = true
				break
		if not retained:
			omitted.append(material.duplicate(true))
			var theme: String = material["theme"]
			avoided[theme] = int(avoided.get(theme, 0)) + 1
	var attention_theme: String = attention_themes[memory_index][selected_attention_index]
	mood[THEME_MOODS[attention_theme]] += 2
	for fragment in manuscript:
		if fragment.get("round", 0) == round_number and not fragment.get("blank", false):
			mood[THEME_MOODS[fragment["theme"]]] += 1
	history.append({
		"memory": memory_index, "attention": selected_attention,
		"theme": attention_theme, "draft": manuscript.duplicate(true), "omitted": omitted
	})
	_update_inspiration()
	if not is_complete():
		_choose_next_memory(attention_theme)
		round_number += 1
		selected_memory_title = ""
		selected_attention = ""
		materials.clear()


func current_memory() -> Dictionary:
	return memories[memory_index]


func select_memory_attention(attention: String) -> void:
	selected_memory_title = current_memory()["title"]
	selected_attention = attention
	selected_attention_index = current_memory()["attention"].find(attention)
	_build_materials()


func _build_materials() -> void:
	materials.clear()
	var theme: String = attention_themes[memory_index][selected_attention_index]
	_add_material(phrases[memory_index][selected_attention_index], theme, "注意所得 · 原文摘句", "source")
	for phrase_index in range(3):
		if phrase_index != selected_attention_index:
			_add_material(phrases[memory_index][phrase_index], attention_themes[memory_index][phrase_index], "同一记忆 · 原文摘句", "source")
	_add_material(echoes[theme][0], theme, "意象残语 · 改写", "toward")
	_add_material(echoes[theme][1], theme, "意象残语 · 改写", "away")
	if not history.is_empty():
		var previous: Dictionary = history.back()
		if not previous["omitted"].is_empty():
			var returning: Dictionary = previous["omitted"][0].duplicate(true)
			returning["note"] = "上一轮未写下的回声"
			materials.append(returning)
		for fragment in previous["draft"]:
			if not fragment.get("blank", false):
				var returning: Dictionary = fragment.duplicate(true)
				returning["note"] = "上一轮留下的回声 · 可重复"
				materials.append(returning)
				break


func _add_material(text: String, theme: String, note: String, stance: String) -> void:
	materials.append({
		"id": "%d:%d" % [round_number, materials.size()], "text": text,
		"theme": theme, "note": note, "stance": stance,
		"round": round_number, "memory": memory_index, "blank": false
	})


func _choose_next_memory(attention_theme: String) -> void:
	var best_score: int = -1
	var next_index: int = 0
	var strongest_theme: String = attention_theme
	for candidate_index in range(memories.size()):
		if candidate_index in visited_memories:
			continue
		var score: int = 0
		var candidate_theme: String = attention_themes[candidate_index][0]
		var strongest_weight: int = -1
		var unique_themes: Array = []
		for theme in attention_themes[candidate_index]:
			if theme in unique_themes:
				continue
			unique_themes.append(theme)
			var weight: int = int(mood[THEME_MOODS[theme]]) + mini(int(avoided.get(theme, 0)), 4)
			if theme == attention_theme:
				weight += 3
			score += weight
			if weight > strongest_weight:
				strongest_weight = weight
				candidate_theme = theme
		if score > best_score:
			best_score = score
			next_index = candidate_index
			strongest_theme = candidate_theme
	memory_index = next_index
	visited_memories.append(memory_index)
	memory_reason = "你注意了「%s」。%s的余响与未写下的材料，使「%s」浮起。" % [
		selected_attention, THEME_NAMES[strongest_theme], current_memory()["title"]
	]


func is_complete() -> bool:
	return history.size() >= TOTAL_ROUNDS


func manuscript_text(draft: Array[Dictionary]) -> String:
	var lines: PackedStringArray = []
	for fragment in draft:
		lines.append("　　　　〔留白〕" if fragment.get("blank", false) else fragment["text"])
	return "\n".join(lines)


func relationship_notes(draft: Array[Dictionary]) -> String:
	var notes: PackedStringArray = []
	for fragment_index in range(draft.size() - 1):
		var first: Dictionary = draft[fragment_index]
		var second: Dictionary = draft[fragment_index + 1]
		var note: String = ""
		if first.get("blank", false) or second.get("blank", false):
			note = "第 %d、%d 行之间，留白使话语停住。" % [fragment_index + 1, fragment_index + 2]
		elif first["theme"] == second["theme"]:
			if [first["stance"], second["stance"]].has("toward") and [first["stance"], second["stance"]].has("away"):
				note = "「%s」与「%s」相互抵牾；两句都留在纸上。" % [first["text"], second["text"]]
			else:
				note = "「%s」紧接「%s」：%s在重复中变重。" % [first["text"], second["text"], THEME_NAMES[first["theme"]]]
		elif (first["theme"] == "war" and second["theme"] == "people") or (first["theme"] == "people" and second["theme"] == "war"):
			note = "「%s」紧接「%s」：鼓声与具体的人并置。" % [first["text"], second["text"]]
		elif first["stance"] == "source" and second["stance"] == "source":
			note = "「%s」／「%s」：两段旧句试着相对。" % [first["text"], second["text"]]
		if not note.is_empty():
			notes.append(note)
	return "\n".join(notes) if not notes.is_empty() else "句与句之间，尚未形成回声。试着换序、重复，或留出一行。"


func _update_inspiration() -> void:
	var theme_rounds: Dictionary = {}
	var has_blank: bool = false
	for fragment in manuscript:
		if fragment.get("blank", false):
			has_blank = true
			continue
		var theme: String = fragment["theme"]
		if not theme_rounds.has(theme):
			theme_rounds[theme] = []
		if not fragment["round"] in theme_rounds[theme]:
			theme_rounds[theme].append(fragment["round"])
	var relations: String = relationship_notes(manuscript)
	var has_tension: bool = relations.contains("抵牾") or relations.contains("具体的人")
	inspiration = ""
	if history.size() < 2 or not (has_blank or has_tension):
		return
	for theme in theme_rounds:
		if theme_rounds[theme].size() >= 2:
			var source_lines: PackedStringArray = []
			for fragment in manuscript:
				if fragment.get("blank", false):
					source_lines.append("　　　　〔停顿〕")
				elif fragment["stance"] == "source":
					source_lines.append(fragment["text"])
			inspiration = "灵感涌现 · %s\n不同轮次留下的%s，在%s中相遇。\n%s\n\n旧句重读 · 依照你留下的次序\n%s" % [
				THEME_NAMES[theme], THEME_NAMES[theme], "停顿" if has_blank else "矛盾", relations,
				"\n".join(source_lines) if not source_lines.is_empty() else "原文已被删去；此刻只有残语。"
			]
			return


func study_text() -> String:
	if history.is_empty():
		return "纸上尚空。每轮选一个意象，将旧句与残语放入同一份残卷。\n四轮之后，可以带着不完整的文字搁笔。"
	var sections: PackedStringArray = []
	sections.append("残卷 · 已写 %d 轮\n\n%s" % [history.size(), manuscript_text(manuscript)])
	sections.append("纸边批注\n%s" % relationship_notes(manuscript))
	var traces: PackedStringArray = []
	for attempt in history:
		traces.append("%s → 注意「%s」 · %d 份材料未写下" % [memories[attempt["memory"]]["title"], attempt["attention"], attempt["omitted"].size()])
	sections.append("来路\n%s" % "\n".join(traces))
	if not inspiration.is_empty():
		sections.append(inspiration)
	if is_complete():
		sections.append("搁笔\n" + ("旧句已有新的回声；它仍不是唯一的答案。" if not inspiration.is_empty() else "今夜未成整章。你留下的顺序、删改和空白，仍是一份作品。"))
	else:
		sections.append("下一次回望\n%s" % memory_reason)
	return "\n\n".join(sections)


func restart() -> void:
	round_number = 1
	memory_index = 0
	selected_memory_title = ""
	selected_attention = ""
	selected_attention_index = 0
	manuscript.clear()
	materials.clear()
	history.clear()
	visited_memories = [0]
	mood = {"怀旧": 0, "羁旅": 0, "记事": 0, "自守": 0}
	avoided.clear()
	memory_reason = "最先浮起的，是旧营的烽火。"
	inspiration = ""
