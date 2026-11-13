// ===== UI BAKERY CREATE =====

// Строим список доступных рецептов (с учётом unlock-флагов)
visible_recipes = [];
for (var _i = 0; _i < array_length(global.recipes); _i++) {
    var _rec = global.recipes[_i];
    var _ok  = true;
    if (variable_struct_exists(_rec, "unlock")) {
        _ok = variable_global_exists(_rec.unlock) && variable_global_get(_rec.unlock);
    }
    if (_ok) array_push(visible_recipes, _rec);
}
selected_recipe = 0;

// Подложка spr_cook_bg (629x477, по макету art_incoming/ui/cooking_v1): слева рамка с блюдом, справа рецепт; рисуется 1:1
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
panel_w = sprite_get_width(spr_cook_bg);
panel_h = sprite_get_height(spr_cook_bg);
panel_x = round((gui_w - panel_w) / 2);
panel_y = round((gui_h - panel_h) / 2);

// Разметка (пиксели подложки, см. tools/village/b22_cooking_ui.py)
title_x   = panel_x + 164;  title_y = panel_y + 57;    // центр таблички "Пекарня"
close_rx  = panel_x + 575;  close_cy = panel_y + 46;   // "[E] закрыть" — правый край и центр по высоте
frame_x0  = panel_x + 49;   frame_y0 = panel_y + 107;  // внутренность левой рамки
frame_x1  = panel_x + 235;  frame_y1 = panel_y + 394;
frame_cx  = (frame_x0 + frame_x1) / 2;
frame_cy  = panel_y + 232;                             // центр картинки блюда / миски

// Стрелки (33x31) и табличка названия рецепта (224x31)
nav_y     = panel_y + 76;
nav_l_x   = panel_x + 276;
nav_r_x   = panel_x + 560;
name_x    = panel_x + 324;
nav_w     = 33;
nav_h     = 31;

// Чек-лист: квадратики 18x18 с шагом 23, текст справа
check_x   = panel_x + 277;
check_y   = panel_y + 118;
check_dy  = 23;
check_tx  = panel_x + 308;

// Миска — рисуется в рамке, если у блюда нет картинки
bowl_cx     = frame_cx;
bowl_cy     = frame_cy;
bowl_rx     = 72;   // полуширина миски
bowl_ry     = 52;   // полувысота миски

// Ингредиенты в миске (item_id когда попали)
bowl_items = [];

// Анимации полёта ингредиентов
fly_anims = [];

// Ячейки ингредиентов 82x62: 3 в ряд, под ячейкой — название
cell_w      = 82;
cell_h      = 62;
cell_step_x = 104;
cell_step_y = 89;
cells_cols  = 3;
cells_x     = panel_x + 282;
cell_area_y = panel_y + 244;

// Hover
hover_cell = -1;

// Предотвращаем немедленный клик
_click_prev = true;

// Анимация готовки
cook_anim       = 0;
cook_done       = false;
cook_done_timer = 0;

// Анимация питья (для кофейных рецептов)
drink_phase = false;
drink_timer = 0;

// Кнопка "Готовить" (плашка spr_cook_btn 170x31) — внизу левой рамки
btn_w = sprite_get_width(spr_cook_btn);
btn_h = sprite_get_height(spr_cook_btn);
btn_x = round(frame_cx - btn_w / 2);
btn_y = frame_y1 - btn_h - 8;

// Анимации всплеска при попадании в миску
splash_anims = [];

// (диалог Макс после готовки — отдельный объект obj_ui_dialog_max_pie)
