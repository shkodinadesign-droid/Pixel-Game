// ===== UI COFFEE MAKER CREATE =====

coffee_recipes = [
    {
        name: "Латте",
        ingredients: [
            { item: "coffee_beans", amount: 1 },
            { item: "milk",         amount: 1 },
            { item: "sugar",        amount: 1 }
        ],
        result: { item: "latte", amount: 1 }
    },
    {
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

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

panel_w = 560;
panel_h = 400;
panel_x = floor((gui_w - panel_w) / 2);
panel_y = floor((gui_h - panel_h) / 2);

// Левая область — миска
bowl_area_w = 200;
bowl_cx     = panel_x + bowl_area_w / 2;
bowl_cy     = panel_y + 50 + (panel_h - 90) / 2;
bowl_rx     = 72;
bowl_ry     = 52;

// Ингредиенты в миске
bowl_items = [];

// Анимации полёта и всплеска
fly_anims    = [];
splash_anims = [];

// Правая область
right_x = panel_x + bowl_area_w + 20;
right_w = panel_w - bowl_area_w - 28;

// Вкладки
tab_w = floor((right_w - 6) / 2);
tab_h = 22;
tab_y = panel_y + 42;

// Ячейки ингредиентов
cell_size   = 60;
cell_gap    = 16;
cells_cols  = 3;
cell_area_y = panel_y + 195;

hover_cell  = -1;
_click_prev = true;

// Анимация готовки
cook_anim       = 0;
cook_done       = false;
cook_done_timer = 0;

// Анимация питья
drink_phase = false;
drink_timer = 0;

// Кнопка Готовить
btn_w = right_w;
btn_h = 48;
btn_x = right_x;
btn_y = cell_area_y + cell_size + cell_gap + 6;

global.control_locked = true;
