# coding: utf-8

import subprocess
import argparse
import os.path
import os
import sys

###############################################################################

parser = argparse.ArgumentParser(prog="segger")
subparsers = parser.add_subparsers()

erase = subparsers.add_parser("erase", help="erase the flash")
erase.set_defaults(command="erase")

flash = subparsers.add_parser("flash", help="program the flash")
flash.set_defaults(command="flash")
flash.add_argument("program", help="binary file containing the program")

###############################################################################

command_line = ("LD_LIBRARY_PATH={path}:$LD_LIBRARY_PATH {path}/JLinkExe"
				.format(path=os.environ["JLINK_PATH"]))

def exec_jlinkexe(input_data):
	process = subprocess.Popen(command_line,
								stdin=subprocess.PIPE,
								stdout=subprocess.PIPE,
								stderr=subprocess.PIPE,
								shell=True)

	stdout, stderr = process.communicate(input_data)
	print stdout
	return process.returncode

###############################################################################

erase_script = """\
w4 4001e504 2
w4 4001e50c 1
w4 4001e514 1
r
q
"""

def erase():
	return exec_jlinkexe(erase_script)

###############################################################################

flash_script = """\
device nrf51822
speed 1000
w4 4001e504 1
loadbin {program} 0
r
g
q
"""

def flash(program):
	return exec_jlinkexe(flash_script.format(program=program))

###############################################################################

args = parser.parse_args().__dict__
command = args.pop("command")

status = globals()[command](**args)
sys.exit(status)
