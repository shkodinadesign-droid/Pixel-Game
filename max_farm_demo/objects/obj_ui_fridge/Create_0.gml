// ===== UI FRIDGE CREATE =====

// Предметы в холодильнике
item_defs = [
    { id: "milk",  col: make_color_rgb(220,235,255), name: "Молоко"  },
    { id: "egg",   col: make_color_rgb(255,220,80),  name: "Яйцо"    },
    { id: "flour", col: make_color_rgb(235,225,205), name: "Мука"    },
    { id: "yeast", col: make_color_rgb(160,110,55),  name: "Дрожжи"  },
    { id: "sugar", col: make_color_rgb(240,240,220), name: "Сахар"   },
];
item_def_count = array_length(item_defs);

// Голубая книга-подложка spr_fridge_bg (836x470): слева холодильник, справа инвентарь; рисуется 1:1
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
panel_w = sprite_get_width(spr_fridge_bg);
panel_h = sprite_get_height(spr_fridge_bg);
panel_x = round((gui_w - panel_w) / 2);
panel_y = round((gui_h - panel_h) / 2);

// Разметка (пиксели подложки): центры табличек, сетки 3x2 из ячеек 48x48 (шаг 80 по x, 92 по y — под названием место)
title_y       = panel_y + 108;
fridge_cx     = panel_x + 236;
player_cx     = panel_x + 606;
slot_size  = 48;
slot_step_x = 80;
slot_step_y = 92;
grid_cols = 3;
grid_rows = 2;
fridge_grid_x = fridge_cx - 24 - slot_step_x;
player_grid_x = player_cx - 24 - slot_step_x;
grid_y        = panel_y + 160;
hint_y        = panel_y + 372;
close_x       = panel_x + 790;   // кнопка-крестик 30x30
close_y       = panel_y + 14;

// Пропустить клик открытия
_click_prev = true;
