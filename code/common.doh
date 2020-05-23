* ===========================================================================
* Global variables and preferences
* ===========================================================================


// --------------------------------------------------------------------------
// Settings
// --------------------------------------------------------------------------

	version 16
	clear all
	cap log close _all
	cap cls
	set more off
	set trace off
	set rmsg off
	set niceness 5 // 5 means "wait 1min before giving back memory to OS"
	set segmentsize 128m
	set varabbrev off // too many hidden errors otherwise
	set type double // -gen xyz- will default to -double- instead of -float-


// --------------------------------------------------------------------------
// Requirements
// --------------------------------------------------------------------------

	which gtools
	*which ftools
	*which reghdfe


// --------------------------------------------------------------------------
// Globals
// --------------------------------------------------------------------------

	global project_path		".."
	global input_path		"$project_path/input"
	global data_path        "$project_path/output/dta"
	global output_path		"$project_path/output/csv"


// --------------------------------------------------------------------------
// Extras
// --------------------------------------------------------------------------

	*cap set scheme s2color, permanently
