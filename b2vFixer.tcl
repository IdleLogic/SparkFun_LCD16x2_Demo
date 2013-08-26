#File:           	b2vFixer.tcl
#Author:         	Chris Zeh <Chris@idle-logic.com> 
#Website:			idle-logic.com
#Version:        	0.91b
#License			MIT License (http://www.opensource.org/licenses/mit-license.php)
# --------------------------------------------------------------------------------------------
#		Revision History
# --------------------------------------------------------------------------------------------
#	Version		Date		Comments
# --------------------------------------------------------------------------------------------
#	0.9b		06/07/12	Initial Release
#	0.91b		07/26/13	Added support to allow 'defparam' to be used
#								we are now using a string replace rather than
#								a reconstruction making the solution more 
#								robust, and lets us remove the get_inst_number
#								function					
# --------------------------------------------------------------------------------------------
#
#Purpose:        	
#	In order to prepare a project for ModelSim-ASE (Which doesn't allow
#	schematic top-level files, this tool converts and improves the Top-Level
#	Schematic (bdf) to Verilog conversion and prepares the project for
#	ModelSim.
#	Note: VHDL conversion not yet supported.
#
#Usage:
#	From the Quartus TCL Console:
#	tcl> source b2vFixer.tcl
#	tcl> b2v
#
#	You can also add "source b2vFixer.tcl"	to the project's .qsf file for it
#	to be included automatically to the project

#Global declarations:
set lModNames {}
set lModCount {}

	
# --------------------------------------------------------------------------------------------
#Function:	start_quartus_b2v
#Purpose:	Starts the native Quartus bdf to verilog tool. Checks to see if the top level has
#			already been converted by this tool, indicated by a _b2v suffix. The top-level 
#			file checking isn't robust yet since in Quartus there doesn't appear to be an easy
#			way to detect its file type.
#
#Inputs:	None. 
#			Resets the global static variables, lModNames & lModCount
#Returns:	Returns boolean success
# --------------------------------------------------------------------------------------------
proc start_quartus_b2v args {
	if {![is_project_open]} { 
		puts "No Project Open"
		return False
	}
	#Reset the Module List/Counter
	global lModNames
	global lModCount 
	set lModNames {}
	set lModCount {}
	
	#Check to see what the current toplevel is	
	set toplevel_name [get_global_assignment -name TOP_LEVEL_ENTITY]
	puts "Top-Level Detected: $toplevel_name"
		
	#See if it is already a "toplevel_b2v" Verilog File
	set suffix_test [string range $toplevel_name end-3 end]
	if {$suffix_test == "_b2v"} {
		puts "Top Level is already a converted schematic file"
		return False
	}
	
	#Kick off the Quartus b2v tool
	set toplevel_bdf "${toplevel_name}.bdf"
	set convert_arg "--convert_bdf_to_verilog=$toplevel_bdf"
	puts "Starting Quartus native b2v tool..."
	if {[catch {execute_module -tool map -args $convert_arg} result]} {
		puts "ERROR: Issue while converting. Check for Errors in the Messages Window.\n"
		return False
	} else {
		puts "...Completed successfully \n"
		
	}
	return True
}

# --------------------------------------------------------------------------------------------
#Function:	b2v
#Purpose:	Main Function call for this program. Initiates and manages the full b2v
#			and processing. 
#
#Inputs:	None. 			
#Returns:	Returns boolean success
# --------------------------------------------------------------------------------------------
proc b2v args {
	if {![is_project_open]} { 
		puts "No Project Open"
		return
	}
	#Start the Internal Quartus Schematic (bdf) to Verilog Converter
	puts "Converting Schematic Top-Level Entity to Verilog Top-Level"
	puts "*******************************************************************"

	if { ![start_quartus_b2v]} {
		return
	}
	
	set toplevel_name [get_global_assignment -name TOP_LEVEL_ENTITY]
	
	set module_name "module ${toplevel_name}("
	set new_module_name "module ${toplevel_name}_b2v("
	set b2vFile [open "${toplevel_name}_b2v.v" w]
	set File [open [file join [pwd] "${toplevel_name}.v"]]
	
	#We will traverse the Quartus Converted b2v file, and make our adjustments.
	#Swap the default b2v_inst0 names for an inst based on the module name so vJTAG_inst0
	#	Also keep track of the module names so we can deal with duplicates, so: vJTAG_inst1, vJTAG_inst2, and so on.
	#Also, we want to swap the module name to <toplevel>_b2v, which will allow the schematic file and the converted
	#	verilog file to remain in the project. Otherwise, you get an error w/ duplicate modules at compile time.
	#	This might slow down the compile process, so if we want to pull the bdf out of the project we can use
	#	set_global_assignment -name BDF_FILE ${toplevel_name}.bdf -remove
	
	puts "Starting Quartus b2v File Processing"
	puts "-------------------------------"
	puts "Top Level Modules Found:"
	puts "-------------------------------"
	
	#Retain the Last Instance Converted in order to handle the defparam's which come after an instance definition
	set lastInstanceName "" 
	
	foreach {i} [split [read $File] \n] {
		
		set mod_name [lindex [regexp -inline -all -- {\S+} $i] 0]
		set inst_name [lindex [regexp -inline -all -- {\S+} $i] 1]
		set inst_name_trunc [string range $inst_name 0 7]

		if {$inst_name_trunc == "b2v_inst"} then {
			
			if {$mod_name == "defparam"} then {
				set mod_name ${lastInstanceName}
			} else {
				set lastInstanceName ${mod_name}
				#Output the list of Modules Found
				puts "${mod_name}_inst"
			}
			#Replace the default b2v_inst name with something more informative
			set replacementText "${mod_name}_inst"
			set replacedLine [string map "b2v_inst $replacementText" ${i}]
			puts $b2vFile "${replacedLine}"
			
		} elseif {$i == $module_name} then {
			#Repalce the Module name with _b2v Suffix to avoid duplicate compilation collisions
			puts $b2vFile $new_module_name
			
		} else {
			#Write lines which don't need to be processed
			puts $b2vFile $i
		}

	}
	puts "-------------------------------"
	close $File
	close $b2vFile
	
	set_global_assignment -name VERILOG_FILE ${toplevel_name}_b2v.v
	set_global_assignment -name TOP_LEVEL_ENTITY ${toplevel_name}_b2v
	#set_global_assignment -name BDF_FILE ${toplevel_name}.bdf -remove
	
	puts "Schematic to Verilog Top-Level Conversion Complete:"
	puts "	${toplevel_name}_b2v.v added to the project"
	puts "	${toplevel_name}_b2v set as TOP_LEVEL_ENTITY"
}

#Indicate the file has been loaded:
puts "------------------------------------"
puts "b2vFixer.tcl Loaded:"
puts "b2v Command now available"
puts "------------------------------------"




# --------------------------------------------------------------------------------------------
# Copyright (c) 2013 Chris Zeh
#
# Released under the MIT License (MIT) (http://www.opensource.org/licenses/mit-license.php)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# --------------------------------------------------------------------------------------------