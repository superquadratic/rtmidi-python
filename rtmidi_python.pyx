from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "Python.h":
    void PyEval_InitThreads()

# Init Python threads and GIL, because RtMidi calls Python from native threads.
# See http://permalink.gmane.org/gmane.comp.python.cython.user/5837
PyEval_InitThreads()

cdef extern from "RtMidi/RtMidi.h":
    ctypedef void (*RtMidiCallback)(double timeStamp, vector[unsigned char]* message, void* userData)

    cdef cppclass RtMidiIn:
        RtMidiIn(string clientName, unsigned int queueSizeLimit)
        void openPort(unsigned int portNumber, string portName)
        void openVirtualPort(string portName)
        void setCallback(RtMidiCallback callback, void* userData)
        void cancelCallback()
        void closePort()
        unsigned int getPortCount()
        string getPortName(unsigned int portNumber)
        void ignoreTypes(bint midiSysex, bint midiTime, bint midiSense)
        double getMessage(vector[unsigned char]* message)

    cdef cppclass RtMidiOut:
        RtMidiOut(string clientName)
        void openPort(unsigned int portNumber, string portName)
        void closePort()
        void openVirtualPort(string portName)
        unsigned int getPortCount()
        string getPortName(unsigned int portNumber)
        void sendMessage(vector[unsigned char]* message)

cdef void midi_in_callback(double time_stamp, vector[unsigned char]* message_vector, void* py_callback) with gil:
    message = [message_vector.at(i) for i in range(message_vector.size())]
    (<object>py_callback)(message, time_stamp)

cdef class MidiIn:
    cdef RtMidiIn* thisptr
    def __cinit__(self, client_name="RtMidi Input Client", queue_size_limit=100):
        self.thisptr = new RtMidiIn(string(<char*>client_name), queue_size_limit)
    def __dealloc__(self):
        del self.thisptr
    def open_port(self, port_number=0, port_name="RtMidi Input"):
        self.thisptr.openPort(port_number, string(<char*>port_name))
    def open_virtual_port(self, port_name="RtMidi Input"):
        self.thisptr.openVirtualPort(string(<char*>port_name))
    def set_callback(self, callback):
        self.thisptr.setCallback(midi_in_callback, <void*>callback)
    def cancel_callback(self):
        self.thisptr.cancelCallback()
    def close_port(self):
        self.thisptr.closePort()
    def get_port_count(self):
        return self.thisptr.getPortCount()
    def get_port_name(self, port_number=0):
        return self.thisptr.getPortName(port_number).c_str()
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

cdef class MidiOut:
    cdef RtMidiOut* thisptr
    def __cinit__(self, client_name="RtMidi Output Client"):
        self.thisptr = new RtMidiOut(string(<char*>client_name))
    def __dealloc__(self):
        del self.thisptr
    def open_port(self, port_number=0, port_name="RtMidi Output"):
        self.thisptr.openPort(port_number, string(<char*>port_name))
    def close_port(self):
        self.thisptr.closePort()
    def open_virtual_port(self, port_name="RtMidi Output"):
        self.thisptr.openVirtualPort(string(<char*>port_name))
    def get_port_count(self):
        return self.thisptr.getPortCount()
    def get_port_name(self, port_number=0):
        return self.thisptr.getPortName(port_number).c_str()
    def send_message(self, message):
        cdef vector[unsigned char]* message_vector = new vector[unsigned char]()
        for byte in message:
            message_vector.push_back(byte)
        self.thisptr.sendMessage(message_vector)
        del message_vector
