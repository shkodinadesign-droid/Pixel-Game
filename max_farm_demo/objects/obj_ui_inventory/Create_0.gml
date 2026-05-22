// Координаты HUD
INV_WATERING_X = 86;   // твоя лейка
INV_WATERING_Y = 516;
INV_CARROT_X   = INV_WATERING_X + 42;
INV_CARROT_Y   = INV_WATERING_Y - 28;

// Иконка моркови
spr_carrot_ui = spr_carrot_icon; // твоё точное имя
spr_carrot_ui_subimg = 0;

// Поповер (+1 / -1)
carrot_pop_timer = 0;
carrot_pop_max   = room_speed * 1.2;
carrot_pop_text  = "";
carrot_pop_dy    = 0;

function show_carrot_pop(_txt) {
    carrot_pop_text  = _txt;
    carrot_pop_timer = carrot_pop_max;
    carrot_pop_dy    = 0;
}

// Универсальный попап: иконка + текст
item_pop_sprite = -1;
item_pop_text   = "";
item_pop_timer  = 0;
item_pop_max    = room_speed * 1.2;
item_pop_dy     = 0;

function show_item_pop(_sprite, _txt) {
    item_pop_sprite = _sprite;
    item_pop_text   = _txt;
    item_pop_timer  = item_pop_max;
    item_pop_dy     = 0;
}
