
//import std.stdio;
import gio.Application : GioApplication = Application;
import gtk.Application;
import designVisTool.mainWindow;

int main(string[] args)
{
    auto application = new Application("org.design.tools.vistool", GApplicationFlags.FLAGS_NONE);
    application.addOnActivate(delegate void(GioApplication app) { new MainWindow(application); });
    return application.run(args);
}
