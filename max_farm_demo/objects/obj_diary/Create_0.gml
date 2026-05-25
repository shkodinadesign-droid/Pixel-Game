// ===== DIARY CREATE =====

// Блокируем управление
global.control_locked = true;

// Текущая вкладка (0-6)
current_tab = 0;

// Масштаб дневника (1.0 = оригинал 549x302)
book_scale = 1.5;

// Размеры книги (GUI координаты)
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

book_w = round(549 * book_scale);  // ~686
book_h = round(302 * book_scale);  // ~378
book_x = (gui_w - book_w) / 2;
book_y = (gui_h - book_h) / 2 + 30;

// Размеры вкладок (масштабируются вместе с книгой)
tab_w       = round(40 * book_scale);  // 50
tab_h       = round(40 * book_scale);  // 50
tab_spacing = round(4  * book_scale);  // 5
var total_tabs_w = 7 * tab_w + 6 * tab_spacing;
tab_start_x = book_x + (book_w - total_tabs_w) / 2;

// Названия вкладок
tab_names = ["Инвентарь", "Задания", "Растения", "Рецепты", "Друзья", "Приключения", "Валюта"];

// Выбранный предмет в инвентаре (-1 = ничего)
selected_item = -1;

// Детальный вид рецепта в вкладке Рецепты
recipe_detail_open = false;

// Отслеживание кликов
// true = пропускаем клик открытия, иначе дневник закроется в первом же кадре
_click_prev = true;

// Игрок открыл дневник — останавливаем прыжок (! остаётся, но не прыгает)
if (!variable_global_exists("diary_was_read")) global.diary_was_read = false;
global.diary_was_read = true;
