# SilentPiano
Silent Piano Digital Image Processing Project

Gabriel Blanco

Stabilization:
Use the diffFrames function to test stabilization. It takes one parameter which determines the frame step. 

To test without subpixel, call stabilize_no_interp instead of stabilize_frame

To change scale factors, you need to change scale factor in both extract_temp_scale.m and stabilize_frame.m. The scale factor is declared as scale in both files
