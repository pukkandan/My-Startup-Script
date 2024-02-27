process_watchdog(spec) {
	if !processExist(spec.process)
		activateProgram(spec)
}
