import wave
import math
import struct
import random

def generate_click(filename):
    sample_rate = 44100
    duration = 0.05 # seconds
    frequency = 800
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(int(duration * sample_rate)):
            # Simple decaying sine wave
            value = int(32767.0 * math.sin(2 * math.pi * frequency * i / sample_rate) * ((duration * sample_rate - i) / (duration * sample_rate)))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

def generate_win(filename):
    sample_rate = 44100
    duration = 1.5
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # Simple arpeggio
        frequencies = [440, 554, 659, 880] # A major
        
        for i in range(int(duration * sample_rate)):
            t = i / sample_rate
            freq = frequencies[int(t * 4) % 4]
            value = int(10000.0 * math.sin(2 * math.pi * freq * t))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

if __name__ == "__main__":
    generate_click("assets/audio/click.wav")
    generate_win("assets/audio/win.wav")
