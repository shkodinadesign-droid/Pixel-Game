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

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

panel_w = 560;
panel_h = 490;
panel_x = floor((gui_w - panel_w) / 2);
panel_y = floor((gui_h - panel_h) / 2);

// Левая область — миска
bowl_area_w = 200;
bowl_cx     = panel_x + bowl_area_w / 2;
bowl_cy     = panel_y + 50 + (panel_h - 90) / 2;
bowl_rx     = 72;   // полуширина миски
bowl_ry     = 52;   // полувысота миски

// Ингредиенты в миске (item_id когда попали)
bowl_items = [];

// Анимации полёта ингредиентов
fly_anims = [];

// Правая область — чеклист + ячейки
right_x  = panel_x + bowl_area_w + 20;
right_w  = panel_w - bowl_area_w - 28;

// Вкладки рецептов
tab_w  = floor((right_w - 6) / 2);
tab_h  = 22;
tab_y  = panel_y + 42;

// Ячейки ингредиентов
cell_size   = 60;
cell_gap    = 28;
cells_cols  = 3;
cell_area_y = panel_y + 246;

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

// Кнопка Готовить — под ячейками, справа
btn_w = right_w;
btn_h = 48;
btn_x = right_x;
btn_y = cell_area_y + 2 * (cell_size + cell_gap) + 6;

// Анимации всплеска при попадании в миску
splash_anims = [];

// (диалог Макс после готовки — отдельный объект obj_ui_dialog_max_pie)
