rtmidi-python
=============

Python wrapper for `RtMidi`_, the lightweight, cross-platform MIDI I/O
library. For Linux, Mac OS X and Windows.

Installation
------------

On Windows, the preferred way is to use one of the precompiled binaries
available from `PyPI`_. On Linux and Mac OS X, the easiest way to install
*rtmidi-python* is using pip::

    pip install rtmidi-python

Alternatively, you can build the module from source as follows::

    python setup.py install

If you want to build from the `Cython`_ source, make sure that you have a
recent version of Cython (>= 0.17), and run::

    python setup.py install --from-cython

Usage Examples
--------------

*rtmidi-python* uses the same API as `RtMidi`_, only reformatted to comply
with PEP-8, and with small changes to make it a little more pythonic.

Print all output ports
~~~~~~~~~~~~~~~~~~~~~~

::

    import rtmidi_python as rtmidi

    midi_out = rtmidi.MidiOut()
    for port_name in midi_out.ports:
        print port_name

Send messages
~~~~~~~~~~~~~

::

    import rtmidi_python as rtmidi

    midi_out = rtmidi.MidiOut()
    midi_out.open_port(0)

    midi_out.send_message([0x90, 48, 100]) # Note on
    midi_out.send_message([0x80, 48, 100]) # Note off

Get incoming messages by polling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    import rtmidi_python as rtmidi

    midi_in = rtmidi.MidiIn()
    midi_in.open_port(0)

    while True:
        message, delta_time = midi_in.get_message()
        if message:
            print message, delta_time

Note that the signature of ``get_message()`` differs from the original
`RtMidi`_ API: It returns a tuple instead of using a return parameter.

Get incoming messages using a callback
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    import rtmidi_python as rtmidi

    def callback(message, time_stamp):
        print message, time_stamp

    midi_in = rtmidi.MidiIn()
    midi_in.callback = callback
    midi_in.open_port(0)

    # do something else here (but don't quit)

Note that the signature of the callback differs from the original `RtMidi`_
API: ``message`` is now the first parameter, like in the tuple returned by
``get_message()``.

License
-------

*rtmidi-python* is licensed under the MIT License, see LICENSE.

It uses `RtMidi`_, licensed under a modified MIT License, see
RtMidi/RtMidi.h.

.. _RtMidi: http://www.music.mcgill.ca/~gary/rtmidi/
.. _PyPI: https://pypi.python.org/pypi/rtmidi-python#downloads
.. _Cython: http://www.cython.org
