// ===== DIARY DRAW GUI =====

var bs = book_scale; // короткий псевдоним

draw_set_alpha(1);

// Затемнение фона
draw_set_color(c_black);
draw_set_alpha(0.5);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Фон книги — масштабируем спрайт
draw_sprite_ext(spr_diary_bg, 0, book_x, book_y, bs, bs, 0, c_white, 1);

// Спрайты вкладок
var tab_sprites = [
    spr_tab_inventory,   // 0 - Инвентарь
    spr_tab_quests,      // 1 - Задания
    spr_tab_plants,      // 2 - Растения
    spr_tab_diary,       // 3 - Рецепты
    spr_tab_friends,     // 4 - Друзья
    spr_tab_adventures,  // 5 - Приключения
    spr_tab_currency     // 6 - Валюта
];

// Вкладки сверху
var _tab_corner = round(6 * bs);
var _recipes_unlocked = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;

for (var i = 0; i < 7; i++) {
    var tx1 = tab_start_x + i * (tab_w + tab_spacing);
    var ty1 = book_y - tab_h + round(5 * bs);
    var tx2 = tx1 + tab_w;
    var ty2 = ty1 + tab_h;

    var _locked = (i == 3 && !_recipes_unlocked);

    if (_locked) {
        draw_set_color(make_color_rgb(160, 150, 145)); // серая заблокированная
    } else if (i == current_tab) {
        draw_set_color(make_color_rgb(245, 235, 220));
    } else {
        draw_set_color(make_color_rgb(200, 180, 160));
    }
    draw_roundrect_ext(tx1, ty1, tx2, ty2, _tab_corner, _tab_corner, false);
    draw_set_color(_locked ? make_color_rgb(100, 90, 85) : make_color_rgb(139, 90, 43));
    draw_roundrect_ext(tx1, ty1, tx2, ty2, _tab_corner, _tab_corner, true);

    // Иконка вкладки
    var spr = tab_sprites[i];
    if (sprite_exists(spr)) {
        var spr_w = sprite_get_width(spr)  * bs;
        var spr_h = sprite_get_height(spr) * bs;
        var spr_x = tx1 + (tab_w - spr_w) / 2;
        var spr_y = ty1 + (tab_h - spr_h) / 2;
        var spr_alpha = _locked ? 0.25 : ((i == current_tab) ? 1.0 : 0.6);
        draw_sprite_ext(spr, 0, spr_x, spr_y, bs, bs, 0, c_white, spr_alpha);
    }

    // Замок поверх заблокированной вкладки (нарисованный примитивами)
    if (_locked) {
        var _lx = tx1 + tab_w / 2;
        var _ly = ty1 + tab_h / 2 + round(2 * bs);
        var _lw = round(7 * bs);
        var _lh = round(6 * bs);
        // Корпус замка
        draw_set_color(make_color_rgb(80, 70, 65));
        draw_roundrect_ext(_lx - _lw / 2, _ly, _lx + _lw / 2, _ly + _lh, 2, 2, false);
        // Дужка (полукруг сверху)
        draw_set_color(make_color_rgb(80, 70, 65));
        draw_ellipse(_lx - _lw / 3, _ly - _lh * 0.8, _lx + _lw / 3, _ly + 1, true);
        draw_set_color(make_color_rgb(160, 150, 145));
        draw_ellipse(_lx - _lw / 3 + 2, _ly - _lh * 0.8 + 2, _lx + _lw / 3 - 2, _ly, true);
    }
}

// Заголовок текущей вкладки
draw_set_font(fnt_dialog);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(80, 50, 20));
draw_text(book_x + round(40 * bs), book_y + round(20 * bs), tab_names[current_tab]);

// Контент вкладки
var content_x = book_x + round(30 * bs);
var content_y = book_y + round(60 * bs);

switch (current_tab) {
    case 0: // Инвентарь

        // [спрайт (-1 = нет), цвет-заглушка, количество, название, описание]
        var inv_items = [
            [spr_carrot_icon, make_color_rgb(255,130,30),
             inventory_get_amount(ITEM_CARROT), "Морковь",
             "Сочная морковка с грядки.\n\nВремя роста: 3 дня.\nХранение в ящике для овощей.\n\nИспользуется в рецептах:\nМорковный пирог."],
            [spr_seed_carrot_icon, make_color_rgb(160,200,80),
             inventory_get_amount(ITEM_SEED), "Семена моркови",
             "Семена моркови.\n\nВремя роста: 3 дня.\nПосадить на вспаханную грядку."],
            [spr_potato_seed_icon, make_color_rgb(220,170,50),
             inventory_get_amount(ITEM_POTATO_SEED), "Семена картофеля",
             "Семена картофеля.\n\nВремя роста: 4 дня.\nПосадить на вскопанную грядку."],
            [spr_strawberry_seed_icon, make_color_rgb(255,100,120),
             inventory_get_amount(ITEM_STRAWBERRY_SEED), "Семена клубники",
             "Семена клубники.\n\nВремя роста: 3 дня.\nПосадить на вскопанную грядку."],
            [spr_potato_icon, make_color_rgb(220,170,50),
             inventory_get_amount("potato"), "Картофель",
             "Картошка из сарая.\n\nВремя роста: 4 дня.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_milk_icon, make_color_rgb(220,235,255),
             inventory_get_amount("milk"), "Молоко",
             "Свежее молоко.\n\nИсточник: корова.\nХранить в холодильнике.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_egg_icon, make_color_rgb(255,220,80),
             inventory_get_amount("egg"), "Яйцо",
             "Куриное яйцо.\n\nИсточник: курица.\nХранить в холодильнике.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_flour_icon, make_color_rgb(235,225,205),
             inventory_get_amount("flour"), "Мука",
             "Пшеничная мука.\n\nХранить в холодильнике.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_yeast_icon, make_color_rgb(160,110,55),
             inventory_get_amount("yeast"), "Дрожжи",
             "Дрожжи для выпечки.\n\nХранить в холодильнике.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_potatoes_pie, make_color_rgb(190,120,55),
             inventory_get_amount("potato_pie"), "Картоф. пирог",
             "Любимый пирог Джастина.\n\nПриготовить в пекарне:\nКартофель + Молоко + Яйцо\nМука + Дрожжи.\n\nМожно продать или\nотдать Джастину."],
        ];
        var inv_count = array_length(inv_items);

        // --- Константы сетки (масштабированные) ---
        var slot_size = round(38 * bs);  // ~48
        var slot_gap  = round(4  * bs);  // ~5
        var grid_cols = 5;
        var grid_rows = 3;
        var grid_x    = book_x + round(40 * bs);
        var grid_y    = book_y + round(48 * bs);
        var _slot_corner = round(4 * bs);

        // --- Сетка слотов ---
        for (var _row = 0; _row < grid_rows; _row++) {
            for (var _col = 0; _col < grid_cols; _col++) {
                var _idx = _row * grid_cols + _col;
                var _sx  = grid_x + _col * (slot_size + slot_gap);
                var _sy  = grid_y + _row * (slot_size + slot_gap);

                var _is_sel = (_idx == selected_item);
                draw_set_color(_is_sel ? make_color_rgb(220, 195, 155) : make_color_rgb(200, 175, 140));
                draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, _slot_corner, _slot_corner, false);
                draw_set_color(_is_sel ? make_color_rgb(139, 90, 43) : make_color_rgb(160, 120, 80));
                draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, _slot_corner, _slot_corner, true);

                if (_idx < inv_count) {
                    var _ispr = inv_items[_idx][0];
                    var _icol = inv_items[_idx][1];
                    var _iqty = inv_items[_idx][2];

                    if (_iqty > 0) {
                        if (sprite_exists(_ispr)) {
                            var _iw  = sprite_get_width(_ispr);
                            var _ih  = sprite_get_height(_ispr);
                            var _pad = round(6 * bs);
                            var _sc  = min((slot_size - _pad) / _iw,
                                           (slot_size - _pad) / _ih);
                            var _dw  = _iw * _sc;
                            var _dh  = _ih * _sc;
                            var _ccx = _sx + slot_size / 2;
                            var _ccy = _sy + slot_size / 2;
                            draw_sprite_stretched_ext(_ispr, 0,
                                _ccx - _dw / 2, _ccy - _dh / 2, _dw, _dh,
                                c_white, 1);
                        } else {
                            // Цветной круг-заглушка
                            draw_set_color(_icol);
                            draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, round(13 * bs), false);
                            draw_set_color(make_color_rgb(0,0,0));
                            draw_set_alpha(0.15);
                            draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, round(13 * bs), true);
                            draw_set_alpha(1);
                        }

                        // Кружок с цифрой — на правом нижнем углу
                        var _br = round(6 * bs);
                        var _bx = _sx + slot_size;
                        var _by = _sy + slot_size;
                        draw_set_color(make_color_rgb(70, 40, 10));
                        draw_circle(_bx, _by, _br, false);
                        draw_set_font(fnt_dialog);
                        draw_set_halign(fa_center);
                        draw_set_valign(fa_middle);
                        draw_set_color(c_white);
                        draw_text(_bx, _by, string(_iqty));
                        draw_set_halign(fa_left);
                        draw_set_valign(fa_top);
                    }
                }
            }
        }

        // --- Правая страница — карточка предмета ---
        var detail_x = book_x + round(288 * bs);
        var detail_y = book_y + round(20  * bs);
        var detail_w = book_w - round(288 * bs) - round(20 * bs);
        var detail_h = book_h - round(20  * bs) - round(38 * bs);

        if (selected_item >= 0 && selected_item < inv_count
            && inv_items[selected_item][2] > 0) {

            var _iname = inv_items[selected_item][3];
            var _idesc = inv_items[selected_item][4];
            var _iqty2 = inv_items[selected_item][2];

            // Рамка карточки
            draw_set_alpha(0.93);
            draw_set_color(make_color_rgb(250, 242, 220));
            draw_roundrect_ext(detail_x, detail_y,
                detail_x + detail_w, detail_y + detail_h, 6, 6, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_roundrect_ext(detail_x, detail_y,
                detail_x + detail_w, detail_y + detail_h, 6, 6, true);

            // Заголовок (жирный)
            draw_set_font(fnt_dialog);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(70, 35, 5));
            draw_text(detail_x + 12, detail_y + 12, _iname);

            // Разделитель
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(detail_x + 10, detail_y + 34,
                      detail_x + detail_w - 10, detail_y + 34);

            // Описание (обычный шрифт, с переносом по ширине карточки)
            draw_set_font(fnt_dialog);
            draw_set_color(make_color_rgb(55, 35, 15));
            draw_text_ext(detail_x + 12, detail_y + 42, _idesc, -1, detail_w - 22);

            // Количество — внизу справа
            draw_set_halign(fa_right);
            draw_set_color(make_color_rgb(139, 90, 43));
            draw_text(detail_x + detail_w - 10, detail_y + detail_h - 16,
                      "Кол-во: " + string(_iqty2));
            draw_set_halign(fa_left);

        } else {
            // Подсказка — по центру правой страницы, на уровне сетки
            draw_set_font(fnt_dialog);
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(detail_x + detail_w / 2, detail_y,
                      "Выбери предмет\nиз инвентаря");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        break;

    case 1: // Задания
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // Заголовок раздела
        draw_set_font(fnt_dialog);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x, content_y, "Основные задания");

        var _tbox = round(13 * bs);   // размер чекбокса
        var _tgap = round(7  * bs);   // отступ текста от чекбокса
        var _ty   = content_y + round(28 * bs);

        // --- Задание 1: Посадить зерна (ВЫПОЛНЕНО) ---
        draw_set_color(make_color_rgb(70, 150, 70));
        draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, false);
        draw_set_font(fnt_dialog);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(content_x + _tbox / 2, _ty + _tbox / 2, "v");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(140, 115, 90));
        var _task1 = "Посадить зерна";
        draw_text(content_x + _tbox + _tgap, _ty, _task1);
        // Зачеркивание
        var _st_y = _ty + string_height(_task1) / 2;
        draw_line(content_x + _tbox + _tgap, _st_y,
                  content_x + _tbox + _tgap + string_width(_task1), _st_y);

        // --- Задание 2: Изучить пекарню ---
        _ty += round(32 * bs);
        var _justin_done = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;

        if (_justin_done) {
            // Выполнено — зелёный чекбокс + зачёркивание
            draw_set_color(make_color_rgb(70, 150, 70));
            draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, false);
            draw_set_font(fnt_dialog);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            draw_text(content_x + _tbox / 2, _ty + _tbox / 2, "v");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(140, 115, 90));
            var _task2 = "Изучить пекарню";
            draw_text(content_x + _tbox + _tgap, _ty, _task2);
            var _st2_y = _ty + string_height(_task2) / 2;
            draw_line(content_x + _tbox + _tgap, _st2_y,
                      content_x + _tbox + _tgap + string_width(_task2), _st2_y);

            // --- Задание 3: Приготовить картофельный пирог ---
            _ty += round(32 * bs);
            var _pie_done = variable_global_exists("potato_pie_done") && global.potato_pie_done;
            if (_pie_done) {
                // Выполнено
                draw_set_color(make_color_rgb(70, 150, 70));
                draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, false);
                draw_set_font(fnt_dialog);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(content_x + _tbox / 2, _ty + _tbox / 2, "v");
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                draw_set_color(make_color_rgb(140, 115, 90));
                var _task3 = "Приготовить картофельный пирог";
                draw_text(content_x + _tbox + _tgap, _ty, _task3);
                var _st3_y = _ty + string_height(_task3) / 2;
                draw_line(content_x + _tbox + _tgap, _st3_y,
                          content_x + _tbox + _tgap + string_width(_task3), _st3_y);
            } else {
                draw_set_color(make_color_rgb(139, 90, 43));
                draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, true);
                draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(content_x + _tbox + _tgap + 5, _ty, "Приготовить картофельный пирог");
            }

            // --- Задание 4: Приготовить кофе ---
            if (variable_global_exists("coffee_letter_read") && global.coffee_letter_read) {
                _ty += round(32 * bs);
                var _coffee_task_done = variable_global_exists("coffee_made") && global.coffee_made;
                if (_coffee_task_done) {
                    draw_set_color(make_color_rgb(70, 150, 70));
                    draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, false);
                    draw_set_font(fnt_dialog);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_set_color(c_white);
                    draw_text(content_x + _tbox / 2, _ty + _tbox / 2, "v");
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                    draw_set_color(make_color_rgb(140, 115, 90));
                    var _task4 = "Приготовить себе кофе";
                    draw_text(content_x + _tbox + _tgap, _ty, _task4);
                    var _st4_y = _ty + string_height(_task4) / 2;
                    draw_line(content_x + _tbox + _tgap, _st4_y,
                              content_x + _tbox + _tgap + string_width(_task4), _st4_y);
                } else {
                    draw_set_color(make_color_rgb(200, 80, 60));
                    draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, false);
                    draw_set_color(make_color_rgb(160, 50, 30));
                    draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, true);
                    draw_set_font(fnt_dialog);
                    draw_set_color(make_color_rgb(55, 35, 15));
                    draw_text(content_x + _tbox + _tgap + 5, _ty, "Приготовить себе кофе");
                }
            }

            // --- Задание 5: Посади клубнику и картофель ---
            if (variable_global_exists("plant_quest_started") && global.plant_quest_started) {
                _ty += round(32 * bs);
                var _plant_done = variable_global_exists("plant_quest_done") && global.plant_quest_done;
                if (_plant_done) {
                    // Выполнено — зелёный чекбокс + зачёркивание
                    draw_set_color(make_color_rgb(70, 150, 70));
                    draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, false);
                    draw_set_font(fnt_dialog);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_set_color(c_white);
                    draw_text(content_x + _tbox / 2, _ty + _tbox / 2, "v");
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                    draw_set_color(make_color_rgb(140, 115, 90));
                    var _task5 = "Посади клубнику и картофель";
                    draw_text(content_x + _tbox + _tgap, _ty, _task5);
                    var _st5_y = _ty + string_height(_task5) / 2;
                    draw_line(content_x + _tbox + _tgap, _st5_y,
                              content_x + _tbox + _tgap + string_width(_task5), _st5_y);
                } else {
                    // Активное — красный чекбокс + описание
                    draw_set_color(make_color_rgb(200, 80, 60));
                    draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, false);
                    draw_set_color(make_color_rgb(160, 50, 30));
                    draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, true);
                    draw_set_font(fnt_dialog);
                    draw_set_color(make_color_rgb(55, 35, 15));
                    draw_text(content_x + _tbox + _tgap + 5, _ty, "Посади клубнику и картофель");
                }
            }

        } else {
            // Не выполнено — пустой чекбокс
            draw_set_color(make_color_rgb(139, 90, 43));
            draw_roundrect_ext(content_x, _ty, content_x + _tbox, _ty + _tbox, 2, 2, true);
            draw_set_color(make_color_rgb(55, 35, 15));
            draw_text(content_x + _tbox + _tgap, _ty, "Изучить пекарню");
        }

        // ===== ПРАВАЯ СТРАНИЦА: ОСНОВНЫЕ ЗАДАНИЯ =====
        if (variable_global_exists("secret_quest_started") && global.secret_quest_started) {
            var _rp_x = book_x + round(295 * bs);
            var _rp_y = book_y + round(20 * bs);
            var _rp_w = book_w - round(295 * bs) - round(15 * bs);
            var _rp_lh = round(26 * bs);  // высота строки
            var _rtbox = round(12 * bs);  // чекбокс
            var _rtgap = round(6  * bs);  // отступ

            // Заголовок
            draw_set_font(fnt_dialog);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(120, 60, 10));
            draw_text(_rp_x, _rp_y, "Сюжетный квест");

            // Разделитель
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_rp_x, _rp_y + round(20 * bs), _rp_x + _rp_w, _rp_y + round(20 * bs));

            var _ry = _rp_y + round(28 * bs);

            // Главная задача
            var _all_done =
                (variable_global_exists("three_pies_done")       && global.three_pies_done) &&
                (variable_global_exists("all_coffees_done")      && global.all_coffees_done) &&
                (variable_global_exists("pizza_recipe_done")     && global.pizza_recipe_done) &&
                (variable_global_exists("helped_villagers_done") && global.helped_villagers_done) &&
                (variable_global_exists("pear_jam_done")         && global.pear_jam_done);

            if (_all_done) {
                draw_set_color(make_color_rgb(70, 150, 70));
                draw_roundrect_ext(_rp_x, _ry, _rp_x + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_font(fnt_dialog); draw_set_halign(fa_center); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_rp_x + _rtbox / 2, _ry + _rtbox / 2, "v");
                draw_set_halign(fa_left); draw_set_valign(fa_top);
                draw_set_color(make_color_rgb(140, 115, 90));
                draw_text(_rp_x + _rtbox + _rtgap, _ry, "Узнать где ключ от тайной двери");
                draw_line(_rp_x + _rtbox + _rtgap, _ry + _rp_lh * 0.5,
                          _rp_x + _rp_w, _ry + _rp_lh * 0.5);
            } else {
                draw_set_color(make_color_rgb(139, 90, 43));
                draw_roundrect_ext(_rp_x, _ry, _rp_x + _rtbox, _ry + _rtbox, 2, 2, true);
                draw_set_font(fnt_dialog); draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_rp_x + _rtbox + _rtgap, _ry, "Узнать где ключ от тайной двери");
            }
            _ry += round(32 * bs);

            // Вспомогательная функция отрисовки под-задачи
            // [1] Три пирога
            var _t1 = variable_global_exists("three_pies_done") && global.three_pies_done;
            var _ind = round(14 * bs);
            if (_t1) {
                draw_set_color(make_color_rgb(70, 150, 70));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_font(fnt_dialog); draw_set_halign(fa_center); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_rp_x + _ind + _rtbox / 2, _ry + _rtbox / 2, "v");
                draw_set_halign(fa_left); draw_set_valign(fa_top);
                draw_set_color(make_color_rgb(140, 115, 90));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "1. Приготовить три пирога");
                draw_line(_rp_x + _ind + _rtbox + _rtgap, _ry + _rp_lh * 0.5,
                          _rp_x + _ind + _rtbox + _rtgap + string_width("1. Приготовить три пирога"), _ry + _rp_lh * 0.5);
            } else {
                draw_set_color(make_color_rgb(200, 80, 60));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_color(make_color_rgb(160, 50, 30));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, true);
                draw_set_font(fnt_dialog); draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "1. Приготовить три пирога");
            }
            _ry += _rp_lh;

            // [2] Все виды кофе
            var _t2 = variable_global_exists("all_coffees_done") && global.all_coffees_done;
            if (_t2) {
                draw_set_color(make_color_rgb(70, 150, 70));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_font(fnt_dialog); draw_set_halign(fa_center); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_rp_x + _ind + _rtbox / 2, _ry + _rtbox / 2, "v");
                draw_set_halign(fa_left); draw_set_valign(fa_top);
                draw_set_color(make_color_rgb(140, 115, 90));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "2. Сварить все виды кофе");
                draw_line(_rp_x + _ind + _rtbox + _rtgap, _ry + _rp_lh * 0.5,
                          _rp_x + _ind + _rtbox + _rtgap + string_width("2. Сварить все виды кофе"), _ry + _rp_lh * 0.5);
            } else {
                draw_set_color(make_color_rgb(200, 80, 60));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_color(make_color_rgb(160, 50, 30));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, true);
                draw_set_font(fnt_dialog); draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "2. Сварить все виды кофе");
            }
            _ry += _rp_lh;

            // [3] Рецепт пиццы бабули
            var _t3 = variable_global_exists("pizza_recipe_done") && global.pizza_recipe_done;
            if (_t3) {
                draw_set_color(make_color_rgb(70, 150, 70));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_font(fnt_dialog); draw_set_halign(fa_center); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_rp_x + _ind + _rtbox / 2, _ry + _rtbox / 2, "v");
                draw_set_halign(fa_left); draw_set_valign(fa_top);
                draw_set_color(make_color_rgb(140, 115, 90));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "3. Открыть рецепт пиццы бабули");
                draw_line(_rp_x + _ind + _rtbox + _rtgap, _ry + _rp_lh * 0.5,
                          _rp_x + _rp_w, _ry + _rp_lh * 0.5);
            } else {
                draw_set_color(make_color_rgb(200, 80, 60));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_color(make_color_rgb(160, 50, 30));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, true);
                draw_set_font(fnt_dialog); draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "3. Открыть рецепт пиццы бабули");
            }
            _ry += _rp_lh;

            // [4] Помочь жителям деревни
            var _t4 = variable_global_exists("helped_villagers_done") && global.helped_villagers_done;
            if (_t4) {
                draw_set_color(make_color_rgb(70, 150, 70));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_font(fnt_dialog); draw_set_halign(fa_center); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_rp_x + _ind + _rtbox / 2, _ry + _rtbox / 2, "v");
                draw_set_halign(fa_left); draw_set_valign(fa_top);
                draw_set_color(make_color_rgb(140, 115, 90));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "4. Помочь жителям деревни");
                draw_line(_rp_x + _ind + _rtbox + _rtgap, _ry + _rp_lh * 0.5,
                          _rp_x + _rp_w, _ry + _rp_lh * 0.5);
            } else {
                draw_set_color(make_color_rgb(200, 80, 60));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_color(make_color_rgb(160, 50, 30));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, true);
                draw_set_font(fnt_dialog); draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "4. Помочь жителям деревни");
            }
            _ry += _rp_lh;

            // [5] Грушевое варенье
            var _t5 = variable_global_exists("pear_jam_done") && global.pear_jam_done;
            if (_t5) {
                draw_set_color(make_color_rgb(70, 150, 70));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_font(fnt_dialog); draw_set_halign(fa_center); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_rp_x + _ind + _rtbox / 2, _ry + _rtbox / 2, "v");
                draw_set_halign(fa_left); draw_set_valign(fa_top);
                draw_set_color(make_color_rgb(140, 115, 90));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "5. Приготовить грушевое варенье");
                draw_line(_rp_x + _ind + _rtbox + _rtgap, _ry + _rp_lh * 0.5,
                          _rp_x + _rp_w, _ry + _rp_lh * 0.5);
            } else {
                draw_set_color(make_color_rgb(200, 80, 60));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, false);
                draw_set_color(make_color_rgb(160, 50, 30));
                draw_roundrect_ext(_rp_x + _ind, _ry, _rp_x + _ind + _rtbox, _ry + _rtbox, 2, 2, true);
                draw_set_font(fnt_dialog); draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_rp_x + _ind + _rtbox + _rtgap, _ry, "5. Приготовить грушевое варенье");
            }
        }
        break;
    case 2: // Растения
        draw_set_font(fnt_dialog);
        draw_set_color(make_color_rgb(80, 50, 20));

        // Морковь
        draw_sprite_ext(spr_carrot_icon, 0, content_x, content_y, 0.7, 0.7, 0, c_white, 1);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x + 26, content_y, "Морковь");
        draw_set_color(make_color_rgb(130, 100, 60));
        draw_text(content_x + 26, content_y + 18, "Время роста: 3 дня");

        // Картофель
        var _py = content_y + round(52 * bs);
        draw_sprite_ext(spr_potato_icon, 0, content_x, _py, 0.7, 0.7, 0, c_white, 1);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x + 26, _py, "Картофель");
        draw_set_color(make_color_rgb(130, 100, 60));
        draw_text(content_x + 26, _py + 18, "Время роста: 2 дня");

        // Клубника
        var _sy = _py + round(52 * bs);
        draw_sprite_ext(spr_strawberry_seed_icon, 0, content_x, _sy, 0.7, 0.7, 0, c_white, 1);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x + 26, _sy, "Клубника");
        draw_set_color(make_color_rgb(130, 100, 60));
        draw_text(content_x + 26, _sy + 18, "Время роста: 2 дня");

        draw_set_color(c_white);
        break;
    case 3: // Рецепты
        if (!_recipes_unlocked) {
            draw_set_font(fnt_dialog);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(book_x + book_w / 2, book_y + book_h / 2, "Рецепты пока недоступны");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            break;
        }

        // --- Карточка рецепта: Картофельный пирог ---
        var _rec_x = content_x;
        var _rec_y = content_y;

        // Название
        draw_set_font(fnt_dialog);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(_rec_x, _rec_y, "Картофельный пирог");

        // Разделитель
        draw_set_color(make_color_rgb(160, 120, 70));
        draw_line(_rec_x, _rec_y + round(22 * bs),
                  _rec_x + round(220 * bs), _rec_y + round(22 * bs));

        // Ингредиенты одной строкой
        draw_set_font(fnt_dialog);
        draw_set_color(make_color_rgb(80, 55, 25));
        draw_text(_rec_x, _rec_y + round(30 * bs),
                  "Картофель, Молоко, Яйцо, Мука, Дрожжи");

        // Кнопка "Подробнее"
        var _pbtn_w = round(90 * bs);
        var _pbtn_h = round(22 * bs);
        var _pbtn_x = _rec_x;
        var _pbtn_y = _rec_y + round(56 * bs);
        var _pbtn_hover = (device_mouse_x_to_gui(0) >= _pbtn_x && device_mouse_x_to_gui(0) <= _pbtn_x + _pbtn_w &&
                           device_mouse_y_to_gui(0) >= _pbtn_y && device_mouse_y_to_gui(0) <= _pbtn_y + _pbtn_h);

        draw_set_color(recipe_detail_open
            ? make_color_rgb(100, 65, 25)
            : (_pbtn_hover ? make_color_rgb(120, 80, 35) : make_color_rgb(160, 115, 60)));
        draw_roundrect_ext(_pbtn_x, _pbtn_y, _pbtn_x + _pbtn_w, _pbtn_y + _pbtn_h, 4, 4, false);
        draw_set_color(make_color_rgb(230, 200, 155));
        draw_roundrect_ext(_pbtn_x, _pbtn_y, _pbtn_x + _pbtn_w, _pbtn_y + _pbtn_h, 4, 4, true);
        draw_set_font(fnt_dialog);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(_pbtn_x + _pbtn_w / 2, _pbtn_y + _pbtn_h / 2,
                  recipe_detail_open ? "Свернуть" : "Подробнее");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // --- Рецепт кофе (после письма бабули) ---
        if (variable_global_exists("coffee_letter_read") && global.coffee_letter_read) {
            var _coffee_y = _pbtn_y + _pbtn_h + round(18 * bs);

            // Разделитель перед рецептом
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_rec_x, _coffee_y, _rec_x + round(220 * bs), _coffee_y);
            _coffee_y += round(10 * bs);

            // Название рецепта
            draw_set_font(fnt_dialog);
            draw_set_color(make_color_rgb(80, 50, 20));
            draw_text(_rec_x, _coffee_y, "Латте");

            // Линия под названием
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_rec_x, _coffee_y + round(22 * bs),
                      _rec_x + round(220 * bs), _coffee_y + round(22 * bs));

            // Ингредиенты
            draw_set_font(fnt_dialog);
            draw_set_color(make_color_rgb(80, 55, 25));
            draw_text(_rec_x, _coffee_y + round(30 * bs),
                      "Зерна кофе, Молоко, Сахар");
        }

        // --- Правая страница: детали рецепта ---
        if (recipe_detail_open) {
            var _det_x = book_x + round(288 * bs);
            var _det_y = book_y + round(20  * bs);
            var _det_w = book_w - round(288 * bs) - round(20 * bs);
            var _det_h = book_h - round(20  * bs) - round(38 * bs);

            draw_set_alpha(0.93);
            draw_set_color(make_color_rgb(250, 242, 220));
            draw_roundrect_ext(_det_x, _det_y, _det_x + _det_w, _det_y + _det_h, 6, 6, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_roundrect_ext(_det_x, _det_y, _det_x + _det_w, _det_y + _det_h, 6, 6, true);

            draw_set_font(fnt_dialog);
            draw_set_color(make_color_rgb(80, 50, 20));
            draw_text(_det_x + 12, _det_y + 12, "Картофельный пирог");
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_det_x + 10, _det_y + 34, _det_x + _det_w - 10, _det_y + 34);

            draw_set_font(fnt_dialog);
            draw_set_color(make_color_rgb(55, 35, 15));
            draw_text_ext(_det_x + 12, _det_y + 42,
                "Любимый пирог Джастина по рецепту бабушки Сони." +
                "\n\nИнгредиенты:" +
                "\nКартофель x1, Молоко x1, Яйцо x1" +
                "\nМука x1, Дрожжи x1" +
                "\n\nПриготовить: подойди к рабочему столу в пекарне и нажми E.",
                -1, _det_w - 22);
        }
        break;
    case 4: // Друзья
        draw_set_font(fnt_dialog);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x, content_y, "Бабушка Мэгги");

        // Кекс — появляется только после того как Мэгги привела котика
        if (!variable_global_exists("kitten_arrived")) global.kitten_arrived = false;
        if (global.kitten_arrived) {
            var _ky = content_y + 32;
            // Иконка сердечко
            draw_set_font(fnt_dialog);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(255, 80, 120));
            draw_text(content_x, _ky, "♥");
            // Имя и описание
            draw_set_font(fnt_dialog);
            draw_set_color(make_color_rgb(80, 50, 20));
            draw_text(content_x + 20, _ky, "Кекс");
            draw_set_color(make_color_rgb(120, 80, 40));
            draw_text(content_x + 20, _ky + 20, "Мой любимый друг");
        }
        break;
    case 5: // Приключения
        draw_set_font(fnt_dialog);
        draw_text(content_x, content_y, "Приключения скоро!");
        break;
    case 6: // Валюта
        // Иконка монеты
        draw_set_color(make_color_rgb(255, 210, 50));
        draw_circle(content_x + 12, content_y + 12, 11, false);
        draw_set_color(make_color_rgb(200, 155, 20));
        draw_circle(content_x + 12, content_y + 12, 11, true);
        draw_set_font(fnt_dialog);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(make_color_rgb(140, 90, 10));
        draw_text(content_x + 12, content_y + 12, "C");
        // Сумма
        draw_set_font(fnt_dialog);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x + 30, content_y + 4, "C — " + string(global.coins));
        break;
}

// Подсказка закрытия
draw_set_font(fnt_dialog);
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(150, 130, 110));
draw_text(book_x + book_w - 15, book_y + book_h - 20, "Клик вне книги - закрыть");

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
