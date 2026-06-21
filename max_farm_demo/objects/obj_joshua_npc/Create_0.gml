say_timer = 0;
npc_name  = "Miley";

// Сбросить блокировку при входе в магазин (spawn_controller здесь не стоит)
global.control_locked = false;

// Автодиалог при первом входе
if (!variable_global_exists("miley_first_visit_done")) global.miley_first_visit_done = false;
intro_timer = global.miley_first_visit_done ? -1 : 90; // 1.5 сек задержка после входа

// Состояние диалога/магазина
// 0 = нет диалога
// 1 = фаза 0: Майли приветствует
// 2 = фаза 1: Макс отвечает
// 3 = фаза 2: Майли приглашает
// 4 = меню магазина открыто
shop_state = 0;

// Параметры диалогового окна
dw = 680;
dpad = 14;
dlh = 24;
dh = 50 + 3 * dlh + 50;
dx = 0; // вычисляется в Draw_64
dy = 20;
btn_w = 120;
btn_h = 30;
_click_prev = false;

// Товары магазина (идентично chest item_defs)
shop_items = [
    { id: "coffee_beans",       spr: spr_cofee_icon,           col: make_color_rgb(100,60,20),   name: "К.зерна",      price: 8  },
    { id: "tomato",             spr: -1,                       col: make_color_rgb(220,60,60),   name: "Томаты",       price: 4  },
    { id: ITEM_POTATO_SEED,     spr: spr_potato_seed_icon,     col: make_color_rgb(220,170,50),  name: "Сем.картоф.",  price: 6  },
    { id: ITEM_SEED,            spr: spr_seed_carrot_icon,     col: make_color_rgb(160,200,80),  name: "Сем.моркови",  price: 5  },
    { id: ITEM_STRAWBERRY_SEED, spr: spr_strawberry_seed_icon, col: make_color_rgb(255,100,120), name: "Сем.клубники", price: 7  },
    { id: "sunflower_seed",     spr: spr_seed,                 col: make_color_rgb(255,210,50),  name: "Сем.подсолн.", price: 10 },
    { id: "apple_sapling",      spr: spr_apple_icon,           col: make_color_rgb(180,60,60),   name: "Саж.яблони",   price: 15 },
    { id: "pear_sapling",       spr: spr_pear_icon,            col: make_color_rgb(180,200,80),  name: "Саж.груши",    price: 15 },
    { id: "milk",               spr: spr_milk_icon,            col: make_color_rgb(240,240,240), name: "Молоко",       price: 4  },
    { id: "sugar",              spr: spr_shugar_icon,          col: make_color_rgb(255,255,200), name: "Сахар",        price: 5  },
    { id: "flour",              spr: spr_flour_icon,           col: make_color_rgb(240,220,180), name: "Мука",         price: 6  },
    { id: "yeast",              spr: spr_yeast_icon,           col: make_color_rgb(200,160,80),  name: "Дрожжи",       price: 4  },
];

// Размеры панели (как у chest)
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
shop_panel_w = 620;
shop_panel_h = 380;
shop_panel_x = (_gw - shop_panel_w) / 2;
shop_panel_y = (_gh - shop_panel_h) / 2;

// Сетка (как у chest)
shop_slot_size = 44;
shop_slot_gap  = 5;
shop_grid_cols = 4;
shop_grid_rows = 3;
shop_grid_x    = shop_panel_x + 20;
shop_inv_x     = shop_panel_x + shop_panel_w / 2 + 20;
shop_grid_y    = shop_panel_y + 72;

// Выбор количества (покупка)
shop_selected  = -1;
shop_buy_qty   = 1;

// Продажа (правая сторона) — отдельный список
sell_items = [
    { id: "potato",          spr: spr_potato_icon,   col: make_color_rgb(220,170,50),  name: "Картофель",   price: 2  },
    { id: "apple",           spr: spr_apple_icon,    col: make_color_rgb(180,60,60),   name: "Яблоко",      price: 2  },
    { id: "pear",            spr: spr_pear_icon,     col: make_color_rgb(180,200,80),  name: "Груша",       price: 2  },
    { id: "potato_pie",      spr: spr_potatoes_pie,  col: make_color_rgb(200,150,80),  name: "Пирог",       price: 20 },
    { id: "carrot_pie",      spr: spr_carrot_pie,    col: make_color_rgb(220,130,50),  name: "Пирог морк.", price: 20 },
    { id: "carrot_muffin",   spr: -1,                col: make_color_rgb(200,150,80),  name: "Маффин",      price: 20 },
    { id: "apple_bun",       spr: -1,                col: make_color_rgb(200,150,80),  name: "Булочки",     price: 20 },
];

sell_selected  = -1;
sell_qty       = 1;
