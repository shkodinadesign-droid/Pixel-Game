depth = -bbox_bottom;

if (obj_max.y < y) {
    image_alpha = 0.5; // крыша становится прозрачной
} else {
    image_alpha = 1;   // крыша снова нормальная
}