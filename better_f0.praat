# better_f0.praat
#
# author: Pablo Arantes <pabloarantes@protonmail.com>
# created: 2010-10-16
# last updated: 2018-10-01
#
# = Purpose =
# The purpose of the procedure is to optimize the range parameter
# (floor and ceiling values) passed to Praat's F0 extraction algorithm.
#
# = How it works = 
# The user can select a Sound file from the Objects list or choose
# a file in a folder and the script will output a Pitch object
# obtained according to the algorithm described below. If the
# 'Inspect' option is selected in the script's GUI the user can 
# manually unvoice frames that he considers to be errors, although
# caution is recommended when using this procedure.
#
# = Algorithm = 
# The script will first extract the F0 contour in a two-pass operation
# and then prompt the user to inspect the Pitch object and remove
# or add pitch points as s/he sees fit. When the user is done the
# script's execution will continue.
# 
# The F0 extraction is a two-pass operation. The relevant parameters
# the algorithm manipulates are floor and ceiling F0 values. In the
# first pass the Pitch object is extracted using 50 and 700 Hz as floor and
# ceiling estimates. In the second pass another Pitch object is extracted using
# optimal values for floor and ceiling estimated from the first Pitch
# object. The values are obtained using the following formulae:
# 
# - F0 floor = 0.7  *q1
# - F0 ceiling = 1.5 * q3
# 
# where q1 and q3 are respectively the first and third quartiles of the
# first Pitch object F0 values. This heuristic is suggested by Hirst
# [cf. D. Hirst, Journal of Speech Sciences, 1(1):55-83 (2011)]. Actually,
# Hirst suggests 0.75 as a coefficient for q1, but in my empirical
# experience 0.75 led to values slightly higher than the first-pass
# minumum value in situations where it was bona fide.
# Hirst also suggests that for expressive speech 2.5 * q3 can give a better
# estimation of ceiling. The 'Range' option provided in the GUI menu lets
# the user select between the two constant values (1.5 or 2.5).
#
# Copyright (C) 2010-2019  Pablo Arantes
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

form better_f0.praat
	choice F0_range: 2
		button Normal (ceiling = 1.5 * q3)
		button Extended (ceiling = 2.5 * q3)
	boolean Inspect no
	choice File: 1
		button Select a Sound from the Objects list
		button Choose a file in a folder
	boolean Save_Pitch no
	sentence Path D:\_temp\optimized\
endform

if file = 1
	sel = numberOfSelected()
	if sel <> 1
		pauseScript: "Select one Sound from the Objects list"
	else
		sel$ = selected$()
		sel$ = extractWord$(sel$, "")
		if sel$ <> "Sound"
			exitScript: "Select a Sound from the Objects list"
		else
			audio = selected("Sound")
		endif
	endif
else
	audio$ = chooseReadFile$ ("Select a WAV file")
	if audio$ <> ""
		audio = Read from file: 'audio$'
	endif
endif

first_pitch = noprogress To Pitch:  0, 50, 700
pitch_name$ = selected$("Pitch")
min = Get minimum: 0, 0, "Hertz", "None"
max = Get maximum: 0, 0, "Hertz", "None"
q1 = Get quantile: 0, 0, 0.25, "Hertz"
q1 = floor(q1)
q3 = Get quantile: 0, 0, 0.75, "Hertz"
q3 = ceiling(q3)
# Round floor and ceiling values to the nearest 10 Hz
floor = floor((0.7 * q1)/ 10) * 10
if f0_range = 1
	ceiling = ceiling((1.5 * q3)/ 10) * 10
else
	ceiling = ceiling((2.5 * q3)/ 10) * 10
endif
removeObject: first_pitch

selectObject: audio
# Second pass F0 extraction
pitch = noprogress To Pitch (ac):  0, floor, 15, "yes", 0.03, 0.45, 0.01, 0.35, 0.14, ceiling

if inspect = 1
	selectObject: audio
	Edit
	editor: audio
		Pitch settings: floor, ceiling, "Hertz", "autocorrelation", "speckles"
		Advanced pitch settings: floor, ceiling, "no", 15, 0.03, 0.45, 0.01, 0.35, 0.14
	endeditor

	selectObject: pitch
	voiced_before = Count voiced frames
	# Prompt user to remove or add points in the 2nd pass Picth object
	Edit
	editor: pitch
		beginPause: "Unvoice spurious pitch points. (Selection > Unvoice)"
		action = endPause ("Done", 1)
		if action = 1
			Close
		endif
	endeditor
	selectObject: pitch
	voiced_after = Count voiced frames
	balance = voiced_after - voiced_before
	editor: audio
		Close
	endeditor
endif

new_min = Get minimum: 0, 0, "Hertz", "None"
new_max = Get maximum: 0, 0, "Hertz", "None"

if save_Pitch = 1
	Write to text file: path$ + pitch_name$ + ".Pitch"
endif

# Writing information to the the info window
writeInfo: ""
appendInfoLine: "F0 extraction report"
appendInfoLine: "--------------------"
appendInfoLine: "file: ", pitch_name$
appendInfoLine: "1st pass > minimum: ", round(min), " Hz - maximum: ", round(max), " Hz"
appendInfoLine: "estimated parameters: floor: ", floor, "Hz - ceiling: ", ceiling, " Hz"
appendInfoLine: "2nd pass > minimum: ", round(new_min), " Hz - maximum: ", round(new_max), " Hz"
if inspect = 1
	appendInfoLine: "net change: ", balance, " points"
endif

appendInfoLine: "--"
appendInfoLine: "Run on ", date$()