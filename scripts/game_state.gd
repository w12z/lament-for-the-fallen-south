extends Node

var round_number: int = 1
var memory_index: int = 0
var selected_memory_title: String = ""
var selected_attention: String = ""

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


func finish_round() -> void:
	round_number += 1
	memory_index = mini(round_number - 1, memories.size() - 1)


func current_memory() -> Dictionary:
	return memories[memory_index]


func select_memory_attention(attention: String) -> void:
	selected_memory_title = current_memory()["title"]
	selected_attention = attention


func restart() -> void:
	round_number = 1
	memory_index = 0
	selected_memory_title = ""
	selected_attention = ""
