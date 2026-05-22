// === ПОЧТОВЫЙ ЯЩИК (CREATE) ===

has_letter    = false;       // есть непрочитанное письмо?
current_letter = -1;         // структура текущего письма (или -1)
pending_action = "";         // действие после закрытия письма

// база писем
letter_db = letter_get_all();

// глобальный массив прочитанных ID
if (!variable_global_exists("letters_read")) {
    global.letters_read = [];
}
