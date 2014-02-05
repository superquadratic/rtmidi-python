from cython.operator import dereference

from libcpp.string cimport string
from libcpp.vector cimport vector


# Init Python threads and GIL, because RtMidi calls Python from native threads.
# See http://permalink.gmane.org/gmane.comp.python.cython.user/5837
cdef extern from "Python.h":
    void PyEval_InitThreads()

PyEval_InitThreads()


cdef extern from "RtMidi/RtMidi.h":
    ctypedef void (*RtMidiCallback)(double timeStamp, vector[unsigned char]* message, void* userData)

    enum Api "RtMidi::Api":
        UNSPECIFIED "RtMidi::UNSPECIFIED"

    cdef cppclass RtMidi:
        void openPort(unsigned int portNumber)
        void openVirtualPort(string portName)
        unsigned int getPortCount()
        string getPortName(unsigned int portNumber)
        void closePort()

    cdef cppclass RtMidiIn(RtMidi):
        RtMidiIn(Api api, string clientName, unsigned int queueSizeLimit)
        void setCallback(RtMidiCallback callback, void* userData)
        void cancelCallback()
        void ignoreTypes(bint midiSysex, bint midiTime, bint midiSense)
        double getMessage(vector[unsigned char]* message)

    cdef cppclass RtMidiOut(RtMidi):
        RtMidiOut(Api api, string clientName)
        void sendMessage(vector[unsigned char]* message)


cdef class MidiBase:
    cdef RtMidi* baseptr(self):
        return NULL

    def open_port(self, port=0):
        if isinstance(port, int):
            port_number = port
        else:
            port_number = self.ports.index(port)

        self.baseptr().openPort(port_number)

    def open_virtual_port(self, port_name="RtMidi"):
        self.baseptr().openVirtualPort(string(<char*>port_name))

    property ports:
        def __get__(self):
            return [self.baseptr().getPortName(i).c_str() for i in range(self.baseptr().getPortCount())]

    def close_port(self):
        self.baseptr().closePort()


cdef void midi_in_callback(double time_stamp, vector[unsigned char]* message_vector, void* py_callback) with gil:
    (<object>py_callback)(dereference(message_vector), time_stamp)


cdef class MidiIn(MidiBase):
    cdef RtMidiIn* thisptr
    cdef object py_callback

    def __cinit__(self, client_name=b"RtMidi Input Client", queue_size_limit=100):
        self.thisptr = new RtMidiIn(UNSPECIFIED, string(<char*>client_name), queue_size_limit)
        self.py_callback = None

    def __dealloc__(self):
        del self.thisptr

    cdef RtMidi* baseptr(self):
        return self.thisptr

    property callback:
        def __get__(self):
            return self.py_callback

        def __set__(self, callback):
            if self.py_callback is not None:
                self.thisptr.cancelCallback()

            self.py_callback = callback

            if self.py_callback is not None:
                self.thisptr.setCallback(midi_in_callback, <void*>self.py_callback)

    def ignore_types(self, midi_sysex=True, midi_time=True, midi_sense=True):
        self.thisptr.ignoreTypes(midi_sysex, midi_time, midi_sense)

    def get_message(self):
        cdef vector[unsigned char] message_vector
        delta_time = self.thisptr.getMessage(&message_vector)

        if message_vector.empty():
            return None, None
        else:
            return message_vector, delta_time


cdef class MidiOut(MidiBase):
    cdef RtMidiOut* thisptr

    def __cinit__(self, client_name=b"RtMidi Output Client"):
        self.thisptr = new RtMidiOut(UNSPECIFIED, string(<char*>client_name))

    def __dealloc__(self):
        del self.thisptr

    cdef RtMidi* baseptr(self):
        return self.thisptr

    def send_message(self, message):
        cdef vector[unsigned char] message_vector = message
        self.thisptr.sendMessage(&message_vector)
