// ===== DIARY CREATE =====

// Блокируем управление
global.control_locked = true;

audio_play_sound(snd_book_open, 1, false, 0.6);

// Текущая вкладка (0-6)
current_tab = 0;

// Масштаб дневника (1.0 = оригинал 549x302)
book_scale = 1.5;

// Размеры книги (GUI координаты)
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

book_w = round(549 * book_scale);  // ~824 (спрайт spr_diary_bg включает вкладки сверху)
book_h = round(302 * book_scale);  // ~453
book_x = (gui_w - book_w) / 2;
book_y = (gui_h - book_h) / 2;

// Названия вкладок
tab_names = ["Задания", "Инвентарь", "Рецепты", "Растения", "Приключения", "Дружба", "Деньги"];

// Выбранный предмет в инвентаре (-1 = ничего)
selected_item = -1;

// Выбранное задание во вкладке "Задания" ("" = ничего)
selected_quest = "";

// Вкладка "Рецепты": текущая категория и выбранный рецепт ("" = ничего)
recipe_category = "baking";
selected_recipe = "";

// Отслеживание кликов
// true = пропускаем клик открытия, иначе дневник закроется в первом же кадре
_click_prev = true;

// Игрок открыл дневник — останавливаем прыжок (! остаётся, но не прыгает)
if (!variable_global_exists("diary_was_read")) global.diary_was_read = false;
global.diary_was_read = true;
