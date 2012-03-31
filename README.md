# rtmidi-python

Python bindings for [RtMidi](http://www.music.mcgill.ca/~gary/rtmidi/).

## Setup

* Install [Cython](http://www.cython.org) 0.15 or later
* Run `python setup.py install`

This should work out of the box on Mac OS X and Linux with ALSA. With a few
changes to `setup.py`, if should also be possible to build the module on Linux
with JACK and Windows.

## Usage Examples

_rtmidi-python_ uses the same API as RtMidi, only reformatted to comply with
PEP-8, and with small changes to make it a little more pythonic.

### Print all output ports

    import rtmidi

    midi_out = rtmidi.MidiOut()
    for i in range(midi_out.get_port_count()):
        print midi_out.get_port_name(i)

### Send messages

    import rtmidi

    midi_out = rtmidi.MidiOut()
    midi_out.open_port(0)

    midi_out.send_message([0x90, 48, 100]) # Note on
    midi_out.send_message([0x80, 48, 100]) # Note off

### Get incoming messages by polling

    import rtmidi

    midi_in = rtmidi.MidiIn()
    midi_in.open_port(0)

    while True:
        message, delta_time = midi_in.get_message()
        if message:
            print message, delta_time

Note that the signature of `get_message()` differs from the original RtMidi
API: It returns a tuple instead of using a return parameter.

### Get incoming messages using a callback

    import rtmidi

    def callback(message, time_stamp):
        print message, time_stamp

    midi_in = rtmidi.MidiIn()
    midi_in.set_callback(callback)
    midi_in.open_port(0)

    # do something else here (but don't quit)

Note that the signature of the callback passed to `set_callback()` differs from
the original RtMidi API: `message` is now the first parameter, like in the
tuple returned by `get_message()`.

## License

_rtmidi-python_ is licensed under the MIT License, see `LICENSE`.
It uses RtMidi, licensed under a modified MIT License, see `RtMidi/RtMidi.h`.
