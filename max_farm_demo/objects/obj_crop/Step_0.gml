// Скрываем зёрна вне фермы (persistent объект не уничтожается при смене комнаты)
visible = (room == rm_farm);

// Сбор урожая: нажать E рядом со зрелым растением — только ОДНО за нажатие
// current_time одинаков для всех экземпляров внутри одного шага →
// первый урожай записывает время, остальные видят совпадение и пропускают.
if (!variable_global_exists("last_harvest_time")) global.last_harvest_time = -1;

var _player = instance_find(obj_max, 0);
if (stage >= ready_index() && _player != noone
    && point_distance(x, y, _player.x, _player.y) < 48
    && keyboard_check_pressed(ord("E"))
    && global.last_harvest_time != current_time) {

    global.last_harvest_time = current_time;

    var _harvest_item = ITEM_CARROT;
    var _harvest_spr  = spr_carrot_icon;
    if (crop_type == "potato") {
        _harvest_item = ITEM_POTATO;
        _harvest_spr  = spr_potato_icon;
    } else if (crop_type == "strawberry") {
        _harvest_item = ITEM_STRAWBERRY;
        _harvest_spr  = spr_straberry_icon;
    }
    inventory_add(_harvest_item, 1);

    // Попап с иконкой собранного предмета
    var _hud = instance_find(obj_ui_inventory, 0);
    if (_hud != noone) with (_hud) show_item_pop(_harvest_spr, "+1");

    // очищаем клетку soil, чтобы можно было сажать снова
    if (soil_id != noone && instance_exists(soil_id)) {
        with (soil_id) clear_cell();
    }

    instance_destroy();
}

