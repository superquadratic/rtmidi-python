import distutils
import sys

from Cython.Distutils import build_ext

define_macros = []
libraries = []
extra_compile_args = []
extra_link_args = []

if sys.platform.startswith('linux'):
    define_macros = [('__LINUX_ALSASEQ__', None)]
    libraries = ['asound', 'pthread']

if sys.platform == 'darwin':
    define_macros = [('__MACOSX_CORE__', None)]
    extra_compile_args = ['-frtti']
    extra_link_args = [
        '-framework', 'CoreMidi',
        '-framework', 'CoreAudio',
        '-framework', 'CoreFoundation'
    ]

rtmidi_module = distutils.extension.Extension(
    'rtmidi',
    ['rtmidi.pyx', 'RtMidi/RtMidi.cpp'],
    language='c++',
    define_macros=define_macros,
    libraries=libraries,
    extra_compile_args=extra_compile_args,
    extra_link_args=extra_link_args
)

distutils.core.setup(
    name='rtmidi-python',
    version='0.1',
    description='Python bindings for RtMidi.',
    author='Guido Lorenz',
    author_email='code@superquadratic.net',
    url='https://github.com/superquadratic/rtmidi-python/',
    cmdclass={'build_ext': build_ext},
    ext_modules=[rtmidi_module],
    license='MIT',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Programming Language :: Cython',
        'Topic :: Multimedia :: Sound/Audio :: MIDI',
        'License :: OSI Approved :: MIT License'
    ]
)
