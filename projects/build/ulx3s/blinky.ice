algorithm main(
  output uint8 led,
  input  uint7 btn,
  output uint1 oled_clk,
  output uint1 oled_mosi,
  output uint1 oled_dc,
  output uint1 oled_resn,
  output uint1 oled_csn,  
  output uint1 sd_clk,
  output uint1 sd_csn,
  output uint1 sd_mosi,
  input  uint1 sd_miso
  )
{
  uint28 counter = 0;
  led := counter[20,8];
  while (1) {
    counter = counter + 1;
  }
}
