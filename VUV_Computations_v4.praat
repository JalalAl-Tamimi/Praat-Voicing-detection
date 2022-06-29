##06 April 2009: version 1. Using autocorrelation.
## 01 April 2011: version 2. A few updates (for details, see Al-Tamimi and Khattab, 2015, JASA, 138(1): 344–360).  
## 25 May 2017: version 3. Using cross-correlation pitch estimate rather than autocorrelation 
## (for details, see Al-Tamimi and Khattab, 2018, Journal of Phonetics, Special Issue on VOT, 71: 306-325) 
## Estimation of Pitch is based on the two-pass method.
## 06 February 2019: version 4. Changed voicing threshold to 0.7 (instead of default 0.45) for a better 
## detection of voiced frames.
## 29 June 2022: Minor updates


beginPause: "VUV computations"
comment: "Where are your sound files and TextGrids?"
sentence: "directory1", ""
clicked = endPause: "OK", 1

if directory1$ = ""
	directory1$ = chooseDirectory$("Select your directory of sound files and TextGrids")
endif

Create Strings as file list: "list", "'directory1$'\*.wav"

numberOfFiles = Get number of strings

for i from 1 to numberOfFiles
	select Strings list
   	fileName$ = Get string: i

	Read from file: "'directory1$'\'fileName$'"
	name$ = selected$ ("Sound")
	Read from file: "'directory1$'\'name$'.TextGrid"
	select Sound 'name$'
	Filter (pass Hann band): 0, 500, 20
	soundFiltered = selected ("Sound")
	select 'soundFiltered'
	noprogress To Pitch (cc): 0.005, 50, 15, "yes", 0.03, 0.7, 0.01, 0.35, 0.14, 600
	q1 = Get quantile: 0, 0, 0.25, "Hertz"
	q3 = Get quantile: 0, 0, 0.75, "Hertz"
	minPitch = q1*0.75
	maxPitch = q3*1.5
	Remove
	select 'soundFiltered'
	noprogress To Pitch (cc): 0.005, minPitch, 15, "yes", 0.03, 0.7, 0.01, 0.35, 0.14, maxPitch
	pitch = selected ("Pitch")
	select 'soundFiltered'
	plus 'pitch'
	pointProsess = noprogress To PointProcess (cc)
	meanPeriod = Get mean period: 0, 0, 0.0001, 0.02, 1.3
	To TextGrid (vuv): 0.02, meanPeriod
	Rename...  'name$'_vuv
	select TextGrid 'name$'_VUV
	plus TextGrid 'name$'_vuv
	Merge

	Write to text file: "'directory1$'\'name$'_VUV.TextGrid"
	select all
	minus Strings list
	Remove
endfor
echo Finished! Check your new TextGrids located in 'directory1$'

