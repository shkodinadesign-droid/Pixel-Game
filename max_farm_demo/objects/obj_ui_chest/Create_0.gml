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

// Размеры панели
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
panel_w = 620;
panel_h = 340;
panel_x = (gui_w - panel_w) / 2;
panel_y = (gui_h - panel_h) / 2;

// Сетка слотов
slot_size = 44;
slot_gap  = 5;
grid_cols = 4;
grid_rows = 3;
chest_grid_x  = panel_x + 20;
player_grid_x = panel_x + panel_w / 2 + 20;
grid_y        = panel_y + 58;

// Отслеживание кликов (true = пропустить клик открытия)
_click_prev = true;
