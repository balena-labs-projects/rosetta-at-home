import dbus
import signal

# TODO: only do this if running on laptop
print("Disabling hibernation when laptop lid is closed")
try:
    bus = dbus.SystemBus()
    obj = bus.get_object('org.freedesktop.login1', '/org/freedesktop/login1')
    interface = dbus.Interface(obj, 'org.freedesktop.login1.Manager')
    fd = interface.Inhibit('handle-lid-switch','root','Prevent hibernate/sleep when lid is closed','block')
    print("Lid switch disabled - You can close the lid without suspending your computer")
except:
    print("Failed to run dbus-send command")

signal.pause()
