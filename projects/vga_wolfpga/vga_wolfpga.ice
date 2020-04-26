// SL 2020-04-24
// Wolf3D!
// see https://lodev.org/cgtutor/raycasting.html for principle
// or "Wolfenstien 3D black book" by Fabien Sanglard

$$texfile = 'wolf.tga'

$include('../common/video_sdram_main.ice')

$$FPw = 28
$$FPf = 10 -- fractions precision
$$FPm = 10 -- precision within cells

$$ ones = '' .. FPw .. 'b'
$$for i=1,FPw-1 do
$$ ones = ones .. '1'
$$end

$$div_width = FPw
$include('../common/divint_any.ice')

// -------------------------

algorithm frame_drawer(
  output uint23 saddr,
  output uint2  swbyte_addr,
  output uint1  srw,
  output uint32 sdata_in,
  output uint1  sin_valid,
  input  uint32 sdata_out,
  input  uint1  sbusy,
  input  uint1  sout_valid,
  input  uint1  vsync,
  output uint1  fbuffer
) {

  uint1  vsync_filtered = 0;

  bram uint8 texture[] = {   // texture from https://github.com/freedoom/freedoom
$$image_table(texfile)
  };
  
  bram uint10 columns[320];
  bram uint2  material[320];
  bram uint6  texcoord[320];

  bram int$FPw$ tan_f[$3600/4$] = {
    0,
$$for i=1,3600/4-3 do
    $math.floor(lshift(1,FPf) * math.tan(2*math.pi*i/3600))$,
$$  l = i
$$end
    $math.floor(lshift(1,FPf) * math.tan(2*math.pi*l/3600))$,
    $math.floor(lshift(1,FPf) * math.tan(2*math.pi*l/3600))$,
  };
  
  bram int$FPw$ sin_m[2048] = {
$$for i=0,2047 do
    $math.floor(lshift(1,FPm) * math.sin(2*math.pi*i/2048))$,
$$end
  };

  // table for vertical interpolation
  bram int20 hscr_inv[512]={
    1, // 0: unused
$$for hscr=1,511 do
    $math.floor(0.5 + 262144/hscr)$,
$$end
  };

$$Deg90  =  900
$$Deg180 = 1800
$$Deg270 = 2700
$$Deg360 = 3600
  
  uint3 level[$8*8$] = {
   4,3,4,3,4,3,4,3,
   1,0,0,0,4,0,0,2,
   2,0,0,0,0,0,0,1,
   1,1,0,0,0,0,2,2,
   2,2,0,0,0,0,1,1,
   1,0,0,0,0,0,0,2,
   2,0,0,0,4,0,0,1,
   4,3,4,3,4,3,4,3,
  };
  
  uint9 c      = 0;
  uint9 y      = 0;
  uint9 yw     = 0;
  uint9 h      = 0;
  uint8 palidx = 0;
  
  int$FPw$ posx_f  = $lshift(4,FPf)$;// + $lshift(1,FPf-1)$;
  int$FPw$ posy_f  = $lshift(4,FPf)$;// + $lshift(1,FPf-1)$;
  int$FPw$ hitx_f  = 0;
  int$FPw$ hity_f  = 0;
  int$FPw$ xstep_f = 0;
  int$FPw$ ystep_f = 0;
 
  int$FPw$ fracx_up_m = 0;
  int$FPw$ fracx_dw_m = 0;
  int$FPw$ fracy_up_m = 0;
  int$FPw$ fracy_dw_m = 0;
  int$FPw$ fracx_m    = 0;
  int$FPw$ fracy_m    = 0;

  int$FPw$ cosview_m  = 0;
  int$FPw$ sinview_m  = 0;

  int$FPw$ mapx     = 0;
  int$FPw$ mapy     = 0;
  int$FPw$ mapxstep = 0;
  int$FPw$ mapystep = 0;
  int$FPw$ mapxtest = 0;
  int$FPw$ mapytest = 0;
  
  int16    angle    = 0;

  int$FPw$ dist_f   = 0;
  int$FPw$ height   = 0;
  
  div$FPw$ div;
  
  uint3     hit       = 0;
  uint1     v_or_h    = 0;

  uint24  frame     = 900;
  uint24  viewangle = 0;
  
  uint20  v_tex      = 0;
  uint20  v_tex_incr = 0;
  
  vsync_filtered ::= vsync;

  sin_valid := 0; // maintain low (pulses high when needed)
  
  srw = 1;        // sdram write

  fbuffer = 0;
  
  sin_m.wenable    = 0;    
  tan_f.wenable    = 0;
  hscr_inv.wenable = 0;
  texture.wenable  = 0;
  
  while (1) {

    columns .wenable = 1;
    material.wenable = 1;
    texcoord.wenable = 1;
    
    viewangle = ((160 + frame) * $math.floor(2048*(2048/3600))$) >> 11;
    
    // get cos/sin view
    sin_m.addr = (viewangle) & 2047;
++:    
    sinview_m  = sin_m.rdata;
    sin_m.addr = (viewangle + 512) & 2047;
++:    
    cosview_m  = sin_m.rdata;

    // animate position
    sin_m.addr = (frame>>1)&2047;
++:
    posx_f  = $lshift(4,FPf) + lshift(1,FPf-1)$ + sin_m.rdata;

    // ray cast columns
    c = 0;
    while (c < 320) {
      
      // start cell 
      mapx       = (posx_f >> $FPf$);
      mapy       = (posy_f >> $FPf$);
      
      fracx_dw_m = (posx_f >> $FPf-FPm$) & $lshift(1,FPm)-1$;
      fracx_up_m = $lshift(1,FPm)$ - fracx_dw_m;      
      fracy_dw_m = (posy_f >> $FPf-FPm$) & $lshift(1,FPm)-1$;
      fracy_up_m = $lshift(1,FPm)$ - fracy_dw_m;      
      
      angle  = frame + c;
      while (angle < 0) {
        angle = angle + 3600;
      }
      while (angle > 3600) {
        angle = angle - 3600;
      }
      
      if (angle < $Deg90$) {
        mapxstep   =  1;
        mapystep   = -1;
        fracx_m    = fracx_up_m;
        fracy_m    = fracy_dw_m;
        tan_f.addr = $Deg90-1$-angle;
++:
        xstep_f    = tan_f.rdata;        
        tan_f.addr = angle;
++:
        ystep_f    = - tan_f.rdata;        
      } else {
        if (angle < $Deg180$) {
          mapxstep   = -1;
          mapystep   = -1;
          fracx_m    = fracx_dw_m;
          fracy_m    = fracy_dw_m;
          tan_f.addr = angle - $Deg90$;
++:
          xstep_f    = - tan_f.rdata;        
          tan_f.addr = $Deg180-1$-angle;
++:
          ystep_f    = - tan_f.rdata;        
        } else {
          if (angle < $Deg270$) {
            mapxstep   = -1;
            mapystep   =  1;
            fracx_m    = fracx_dw_m;
            fracy_m    = fracy_up_m;
            tan_f.addr = $Deg270-1$-angle;
++:
            xstep_f    = - tan_f.rdata;        
            tan_f.addr = angle - $Deg180$;
++:
            ystep_f    = tan_f.rdata;        
          } else {
            mapxstep   =  1;
            mapystep   =  1;
            fracx_m    = fracx_up_m;
            fracy_m    = fracy_up_m;
            tan_f.addr = angle-$Deg270$;
++:
            xstep_f    = tan_f.rdata;        
            tan_f.addr = $Deg360-1$-angle;
++:
            ystep_f    = tan_f.rdata;            
          }        
        }   
      }
      
      // first intersection
      hity_f = posy_f + ((fracx_m * ystep_f) >>> $FPm$);
      mapx   = mapx + mapxstep;
      
      hitx_f = posx_f + ((fracy_m * xstep_f) >>> $FPm$);
      mapy   = mapy + mapystep;
      
      // DDA wolfenstein-style main loop
      hit    = 0;
      v_or_h = 0; // 0: vertical (along x) 1: horizontal (along y)
      while (hit == 0) {
      
        mapxtest = hitx_f >>> $FPf$;
        mapytest = hity_f >>> $FPf$;
        
        // shall we do vertical or horizontal?
        if (v_or_h == 0) {
          // keep doing vertical?
          if (mapystep > 0 && mapytest >= mapy) {
            v_or_h = 1;
          }
          if (mapystep < 0 && mapytest <= mapy) {
            v_or_h = 1;
          }
        } else {
          // keep doing horizontal?
          if (mapxstep > 0 && mapxtest >= mapx) {
            v_or_h = 0;
          }
          if (mapxstep < 0 && mapxtest <= mapx) {
            v_or_h = 0;
          }        
        }

        // now advance 
        if (v_or_h == 0) {
          // check for a hit
          hit = level[(mapx&7) + (((mapytest)&7)<<3)];
          if (hit != 0) {
            if (mapxstep < 0) {
              hitx_f = (mapx+1) << $FPf$;
            } else {
              hitx_f = mapx << $FPf$;
            }
            break;
          }
          mapx   = mapx   + mapxstep;
          hity_f = hity_f + ystep_f;
        } else {
          // check for a hit
          hit = level[((mapxtest)&7) + ((mapy&7)<<3)];
          if (hit != 0) {
            if (mapystep < 0) {
              hity_f = (mapy+1) << $FPf$;
            } else {
              hity_f = mapy << $FPf$;
            }
            break;
          }
          mapy   = mapy   + mapystep;
          hitx_f = hitx_f + xstep_f;
        }
      }
      
      // distance
      dist_f = ((cosview_m * (hitx_f - posx_f))
             -  (sinview_m * (hity_f - posy_f))) >>> $FPf$;
      (height) <- div <- ($lshift(140,FPf)$,dist_f>>1);
      
      columns.addr   = c;
      columns.wdata  = height;
      material.addr  = c;
      material.wdata = hit-1;
      texcoord.addr  = c;
      if (v_or_h == 0) {
        texcoord.wdata = hity_f >>> $FPf-6$;
      } else {
        texcoord.wdata = hitx_f >>> $FPf-6$;
      }
      
      // write on loop
     
      c = c + 1;
    }
    
    // now draw columns
    c = 0;
    columns.wenable  = 0;
    material.wenable = 0;
    texcoord.wenable = 0;
    while (c < 320) {
      columns.addr  = c;
      material.addr = c;
      texcoord.addr = c;
++:
      if (columns.rdata < 100) {
        h = columns.rdata;
      } else {
        h = 99;        
      }
      hscr_inv.addr = columns.rdata & 511;
      v_tex = $lshift(32,13)$;
++:      
      v_tex_incr    = hscr_inv.rdata;  
      y = 0;
      while (y < 100) {
        // floor and bottom half
        if (y <= h) {
          texture.addr = ((texcoord.rdata + (material.rdata<<6)) & 255) + (((v_tex >> 13) & 63)<<8);
++:          
          palidx       = texture.rdata;
        } else {
          palidx = 22;  
        }
        // write to sdram
        yw = 100+y;
        while (1) {
          if (sbusy == 0) { // not busy?
            sdata_in    = palidx;
            saddr       = {~fbuffer,21b0} | ((c + (yw << 8) + (yw << 6)) >> 2); // * 240 / 4
            swbyte_addr = c & 3;
            sin_valid   = 1; // go ahead!
            break;
          }
        }          
        yw = 100-y;
        // floor and bottom half
        palidx = 22;  
        if (y <= h) {
          texture.addr = ((texcoord.rdata + (material.rdata<<6)) & 255) + ((63 - ((v_tex >> 13) & 63))<<8);
++:          
          palidx       = texture.rdata;
        } else {
          palidx = 2;
        }
        while (1) {
          if (sbusy == 0) { // not busy?
            sdata_in    = palidx;
            saddr       = {~fbuffer,21b0} | ((c + (yw << 8) + (yw << 6)) >> 2); // * 240 / 4
            swbyte_addr = c & 3;
            sin_valid   = 1; // go ahead!
            break;
          }
        }
        if (y <= h) {
          v_tex = v_tex + v_tex_incr;
        }
        y = y + 1;        
      }      
      c = c + 1;
    }    
    
    // prepare next frame
$$if SIMULATION then
    frame = frame + 100;
$$else
    frame = frame + 1;
$$end

    // wait for frame to end
    while (vsync_filtered == 0) {}

    // swap buffers
    fbuffer = ~fbuffer;

  }

}

// ------------------------- 
