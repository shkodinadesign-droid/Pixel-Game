// ===== ФЕРМЕР ДЖО — ПРОДАВЕЦ СЕМЯН (CREATE) =====
// Стоит на месте сидящего obj_farmer_joe у вагончика Джека и ничего не рисует (Джо рисует obj_farmer_joe).
// Диалог и магазин — как у Майли (родитель obj_joshua_npc). Первая встреча начинается сама, когда Макс подходит.
npc_name        = "Джо";
npc_speaker     = "Джо:";
npc_portrait    = spr_joe_portrait_anim;
npc_spr_idle    = spr_farmer_joe_smoke;
npc_spr_talk    = spr_farmer_joe_talk;
first_visit_key = "joe_first_visit_done";
stock_key       = "joe_inventory";
shop_title      = "Семена Джо";
repeat_line     = "Привет, внучка! Что хочешь купить?";
intro_lines = [
    ["Джо:",  "Привет, внучка! Что хочешь купить?",       ""],
    ["Макс:", "Здравствуйте, дядя Джо! Я вас помню.",     "Я Макс - внучка бабушки Сони."],
    ["Джо:",  "Макс! Вот это да, как я рад тебя видеть!", "Для тебя - самые лучшие семена!"],
];
shop_items = [
    { id: ITEM_SEED,            spr: spr_seed_carrot_icon,     col: make_color_rgb(160,200,80),  name: "Семена моркови",    price: 5 },
    { id: ITEM_POTATO_SEED,     spr: spr_potato_seed_icon,     col: make_color_rgb(220,170,50),  name: "Семена картофеля",  price: 6 },
    { id: ITEM_STRAWBERRY_SEED, spr: spr_strawberry_seed_icon, col: make_color_rgb(255,100,120), name: "Семена клубники",   price: 7 },
    { id: "tomato_seed",        spr: spr_tomato_seed_icon,     col: make_color_rgb(220,60,60),   name: "Семена помидоров",  price: 6 },
    { id: "pumpkin_seed",       spr: spr_pumpkin_seed_icon,    col: make_color_rgb(240,140,40),  name: "Семена тыквы",      price: 8 },
    { id: "onion_seed",         spr: spr_onion_seed_icon,      col: make_color_rgb(230,200,140), name: "Семена лука",       price: 5 },
];
talk_radius     = 80;                 // в деревне — только вплотную к Джо
var _lock = global.control_locked;    // родитель сбрасывает блокировку управления (рассчитан на вход в магазин)
event_inherited();
global.control_locked = _lock;
intro_timer = -1;                     // знакомство не по таймеру, а когда Макс подходит (см. Step)
