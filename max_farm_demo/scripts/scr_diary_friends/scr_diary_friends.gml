// ===== ДНЕВНИК: ДАННЫЕ ВКЛАДКИ "ДРУЖБА" =====

/// @func diary_get_friend_list()
/// @desc Список персонажей, с которыми Макс уже знаком.
/// Каждый: { id, name, short_desc, desc, portrait }. portrait = -1, если спрайта нет — рисуется цветной кружок.
function diary_get_friend_list() {
    var _list = [];

    array_push(_list, {
        id: "maggie",
        name: "Бабуля Мэгги",
        short_desc: "Старая подруга бабули",
        desc: "Бабуля Мэгги — давняя подруга бабушки.\n\nМакс хорошо её помнит, и у него к ней тёплые чувства — она ему тоже родная.",
        portrait: spr_grandma_maggie_portrait,
    });

    if (!variable_global_exists("kitten_arrived")) global.kitten_arrived = false;
    if (global.kitten_arrived) {
        array_push(_list, {
            id: "keks",
            name: "Кекс",
            short_desc: "Мой любимый друг",
            desc: "Кекс — котёнок, которого привела бабуля Мэгги.\n\nОн быстро стал любимцем всей семьи.",
            portrait: -1,
        });
    }

    return _list;
}
