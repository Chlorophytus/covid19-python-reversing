from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize
import os
import os.path

extensions: [Extension] = [
    Extension("covid19re.vectorize", ["covid19re/vectorize.pyx"], extra_compile_args=["-mavx2"])
]

setup(
    name="covid19re",
    version="0.1.0",
    author="Roland Metivier",
    author_email="metivier.roland@chlorophyt.us",
    description=("A COVID-19 reverse engineering workspace."),
    ext_modules=cythonize(extensions),
    license="Public Domain",
    packages=find_packages(),
    long_description=open("README.md", "r").read(),
)