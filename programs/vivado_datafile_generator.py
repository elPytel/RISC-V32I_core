# By Pytel

DESCRIPTION = """
Aplication for generating COE, RAW and MEM files. 
For VHDL ROM initialization. \n
Specific types: \n
- COE file is used for Xilinx Vivado block ram IP core. \n
- MEM file is used for block ram. \n
- RAW file is used for loading program into FPGA memory from SD card.
"""

import os
import sys
import argparse
from my_colors import *

# import enum
from enum import Enum, auto

class FileFormat(Enum):
    COE = auto()
    MEM = auto()

VERBOSE = True

def generate_coe_file(input, output, radix):
    print(Green + "Generating COE file from: " + Blue + input +  NC +" to: "+ Blue + output + NC)
    input_file_format = input.split('.')[-1]
    with open(input, "r") as source, open(output, "w") as dest:
        dest.write(
            "memory_initialization_radix=" + str(radix) + ";\n" + 
            "memory_initialization_vector=\n")
        if input_file_format == "txt":
            parse_text_file(source, dest)
        else:
            raise Exception(Red + "Unsupported file format!" + NC)
    print(Green + "Done!" + NC)

def generate_mem_file(input, output):
    print(Green + "Generating MEM file from: " + Blue + input +  NC +" to: "+ Blue + output + NC)
    input_file_format = input.split('.')[-1]
    with open(input, "r") as source, open(output, "w") as dest:
        dest.write(
            "@00000000\n")
        if input_file_format == "txt":
            lines = source.readlines()
            for line in lines:
                dest.write(line)
        else:
            raise Exception(Red + "Unsupported file format!" + NC)
    print(Green + "Done!" + NC)

def generate_raw_file(input, output):
    print(Green + "Generating RAW file from: " + Blue + input +  NC +" to: "+ Blue + output + NC)
    input_file_format = input.split('.')[-1]
    with open(input, "r") as source, open(output, "w") as dest:
        if input_file_format == "txt":
            lines = source.readlines()
            # remove new line character
            lines = [line.strip('\n') for line in lines]
            # wite all on single line
            dest.write("".join(lines))
        else:
            raise Exception(Red + "Unsupported file format!" + NC)
    print(Green + "Done!" + NC)

def parse_text_file(source, dest):
    # last line without comma
    lines = source.readlines()
    for line in lines[:-1]:
        dest.write(line.strip('\n') + ",\n")
    # last line
    dest.write(lines[-1].strip('\n') + ";")
    return dest

def main(argv):
    parser = argparse.ArgumentParser(description=DESCRIPTION)
    parser.add_argument("-i", "--input", help="input file", required=True)
    parser.add_argument("-o", "--output", help="output file", required=False, default="output.coe")
    parser.add_argument("-r", "--radix", help="radix", required=False, default=16)
    parser.add_argument("-f", "--format", help="file format", required=False)
    
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        raise Exception(Red + "Input file does not exist!" + NC)

    if args.format is None:
        args.format = args.output.split('.')[-1]
        if VERBOSE:
            print("Format not specified, using format from output file: " + Blue + args.format + NC)

    # file format to lower case
    if args.format.lower() == "coe":
        generate_coe_file(args.input, args.output, args.radix)
    elif args.format.lower() == "mem":
        generate_mem_file(args.input, args.output)
    elif args.format.lower() == "raw":
        generate_raw_file(args.input, args.output)
    else:
        raise Exception(Red + "Unsupported file format!" + NC)

if __name__ == '__main__':
    try:
        main(sys.argv[1:])
    except Exception as e:
        print(e)
        sys.exit(1)
    