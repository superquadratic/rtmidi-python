from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "Python.h":
    void PyEval_InitThreads()

# Init Python threads and GIL, because RtMidi calls Python from native threads.
# See http://permalink.gmane.org/gmane.comp.python.cython.user/5837
PyEval_InitThreads()

cdef extern from "RtMidi/RtMidi.h":
    ctypedef void (*RtMidiCallback)(double timeStamp, vector[unsigned char]* message, void* userData)

    cdef cppclass RtMidi:
        void openPort(unsigned int portNumber)
        void openVirtualPort(string portName)
        unsigned int getPortCount()
        string getPortName(unsigned int portNumber)
        void closePort()

    cdef cppclass RtMidiIn(RtMidi):
        RtMidiIn(string clientName, unsigned int queueSizeLimit)
        void setCallback(RtMidiCallback callback, void* userData)
        void cancelCallback()
        void ignoreTypes(bint midiSysex, bint midiTime, bint midiSense)
        double getMessage(vector[unsigned char]* message)

    cdef cppclass RtMidiOut(RtMidi):
        RtMidiOut(string clientName)
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
    message = [message_vector.at(i) for i in range(message_vector.size())]
    (<object>py_callback)(message, time_stamp)

cdef class MidiIn(MidiBase):
    cdef RtMidiIn* thisptr
    def __cinit__(self, client_name="RtMidi Input Client", queue_size_limit=100):
        self.thisptr = new RtMidiIn(string(<char*>client_name), queue_size_limit)
    def __dealloc__(self):
        del self.thisptr
    cdef RtMidi* baseptr(self):
        return self.thisptr
    def set_callback(self, callback):
        self.thisptr.setCallback(midi_in_callback, <void*>callback)
    def cancel_callback(self):
        self.thisptr.cancelCallback()
    def ignore_types(self, midi_sysex=True, midi_time=True, midi_sense=True):
        self.thisptr.ignoreTypes(midi_sysex, midi_time, midi_sense)
    def get_message(self):
        cdef vector[unsigned char]* message_vector = new vector[unsigned char]()
        delta_time = self.thisptr.getMessage(message_vector)
        if not message_vector.empty():
            message = [message_vector.at(i) for i in range(message_vector.size())]
            return message, delta_time
        else:
            return None, None

cdef class MidiOut(MidiBase):
    cdef RtMidiOut* thisptr
    def __cinit__(self, client_name="RtMidi Output Client"):
        self.thisptr = new RtMidiOut(string(<char*>client_name))
    def __dealloc__(self):
        del self.thisptr
    cdef RtMidi* baseptr(self):
        return self.thisptr
    def send_message(self, message):
        cdef vector[unsigned char]* message_vector = new vector[unsigned char]()
        for byte in message:
            message_vector.push_back(byte)
        self.thisptr.sendMessage(message_vector)
        del message_vector
