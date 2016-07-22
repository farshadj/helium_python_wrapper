from distutils.core import setup, Extension
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy


# define the extension module
helium = Extension('he', 
	sources=['he.pyx'],
	include_dirs=['/usr/include/',numpy.get_include()], #change this if your environment is different
	extra_link_args=['-lhe','-lpthread'],
	extra_compile_args=['-lhe','-lpthread']
)

# run the setup
setup(
    ext_modules=cythonize([helium]))
