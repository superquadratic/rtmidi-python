import distutils
import sys

if '--from-cython' in sys.argv:
    from Cython.Distutils import build_ext
    sys.argv.remove('--with-cython')
    module_source = 'rtmidi.pyx'
else:
    from distutils.command.build_ext import build_ext
    module_source = 'rtmidi.cpp'

extension_args = {}

if sys.platform.startswith('linux'):
    extension_args = dict(
        define_macros=[('__LINUX_ALSASEQ__', None)],
        libraries=['asound', 'pthread']
    )

if sys.platform == 'darwin':
    extension_args = dict(
        define_macros=[('__MACOSX_CORE__', None)],
        extra_compile_args=['-frtti'],
        extra_link_args=[
            '-framework', 'CoreMidi',
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
    'rtmidi',
    [module_source, 'RtMidi/RtMidi.cpp'],
    language='c++',
    **extension_args
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
