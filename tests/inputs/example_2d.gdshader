// https://github.com/AlDanial/cloc/issues/641
shader_type canvas_item;

uniform float blue = 1.0; // you can assign a default value to uniforms

void vertex() {
  // Animate Sprite moving in big circle around its location
  VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
}

void fragment(){
    // this shader will result in an more bluish sprite
    COLOR = texture(TEXTURE, UV); //read from texture
    COLOR.b = blue; //set blue channel to <blue>
}
