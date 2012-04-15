#!/usr/bin/env python

import time
import unittest

import rtmidi_python as rtmidi

class RtMidiTestCase(unittest.TestCase):

    NOTE_ON = [0x90, 48, 100]
    NOTE_OFF = [0x80, 48, 16]
    TEST_PORT_NAME = 'rtmidi test port'
    DELAY = 0.1

    def setUp(self):
        self.midi_out = rtmidi.MidiOut()
        self.midi_out.open_virtual_port(self.TEST_PORT_NAME)

        self.midi_in = rtmidi.MidiIn()
        self.midi_in.open_port(self.TEST_PORT_NAME)

    def tearDown(self):
        self.midi_in.close_port()
        self.midi_in = None
        self.midi_out.close_port()
        self.midi_out = None

    def test_send_and_get_message(self):
        self.midi_out.send_message(self.NOTE_ON)
        self.midi_out.send_message(self.NOTE_OFF)
        time.sleep(self.DELAY)
        incoming_message_1, _ = self.midi_in.get_message()
        incoming_message_2, _ = self.midi_in.get_message()
        self.assertEqual(incoming_message_1, self.NOTE_ON)
        self.assertEqual(incoming_message_2, self.NOTE_OFF)

    def test_callback(self):
        incoming_messages = []
        def callback(message, time_stamp):
            incoming_messages.append(message)
        self.midi_in.callback = callback
        self.midi_out.send_message(self.NOTE_ON)
        self.midi_out.send_message(self.NOTE_OFF)
        time.sleep(self.DELAY)
        self.assertEqual(incoming_messages, [self.NOTE_ON, self.NOTE_OFF])

        incoming_messages = []
        self.midi_in.callback = None
        self.midi_out.send_message(self.NOTE_ON)
        self.midi_out.send_message(self.NOTE_OFF)
        time.sleep(self.DELAY)
        self.assertEqual(incoming_messages, [])

if __name__ == '__main__':
    unittest.main()
