package main

import (
	"fmt"
	"os"
	"github.com/godbus/dbus"
)

func main() {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to connect to system bus:", err)
		os.Exit(1)
	}
	defer conn.Close()

	var s string
	err = conn.Object("org.freedesktop.login1", "/org/freedesktop/login1").Call("org.freedesktop.login1.Manager.Inhibit", 0,"handle-lid-switch","root","Prevent hibernate/sleep when lid is closed","block").Store(&s)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to call Inhibit method", err)
		os.Exit(1)
	}

	fmt.Println("Lid switch disabled - You can close the lid without suspending your computer")
	fmt.Scanln()
}
