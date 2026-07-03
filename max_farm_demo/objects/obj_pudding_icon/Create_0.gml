if (!variable_global_exists("pudding_on_porch")) global.pudding_on_porch = false;

// Показываем спрайт только если пуддинг уже лежит на крыльце
visible = global.pudding_on_porch;
