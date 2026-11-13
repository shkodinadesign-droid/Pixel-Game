// ===== UI CHEST CREATE =====

// Список известных предметов [id, спрайт или -1, цвет-заглушка, название]
item_defs = [
    { id: ITEM_CARROT,          spr: spr_carrot_icon, col: make_color_rgb(255,130,30),  name: "Морковь"       },
    { id: ITEM_SEED,            spr: spr_seed_carrot_icon,  col: make_color_rgb(160,200,80),  name: "Сем.моркови"   },
    { id: ITEM_POTATO_SEED,     spr: spr_potato_seed_icon, col: make_color_rgb(220,170,50),  name: "Сем.картофеля" },
    { id: ITEM_STRAWBERRY_SEED, spr: spr_strawberry_seed_icon,     col: make_color_rgb(255,100,120), name: "Сем.клубники"  },
    { id: "potato",             spr: spr_potato_icon, col: make_color_rgb(220,170,50),  name: "Картофель"     },
    { id: "coffee_beans",       spr: spr_cofee_icon,  col: make_color_rgb(100,60,20),   name: "К.зерна"       },
];
item_def_count = array_length(item_defs);

// Книга-подложка spr_storage_bg (836x470, как дневник): слева ящик, справа инвентарь; рисуется 1:1
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
panel_w = sprite_get_width(spr_storage_bg);
panel_h = sprite_get_height(spr_storage_bg);
panel_x = round((gui_w - panel_w) / 2);
panel_y = round((gui_h - panel_h) / 2);

// Разметка (пиксели подложки): центры табличек заголовков, сетки 4x3 из ячеек 48x48 с шагом 54
title_y       = panel_y + 108;
chest_cx      = panel_x + 236;
player_cx     = panel_x + 606;
slot_size = 48;
slot_gap  = 6;
grid_cols = 4;
grid_rows = 3;
chest_grid_x  = chest_cx  - 105;
player_grid_x = player_cx - 105;
grid_y        = panel_y + 160;
hint_y        = panel_y + 372;
close_x       = panel_x + 790;   // кнопка-крестик 30x30
close_y       = panel_y + 14;

// Отслеживание кликов (true = пропустить клик открытия)
_click_prev = true;
