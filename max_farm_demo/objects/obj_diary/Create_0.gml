// ===== DIARY CREATE =====

// Блокируем управление
global.control_locked = true;

audio_play_sound(snd_book_open, 1, false, 0.6);

// Текущая вкладка (0-6)
current_tab = 0;

// Масштаб дневника: подложка spr_diary_bg и элементы spr_ui_* рисуются 1:1 (книга 836x470), bs — множитель отступов
book_scale = 1.5;

// Размеры книги (GUI координаты) — по размеру спрайта подложки
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

book_w = sprite_get_width(spr_diary_bg);   // 836
book_h = sprite_get_height(spr_diary_bg);  // 470
book_x = round((gui_w - book_w) / 2);
book_y = round((gui_h - book_h) / 2);

// Разметка (пиксели подложки spr_diary_bg, замерены по арту) — общая для Draw_64 и Step
ui_tab_x0  = 64;   ui_tab_dx = 57;   ui_tab_y = 4;   // вкладки 50x48: x = ui_tab_x0 + i * ui_tab_dx
ui_tabs    = [];
for (var _ti = 0; _ti < 7; _ti++) ui_tabs[_ti] = [ui_tab_x0 + _ti * ui_tab_dx, ui_tab_y, ui_tab_x0 + _ti * ui_tab_dx + 50, ui_tab_y + 48];
ui_close   = [790, 14];                // кнопка-крестик 30x30 (левый верхний угол)
ui_title   = [236, 108];               // центр таблички с названием раздела
ui_sheet   = [455, 98, 750, 283];      // белый лист (сверху по центру — закладка до y 120)
ui_low     = [450, 298, 770, 390];     // свободное место под белым листом
ui_list    = [68, 136, 320, 254];      // карточки заданий/растений: x, y, ширина, высота области
ui_arrows  = [126, 326, 391];          // стрелки листания: x левой, x правой, y
ui_inv     = [97, 150, 48, 6];         // сетка инвентаря 5x4: x, y, ячейка, промежуток
ui_rcat    = [77, 138, 96, 8];         // кнопки категорий рецептов: x, y, ширина кнопки, промежуток
ui_rgrid   = [125, 172, 46, 8];        // сетка рецептов 4x4: x, y, ячейка, промежуток

// Табы: спрайты активной/неактивной вкладки по порядку разделов
tab_spr_active   = [spr_ui_tab_quests_active, spr_ui_tab_inventory_active, spr_ui_tab_recipes_active, spr_ui_tab_plants_active,
                    spr_ui_tab_adventures_active, spr_ui_tab_friendship_active, spr_ui_tab_money_active];
tab_spr_inactive = [spr_ui_tab_quests_inactive, spr_ui_tab_inventory_inactive, spr_ui_tab_recipes_inactive, spr_ui_tab_plants_inactive,
                    spr_ui_tab_adventures_inactive, spr_ui_tab_friendship_inactive, spr_ui_tab_money_inactive];

// Страница списка заданий
quest_page = 0;

// Выбранное растение во вкладке "Растения" (-1 = ничего)
selected_plant = -1;

// Названия вкладок
tab_names = ["Задания", "Инвентарь", "Рецепты", "Растения", "Приключения", "Дружба", "Деньги"];

// Выбранный предмет в инвентаре (-1 = ничего)
selected_item = -1;

// Выбранное задание во вкладке "Задания" ("" = ничего)
selected_quest = "";

// Вкладка "Рецепты": текущая категория и выбранный рецепт ("" = ничего)
recipe_category = "baking";
selected_recipe = "";

// Выбранный персонаж во вкладке "Дружба" ("" = ничего)
selected_friend = "";

// Отслеживание кликов
// true = пропускаем клик открытия, иначе дневник закроется в первом же кадре
_click_prev = true;

// Игрок открыл дневник — останавливаем прыжок (! остаётся, но не прыгает)
if (!variable_global_exists("diary_was_read")) global.diary_was_read = false;
global.diary_was_read = true;
