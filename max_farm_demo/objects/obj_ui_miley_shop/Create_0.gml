// ===== UI МАГАЗИН МАЙЛИ (CREATE) =====

shop_items = [
    { id: "tomato_seed",    name: "Семена томатов",    price: 8  },
    { id: "pumpkin_seed",   name: "Семена тыквы",      price: 10 },
    { id: "sunflower_seed", name: "Семена подсолнуха", price: 10 },
    { id: "flour",          name: "Мука",              price: 6  },
    { id: "sugar",          name: "Сахар",             price: 5  },
    { id: "coffee_beans",   name: "Зерна кофе",        price: 8  },
];

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

item_count = array_length(shop_items);
item_h     = 48;
pad        = 16;

panel_w = 500;
panel_h = 64 + item_count * item_h + 48;
panel_x = (gui_w - panel_w) / 2;
panel_y = (gui_h - panel_h) / 2;

hover_item  = -1;
_click_prev = true;

global.control_locked = true;
