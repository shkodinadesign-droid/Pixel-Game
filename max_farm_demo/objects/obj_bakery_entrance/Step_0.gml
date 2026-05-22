// Вход в пекарню
  var p = instance_nearest(x, y, obj_max);
  if (p != noone) {
      var foot_cx = (p.bbox_left + p.bbox_right) * 0.5;
      var foot_y  = p.bbox_bottom;
      if (point_distance(x, y, foot_cx, foot_y) < 96) {
          if (keyboard_check_pressed(ord("E"))) {
              global.return_spawn_x = p.x;
              global.return_spawn_y = p.y + 32;
              global.next_spawn_x   = 256;
              global.next_spawn_y   = 680;
              room_goto(rm_bakery);
          }
      }
  }
