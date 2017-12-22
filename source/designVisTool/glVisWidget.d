module designVisTool.glVisWidget;

import std.string;
import std.stdio;
import std.conv;

import gtk.Widget;
import gdk.Event;

import gtk.GLArea;
import gdk.GLContext;
import gdk.FrameClock;

import designVisTool.gl;
import designVisTool.glEntityDisks;

class glVisWidget : GLArea
{


  GLContext con;  
  long last_render_frame_time;
  long framerate_max;

  glDisks entity_disks;

  struct state_t{
    float [2] window_wh; // px
  };

  state_t state;

public:
  this()
  {
    setAutoRender(true);

    //last_render_frame_time = 0;
    //framerate_max = 1000000 / 30;

    addOnCreateContext(&initGL);    

    addOnRealize(&realize);
    addOnUnrealize(&unrealize);

    addOnRender(&render);

    addOnResize(&onResize);
    
    addOnButtonPress(&onButtonPress);
    addOnButtonRelease(&onButtonRelease);

    addOnMotionNotify(&onMouseMove);
    // mouse button 
    // addTickCallback (&tickCallback);
    // scroll
    addOnScroll(&onScroll);

    showAll();
  }

  GLContext initGL(GLArea area) {
      DerelictGL3.load();

      GLContext context;
      context = area.getWindow().createGlContext();
      context.realize();
      context.makeCurrent();
      DerelictGL3.reload();

      con = context; // saves the earth!

      version(console){
        writeln("init gl ok");
        writefln("Vendor:   %s",   to!string(glGetString(GL_VENDOR)));
        writefln("Renderer: %s",   to!string(glGetString(GL_RENDERER)));
        writefln("Version:  %s",   to!string(glGetString(GL_VERSION)));
        writefln("GLSL:     %s\n", to!string(glGetString(GL_SHADING_LANGUAGE_VERSION)));
      }

      return context;
  }

  void realize(Widget w)
  {
    makeCurrent();
    entity_disks.realize();
    //entity2.realize();

    version(console) writeln("realize gl ok");
  }

  void unrealize(Widget w)
  {
    makeCurrent();
    entity_disks.unrealize();
    //entity2.unrealize();
    version(console) writeln("unrealize gl ok");
  }

  /+
  bool tickCallback(Widget w, FrameClock fc){
    auto this_frame_time = fc.getFrameTime();

    if ( this_frame_time - last_render_frame_time > framerate_max){
      // animation state advance
      // min frame max frame 
      // speed

      queueDraw();

      last_render_frame_time = this_frame_time;

    }
    return true;
  }
  +/

  bool render(GLContext c, GLArea a)
  {

    if (c is null) return true;
    c.makeCurrent();
    //updateEntitiesState();
    //version(console) writeln("render");

    glClear (GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glViewport (0, 0, state.window_wh[0].to!int, state.window_wh[1].to!int);
    glClearColor (0.1, 0.5, 0.5, 1.0); // bg color
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


    // alpha blending works!
    //entity2.m_shader_params.border_size = 1.0;
    entity_disks.m_shader_params.screen_wh = state.window_wh;
    entity_disks.render(); 
    
    //glFlush();

    return true;
  }

  void onResize( int width,  int height, GLArea glarea){
    //version(console){ writeln("resize");}
    state.window_wh = [width, height];
  }

  /+
  bool resizeGL(Event event = null) {
      GLfloat w;
      GLfloat h;

      if ( event is null || event.type != GdkEventType.CONFIGURE ) 
      {
        w = getWidth();
        h = getHeight();
      } 
      else 
      {
        w = event.configure.width;
        h = event.configure.height;
      }

      width = w;
      height = h;

      glViewport (0, 0, cast(int)w, cast(int)h); //Adjust the viewport according to new window dimensions 

      return true;
  }
  +/

  bool onButton(Event ev, Widget w){

    version(console){
      //writeln("Mouse scroll event in scene.");
      writeln("button ", ev.button.type);
    }
    
    return true;
  }

  bool onButtonPress(Event ev, Widget w){

    if (ev.type == EventType.BUTTON_PRESS){
      version(console) writeln("button P ", ev.button.type);
      // writeln("Mouse scroll event in scene.");
      // save_xy
      // drag = true
    }
    
    return true;
  }

  bool onButtonRelease(Event ev, Widget w){
    version(console) writeln("button R ", ev.button.type);

    // drag = false
    
    return true;
  }


  bool onScroll(Event ev, Widget w){

    version(console){
      //writeln("Mouse scroll event in scene.");
      writeln("scroll ", ev.scroll.direction);
    }
    
    return true;
  }

  bool onMouseMove(Event ev, Widget widget) {
    //if  ( ev.type != EventType.MOTION_NOTIFY ) return true;
    version(console){
      //writeln("Mouse move event in scene.");
      writefln("pos (%d,%d) ", ev.motion.x.to!int, ev.motion.y.to!int);
      //if (drag == true) drag_delta = pos - start_drag_pos;
    }
    
    return true;
  }

}

