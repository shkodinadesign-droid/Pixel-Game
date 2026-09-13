peck_timer--;

if (peck_timer <= 0 && !pecking) {
    pecking    = true;
    peck_frame = 0;
    peck_timer = room_speed * 3 + irandom(room_speed * 4);
}

if (pecking) {
    peck_frame++;
    // два клевка через синус — плавное опускание и подъём
    if (peck_frame < 8) {
        y = base_y + round(sin(peck_frame * pi / 8) * 3);
    } else if (peck_frame < 16) {
        y = base_y + round(sin((peck_frame - 8) * pi / 8) * 3);
    } else {
        y      = base_y;
        pecking = false;
    }
} else {
    y = base_y;
}
