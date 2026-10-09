// ===== ОКНО ДОСКИ ОБЪЯВЛЕНИЙ (CREATE) =====
// Попап в стиле дневника: список объявлений (магазины деревни) + одно задание от Ивана

if (!variable_global_exists("control_locked"))    global.control_locked    = false;
if (!variable_global_exists("ivan_quest_started")) global.ivan_quest_started = false;
if (!variable_global_exists("ivan_quest_done"))    global.ivan_quest_done    = false;
global.control_locked = true;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Цвета — те же, что в спрайте дневника (spr_diary_bg)
col_leather_dark = make_color_rgb(77, 43, 37);
col_leather      = make_color_rgb(102, 57, 49);
col_leather_hi   = make_color_rgb(157, 87, 75);
col_page_edge    = make_color_rgb(222, 203, 144);
col_page         = make_color_rgb(248, 226, 161);
col_line         = make_color_rgb(200, 149, 82);
col_title        = make_color_rgb(70, 40, 15);
col_text         = make_color_rgb(55, 35, 15);
col_author       = make_color_rgb(120, 80, 35);

// Окно
win_w  = 640;
win_h  = 460;
win_x  = round((_gw - win_w) / 2);
win_y  = round((_gh - win_h) / 2);
border = 14;   // кожаная рамка
pad    = 22;   // отступ текста от края страницы

// Объявления: { title, text, author, quest }
notes = [
    { title: "Магазин Майли",  author: "Майли",  quest: false,
      text: "Семена, саженцы, молоко, мука, сахар, дрожжи и кофейные зёрна. Новым покупателям - скидки!" },
    { title: "Мясная лавка",   author: "Иван",   quest: false,
      text: "Скоро открытие! Свежее мясо и домашние колбаски каждый день." },
    { title: "Пекарня",        author: "Пекарня", quest: false,
      text: "Свежие пироги и кофе. Заказы принимаем на доске в пекарне." },
    { title: "Нужна морковь!", author: "Иван",   quest: true,
      text: "Готовлю рагу к открытию лавки, а моркови не хватает. Принесите 5 морковок - заплачу 25 монет." },
];

// Кнопка "Взять задание" (координаты считаются в Draw)
qbtn_w  = 150;
qbtn_h  = 28;
qbtn_x1 = -1; qbtn_y1 = -1; qbtn_x2 = -1; qbtn_y2 = -1;

// Кнопка закрытия — зелёный крестик, как в дневнике
close_r  = 15;
close_cx = win_x + win_w - 6;
close_cy = win_y + 6;

_click_prev = true;
open_delay  = 2;     // E, которым открыли доску, не должна её сразу закрыть
