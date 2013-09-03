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

softdevice = subparsers.add_parser("softdevice", help="program the softdevice")
softdevice.set_defaults(command="softdevice")
softdevice.add_argument("uicr")
softdevice.add_argument("main")

###############################################################################

def exec_command_line(command_line, input_data=None):
	process = subprocess.Popen(command_line,
								stdin=subprocess.PIPE,
								stdout=subprocess.PIPE,
								stderr=subprocess.PIPE,
								shell=True)

	stdout, stderr = process.communicate(input_data)
	return process.returncode, stdout, stderr

jlinkexe_command_line = ("LD_LIBRARY_PATH={path}:$LD_LIBRARY_PATH "
					"{path}/JLinkExe".format(path=os.environ["JLINK_PATH"]))

def exec_jlinkexe(input_data):
	status, stdout, stderr = exec_command_line(jlinkexe_command_line,
												input_data)

	print stdout
	return status

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
loadbin {program} {addr}
r
g
q
"""

def flash(program):
	if os.environ["USE_SOFTDEVICE"] == "blank":
		addr = 0
	else:
		addr = 0x00014000

	return exec_jlinkexe(flash_script.format(program=program, addr=addr))

###############################################################################

softdevice_script = """\
device nrf51822
speed 1000
w4 4001e504 1
loadbin {uicr} 0x10001000
loadbin {main} 0
r
g
q
"""

def softdevice(uicr, main):
	return exec_jlinkexe(softdevice_script.format(uicr=uicr, main=main))

###############################################################################

args = parser.parse_args().__dict__
command = args.pop("command")

status = globals()[command](**args)
sys.exit(status)
