process_watchdog(proc, prms*) {
	if !processExist(proc)
		ShellRun(proc, prms*)
}
