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

// Книга-подложка spr_storage_bg (836x470, как дневник): слева рецепт и ингредиенты, справа миска; рисуется 1:1
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
panel_w = sprite_get_width(spr_storage_bg);
panel_h = sprite_get_height(spr_storage_bg);
panel_x = round((gui_w - panel_w) / 2);
panel_y = round((gui_h - panel_h) / 2);

// Разметка (пиксели подложки)
title_y   = panel_y + 108;            // центр табличек
left_cx   = panel_x + 236;            // центр левой страницы
right_cx  = panel_x + 606;            // центр правой страницы
hint_y    = panel_y + 372;
close_x   = panel_x + 790;            // кнопка-крестик 30x30
close_y   = panel_y + 14;

// Стрелки листания рецептов (20x20) и номер рецепта между ними
arr_y     = panel_y + 140;
arr_l_x   = left_cx - 86;
arr_r_x   = left_cx + 66;

// Миска — по центру правой страницы
bowl_cx     = right_cx;
bowl_cy     = panel_y + 228;
bowl_rx     = 72;   // полуширина миски
bowl_ry     = 52;   // полувысота миски

// Ингредиенты в миске (item_id когда попали)
bowl_items = [];

// Анимации полёта ингредиентов
fly_anims = [];

// Ячейки ингредиентов 48x48: 3 в ряд, под ячейкой — название
cell_size   = 48;
cell_step_x = 80;
cell_step_y = 92;
cells_cols  = 3;
cells_x     = left_cx - 24 - cell_step_x;
cell_area_y = panel_y + 176;

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

// Кнопка "Готовить" (плашка 200x28) — под миской
btn_w = 200;
btn_h = 28;
btn_x = right_cx - 100;
btn_y = panel_y + 316;

// Анимации всплеска при попадании в миску
splash_anims = [];

// (диалог Макс после готовки — отдельный объект obj_ui_dialog_max_pie)
