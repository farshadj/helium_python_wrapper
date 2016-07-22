# Welcome to the helium_python_wrapper wiki!

## Version: 
* V1.0 First version Farshad Javadi 22 Jul 2015

## Implementation:
* This wrapper is implemented using Cython. The wrapper is a like-to-like implementation of helium c and helium manual can be easilly applied to the python implementation. All functions name and input/output arguments are identical to helium base. The only notable change is the implementation of he_item. he_item is defined as class and need to be initiated like below example: 
	item=he_item()
	item.key=bytearray("some key".unicode('utf-8'))
	item.key_len=8
	item.val=bytearray("some value".unicode('utf-8'))
	item.val_len=11
	
* Python Buffer Protocol is implemented to minimize memory copy when passing data from/to C api. For example, item key, val buffers are shared with helium C. 


## Important Files:
* che.pxd: helium.h is redefined as C API in this file. This is almost identical to helium he.h file with minor 	  modifications. Cython is the language of the script. 
* he.pyx: This file is the implementation of helium wrapper. Cython is the language of the script. 
* setup.py: Configuration file to build extension (.so file in Mac). File may need to change for different environment.  
* build_extension.sh: Script to build so extension
* system_test.py: Script to test the library. 
* system_test_result.txt: Output of system_test.py

## How to build extension: 
* Simply run ./build_extension.sh. If failed, change paths at setup.py.
* Cython is needed for building the extension.  

## How to test 

Two ways to generate
### Unit Testing

Unit testing files are written to test some important methods and system. To unittest System run: 
run  "python -m unittest test/test_system.py" in test folder

### Test_System script
run python system_test.sh.

## How to include in your Python project
build extension first.
run ./build_extension.sh.