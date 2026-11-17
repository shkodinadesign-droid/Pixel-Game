// ===== UI COFFEE MAKER CREATE =====

coffee_recipes = [
    {
        id:   "latte",
        name: "Латте",
        ingredients: [
            { item: "coffee_beans", amount: 1 },
            { item: "milk",         amount: 1 },
            { item: "sugar",        amount: 1 }
        ],
        result: { item: "latte", amount: 1 }
    },
    {
        id:   "americano",
        name: "Американо",
        ingredients: [
            { item: "coffee_beans", amount: 1 },
            { item: "water",        amount: 1 },
            { item: "sugar",        amount: 1 }
        ],
        result: { item: "americano", amount: 1 }
    }
];
selected_recipe = 0; // 0 = Латте (по умолчанию)

// Разметка — как у окна готовки obj_ui_bakery (подложка spr_cook_bg 629x477, рисуется 1:1)
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
panel_w = sprite_get_width(spr_cook_bg);
panel_h = sprite_get_height(spr_cook_bg);
panel_x = round((gui_w - panel_w) / 2);
panel_y = round((gui_h - panel_h) / 2);

title_x  = panel_x + 164;  title_y  = panel_y + 57;    // табличка "Кофемашина"
close_rx = panel_x + 575;  close_cy = panel_y + 46;    // "[E] закрыть"
frame_x0 = panel_x + 49;   frame_y0 = panel_y + 107;   // левая рамка — чашка
frame_x1 = panel_x + 235;  frame_y1 = panel_y + 394;
frame_cx = (frame_x0 + frame_x1) / 2;
frame_cy = panel_y + 232;

nav_y   = panel_y + 76;  nav_l_x = panel_x + 276;  nav_r_x = panel_x + 560;  name_x = panel_x + 324;
nav_w   = 33;            nav_h   = 31;
check_x = panel_x + 277; check_y = panel_y + 118;  check_dy = 23;  check_tx = panel_x + 308;

// Ингредиенты летят в чашку (центр рамки)
bowl_cx = frame_cx;
bowl_cy = frame_cy + 20;
bowl_items   = [];
fly_anims    = [];
splash_anims = [];

// Ячейки ингредиентов 82x62: 3 в ряд, под ячейкой — название
cell_w = 82; cell_h = 62; cell_step_x = 104; cell_step_y = 89; cells_cols = 3;
cells_x = panel_x + 282; cell_area_y = panel_y + 244;

hover_cell  = -1;
_click_prev = true;

// Анимация готовки
cook_anim       = 0;
cook_done       = false;
cook_done_timer = 0;

// Анимация питья
drink_phase = false;
drink_timer = 0;

// Кнопка "Сварить" (плашка spr_cook_btn) — внизу рамки
btn_w = sprite_get_width(spr_cook_btn);
btn_h = sprite_get_height(spr_cook_btn);
btn_x = round(frame_cx - btn_w / 2);
btn_y = frame_y1 - btn_h - 16;

global.control_locked = true;
