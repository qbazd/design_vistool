module designVisTool.mainWindow;

import stdlib = core.stdc.stdlib : exit;
import core.thread;
import core.memory;

import std.random;
import std.string;
import std.stdio;
import std.path;


import gtk.Version;
import gtk.Table;

import gdk.Threads;
import gdk.Event;
import gio.Application : GioApplication = Application;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Adjustment;
import gtk.AccelGroup;

import gtk.MenuItem;
import gtk.Widget;
import gtk.MenuBar;
import glib.Timeout;
import glib.Idle;

/+
import gtk.Notebook;
import gtk.ComboBoxText;
import gtk.FontSelectionDialog;
import gtk.ColorSelectionDialog;
import gtk.MessageDialog;
import gtk.Frame;
import gtk.HButtonBox;
import gtk.Statusbar;
import gtk.HandleBox;
import gtk.Toolbar;
import gtk.SeparatorToolItem;
import gtk.ToolButton;
import gtk.RadioButton;
import gtk.CheckButton;
import gtk.ToggleButton;
import gtk.Arrow;
import gtk.ButtonBox;
import gtk.Calendar;
import gtk.VButtonBox;
import gtk.SpinButton;
import gtk.ListStore;
import gtk.TreeIter;
import gtk.TreeView;
import gtk.TreeViewColumn;
import gtk.CellRendererText;
import gtk.Window;

import gtk.ScrolledWindow;

import glib.ListSG;

import glib.Str;
import gtk.Label;
import glib.ListG;
import gtk.Paned;
import gtk.HPaned;
import gtk.VPaned;

import gtk.Calendar;
import gtk.VButtonBox;
import gtk.FileChooserButton;


import gtk.TreeStore;
import gdk.Pixbuf;
import gtk.ComboBox;

import gtk.TreePath;
import gtk.CellRenderer;
import gtk.CellRendererPixbuf;
+/

import gtk.Menu;
import gtk.HBox;
import gtk.FileFilter;
import gtk.VBox;
import gtk.Dialog;
import gtk.DrawingArea;
import gtk.HScale;
import gtk.Button;
import gtk.FileChooserDialog;
import gtk.AboutDialog;
import gtk.MessageDialog;


import design_io;
import designVisTool.glVisWidget;

class designVisToolController{

  enum playMode {Stop, PlayForward, PlayBackward};

  playMode pMode = playMode.Stop;

  DataSet ds;
  DiskVisualizator dsv;

  int frameId = 0;
  int frameMin = 0;
  int frameMax = 1000;

  void importDataset(string datasetFile){
    auto ds = new DataSet(datasetFile);
    dsv = new DiskVisualizator(ds);
    frameId = 0;
    frameMin = 0;
    frameMax = cast(int)ds.timesteps.length -1;
    playStop();
  }

  void closeDataset(){
    frameId = 0;
    frameMin = 0;
    frameMax = 1;
  }

  void playStop(){
    pMode = playMode.Stop;
  }

  void playForward(){
    pMode = playMode.PlayForward;
  }

  void playBackward(){
    pMode = playMode.PlayBackward;
  }

  void playForwardTogle(){
    if (pMode == playMode.PlayForward)
      pMode = playMode.Stop;
    else
      pMode = playMode.PlayForward;
  }

  void playBackwardTogle(){
    if (pMode == playMode.PlayBackward)
      pMode = playMode.Stop;
    else 
      pMode = playMode.PlayBackward;
  }

  void frameUpdate(){
    if (!isOpen) return;
    if (pMode == playMode.Stop){

    } else {
      if (pMode == playMode.PlayForward){
        frameId ++;
        if (frameId > frameMax) frameId = frameMin;
      } else 
      if (pMode == playMode.PlayBackward){
        frameId --;
        if (frameId < frameMin) frameId = frameMax;
      }
    }

    //writeln(
    //dsv.getFrame(timesteps[frameId]);
    //);

    // debug(trace) writeln(frameId);
  }

  bool isOpen(){
    return dsv ! is null;
  }

}

class MainWindow : ApplicationWindow
{

  Adjustment timestep_adj;
  bool timestep_adj_updatable = true;
  HScale timestep_hscale;

  glVisWidget glvis;
  designVisToolController dvtc;
  Timeout animationUpdateTimeout;

  /**
   * Executed when the user tries to close the window
   * @return true to refuse to close the window
   */
  int windowDelete(GdkEvent* event, Widget widget)
  {

    debug(events) writeln("TestWindow.widgetDelete : this and widget to delete %X %X",this,window);
    MessageDialog d = new MessageDialog(
                    this,
                    GtkDialogFlags.MODAL,
                    MessageType.QUESTION,
                    ButtonsType.YES_NO,
                    "Are you sure you want' to exit these GtkDTests?");
    int responce = d.run();
    if ( responce == ResponseType.YES )
    {
      stdlib.exit(0);
    }
    d.destroy();
    return true;
  }

  void anyButtonExits(Button button)
  {
      stdlib.exit(0);
  }

  this(Application application)
  {
    super(application);
    setTitle("DESIgn visualistion tool");
    setup();
    resize (800, 800);
    showAll();
  }

  void setup()
  {

    dvtc = new designVisToolController();
    
    VBox mainBox = new VBox(false,0);
    mainBox.packStart(getMenuBar(),false,false,0);

    // opengl area
    glvis = new glVisWidget();
    mainBox.packStart(glvis,true,true,0);

    //DrawingArea dar = new DrawingArea();
    //dar.setSizeRequest(400,400);
    //mainBox.packStart(dar,true,true,0);

    {
      HBox controlsBox = new HBox(false,0);
      Button left = new Button("<<", delegate(Button) { dvtc.playBackwardTogle; });
      Button right = new Button(">>", delegate(Button) { dvtc.playForwardTogle; });


      timestep_adj = new Adjustment(0.0, 0.0, 100.0, 1.0, 1.0, 1.0);
      timestep_adj.addOnValueChanged(delegate(Adjustment a) {if(timestep_adj_updatable == false ) dvtc.frameId = cast(int)a.getValue(); });

      timestep_hscale = new HScale(timestep_adj);
      timestep_hscale.setSizeRequest(200,-1);

      timestep_hscale.addOnButtonPress(delegate(Event e, Widget w)  {timestep_adj_updatable = false ; return false;} );
      timestep_hscale.addOnButtonRelease(delegate(Event e, Widget w)  {dvtc.frameId = cast(int)timestep_adj.getValue(); timestep_adj_updatable = true ;return false;} );
      timestep_hscale.setDigits(0);

      controlsBox.packStart(left,false,false,0);      
      controlsBox.packStart(timestep_hscale,true,true,0);
      controlsBox.packStart(right,false,false,0);

      mainBox.packStart(controlsBox,false,false,0);
    }


    //Statusbar statusbar = new Statusbar();
    //mainBox.packStart(statusbar,false,true,0);
    add(mainBox);

    animationUpdateTimeout =  new Timeout(1000/60, delegate() { dvtc.frameUpdate(); updateGui(); return true; }, true);

  }

  void updateGui(){
    if (!dvtc.isOpen) return;
    if (!glvis.realized) return;

    if (timestep_adj_updatable){
      timestep_adj.configure(dvtc.frameId, dvtc.frameMin, dvtc.frameMax, 1.0, 1.0, 1.0);
    }
    // update time_label
   
    //writeln(far.length/4);
    //writeln(dvtc.dsv.ds.timesteps.length);
    //writeln(dvtc.dsv.ds.timesteps[dvtc.frameId] );
    auto far = dvtc.dsv.getFrame(dvtc.dsv.ds.timesteps[dvtc.frameId]);
    //writeln(far[0..16]);
    //assert(far !is  null);
    //assert(glvis.gl_disks !is null);
    glvis.gl_disks.update_geometry(far);
    
    glvis.queueDraw();
  }

  MenuBar getMenuBar()
  {

    AccelGroup accelGroup = new AccelGroup();

    addAccelGroup(accelGroup);

    MenuBar menuBar = new MenuBar();

    Menu menu;

/+
    menu = menuBar.append("_File");
    MenuItem item = new MenuItem(&onMenuActivate, "_New","file.new", true, accelGroup, 'n');
    item.addAccelerator("activate",accelGroup,'n',GdkModifierType.CONTROL_MASK,GtkAccelFlags.VISIBLE);
    menu.append(item);

    menu.append(new MenuItem(&onMenuActivate, "_Open","file.open", true, accelGroup, 'o'));
    menu.append(new MenuItem(&onMenuActivate, "Save","file.save", true, accelGroup, 's',GdkModifierType.CONTROL_MASK));
    menu.append(new MenuItem(&onMenuActivate, "Save As","file.save", true, accelGroup, 's',GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK));
    menu.append(new MenuItem(&onMenuActivate, "_Close","file.close", true, accelGroup, 'c'));
    menu.append(new MenuItem(&onMenuActivate, "E_xit","file.exit", true, accelGroup, 'x'));
+/
    menu = menuBar.append("_Edit");
    menu.append(new MenuItem(&onMenuActivate,"Import Dataset","edit.import", true, accelGroup, 'i'));
    menu.append(new MenuItem(&onMenuActivate,"Visuals","edit.visuals", true, accelGroup, 'v'));
//    menu.append(new MenuItem(&onMenuActivate,"Movie Sequence","edit.move_sequence", true, accelGroup, 'm'));

    menu = menuBar.append("_Help");
    menu.append(new MenuItem(&onMenuActivate,"_About","help.about", true, accelGroup, 'a',GdkModifierType.CONTROL_MASK|GdkModifierType.SHIFT_MASK));

    return menuBar;
  }

  void onMenuActivate(MenuItem menuItem)
  {
    string action = menuItem.getActionName();
    switch( action )
    {
      case "edit.import":
        showFileChooser();
        break;

      case "file.exit":
        destroy();
        break;

      case "help.about":
        GtkDAbout dlg = new GtkDAbout();
        dlg.addOnResponse(&onDialogResponse);
        dlg.showAll();
        break;

      default:
        MessageDialog d = new MessageDialog(
          this,
          GtkDialogFlags.MODAL,
          MessageType.INFO,
          ButtonsType.OK,
          "You pressed menu item "~action);
        d.run();
        d.destroy();
      break;
    }

  }

  void onDialogResponse(int response, Dialog dlg)
  {
    if(response == GtkResponseType.CANCEL)
      dlg.destroy();
  }

  class GtkDAbout : AboutDialog
  {
    this()
    {
      string[] names;
      names ~= "Antonio Monteiro (binding/wrapping/proxying/decorating for D)";
      names ~= "www.gtk.org (base C library)";

      setAuthors( names );
      //setDocumenters( names );
      //setArtists( names );

      setLicense("License is LGPL");
      setWebsite("http://lisdev.com");
    }
  }

  FileChooserDialog fcd;
  
  void showFileChooser()
  {

    if ( fcd  is  null )
    {
      string[] a;
      ResponseType[] r;

      a ~= "Lets go!";
      a ~= "Please don't";
      r ~= ResponseType.OK;
      r ~= ResponseType.CANCEL;

      fcd = new FileChooserDialog("File Chooser", this, FileChooserAction.OPEN, a, r);
      fcd.setSelectMultiple(false);

      auto f = new FileFilter();

      f.addPattern("*.const");
      f.setName("[model_run].0.const");
      fcd.addFilter(f);
    }

  
    if(fcd.run() == ResponseType.OK){
      //writefln("file selected = %s",fcd.getFilename());
      auto filename = dirName(fcd.getFilename()) ~ "/" ~ baseName(fcd.getFilename(), ".0.const");
      //dataset = new DataSet();

      dvtc.importDataset(filename);
      // dvtc.openDataset(filename);
      // Idle(buffer_refiller);

      GC.collect();

      //writeln(dataset.features);
    }

    fcd.hide();
  }


}
