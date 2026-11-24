// Целый пуддинг или пустая миска (последний кадр spr_pudding_eaten)
if (global.pudding_on_porch) draw_self();
else draw_sprite(spr_pudding_eaten, 4, x, y);
