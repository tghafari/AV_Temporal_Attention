"""
Simple wrapper around pyOSC to send OSC packets.

pyOSC - https://trac.v2.nl/wiki/pyOSC
"""

import pyOSC3


class OSCSender:
    """ Class for sending simple OSC messages.
    """
    def __init__(self, send_address=('127.0.0.1', 57120)):
        #57120: default port for supercollider
        self.osc_client = pyOSC3.OSCClient()
        self.osc_client.connect(send_address)

    def send(self, route, val):
        """ Send an OSC message.
        """
        msg = pyOSC3.OSCMessage()
        msg.setAddress(route)
        msg.append(val)
        self.osc_client.send(msg)

