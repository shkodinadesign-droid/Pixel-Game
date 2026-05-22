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

// Размеры панели
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
panel_w = 620;
panel_h = 380;
panel_x = (gui_w - panel_w) / 2;
panel_y = (gui_h - panel_h) / 2;

// Сетка слотов
slot_size  = 60;
slot_gap   = 28; // вертикальный (между рядами — нужен для текста)
slot_gap_x = 18; // горизонтальный (между ячейками в ряду)
grid_cols = 3;
grid_rows = 2;
fridge_grid_x = panel_x + 24;
player_grid_x = panel_x + panel_w / 2 + 24;
grid_y        = panel_y + 58;

// Пропустить клик открытия
_click_prev = true;
