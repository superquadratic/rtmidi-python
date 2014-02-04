import distutils
import sys

if '--from-cython' in sys.argv:
    from Cython.Distutils import build_ext
    sys.argv.remove('--from-cython')
    module_source = 'rtmidi_python.pyx'
else:
    from distutils.command.build_ext import build_ext
    module_source = 'rtmidi_python.cpp'

extension_args = {}

if sys.platform.startswith('linux'):
    extension_args = dict(
        define_macros=[('__LINUX_ALSA__', None)],
        libraries=['asound', 'pthread']
    )

if sys.platform == 'darwin':
    extension_args = dict(
        define_macros=[('__MACOSX_CORE__', None)],
        extra_compile_args=['-frtti'],
        extra_link_args=[
            '-framework', 'CoreMIDI',
            '-framework', 'CoreAudio',
            '-framework', 'CoreFoundation'
        ]
    )

if sys.platform == 'win32':
    extension_args = dict(
        define_macros=[('__WINDOWS_MM__', None)],
        libraries=['winmm']
    )

rtmidi_module = distutils.extension.Extension(
    'rtmidi_python',
    [module_source, 'RtMidi/RtMidi.cpp'],
    language='c++',
    **extension_args
)

distutils.core.setup(
    name='rtmidi-python',
    version='0.2.2',
    description='Python wrapper for RtMidi',
    long_description=open('README.rst').read(),
    author='Guido Lorenz',
    author_email='code@superquadratic.net',
    url='https://github.com/superquadratic/rtmidi-python',
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
