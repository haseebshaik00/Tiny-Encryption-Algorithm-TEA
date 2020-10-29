The .asm file contains a encryption algorithm named as Tiny Encryption Algorithm which I implemented on emu8086 for my Microprocessor Project.

# Introduction
In cryptography, the Tiny Encryption Algorithm is a block cipher notable for its simplicity of description and implementation, typically a few lines of code. It was designed by David Wheeler and Roger Needham of the Cambridge Computer Laboratory; it was first presented at the Fast Software Encryption workshop in Leuven in 1994, and first published in the proceedings of that workshop.TEA operates on two 32-bit and uses a 128-bit key. It has a Feistel structure with a suggested 64 rounds, typically implemented in pairs termed cycles. It has an extremely simple key schedule, mixing all of the key material in exactly the same way for each cycle. Different multiples of a magic constant are used to prevent simple attacks based on the symmetry of the rounds. TEA has a few weaknesses. Most notably, it suffers from equivalent keys each key is equivalent to three others, which means that the effective key size is only 126 bits. As a result, TEA is especially bad as a cryptographic hash function. 

The Tiny Encryption Algorithm (TEA) is one of the fastest and most efficient cryptographic algorithms in existence. It’s is a symmetric (private) key encryption algorithm hence easy to implement. It’s designed to minimize memory footprint and maximize speed hence better than the other existing algorithms. It achieves the Shannon's properties of complete diffusion and confusion without the employment of S & P boxes, after only six rounds but thirty-two rounds are recommended. Thus, we will analyse and try to implement both the encryption and decryption modules of Tiny Encryption Algorithm using emu8086 microprocessor emulator.

# Modules 
1) Data Segment 
2) Code Segment
    a) Take input of the plain text
    b) Take input of the key
    c) Main Module
    d) Encryption Module
    e) Decryption Module 
    f) Print Module