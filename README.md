# better_f0.praat

A Praat script for better f0 extraction.

## Purpose

The script optimizes the range parameter (floor and ceiling values) passed to Praat's F0 autocorrelation-based extraction algorithm.

## How it works

The user can select a Sound object from the Objects list or choose a sound file in a folder and the script will generate a Pitch object based on to the algorithm described below.

## Algorithm

The script will first extract the f0 contour in a two-pass operation and then prompt the user to inspect the Pitch object and remove or add pitch points as s/he sees fit. When the user is done the script's execution will continue.
 
The f0 extraction is a two-pass operation. The relevant parameters the algorithm manipulates are floor and ceiling f0 values. In the first pass the Pitch object is extracted using 50 and 700 Hz as floor and ceiling estimates. In the second pass, another Pitch object is extracted using optimal values for floor and ceiling, estimated from the first Pitch object. The optimized values are obtained using the following formulae:

- _floor_ = 0.7  * q<sub>1</sub>
- _ceiling_ = 1.5 * q<sub>3</sub>
 
where q<sub>1</sub> and q<sub>3</sub> are respectively the first and third quartiles of the f0 values contained in the first Pitch object. This heuristic is suggested by Hirst (see [Reference](#reference)). Actually, Hirst suggests 0.75 as a coefficient for q<sub>1</sub>, but in my empirical experience 0.75 seems to result in a floor value that is slightly too high and thus exclude some bona fide f0 candidates. Hirst also suggests that 2.5 * q<sub>3</sub> can give a better estimation of ceiling for expressive speech. The 'Range' option provided in the GUI menu lets the user select between the two constant values (1.5 or 2.5).

If the GUI option 'Inspect' option is selected, the user can manually unvoice frames that s/he considers to be errors after the second pass.

## Changelog

See the [CHANGELOG](CHANGELOG.md) file for the complete version history.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations.

<!--
## How to cite

Click on the DOI badge above to see instructions on how to cite the script.
-->

## Reference

D. J. Hirst, "The Analysis by Synthesis of Speech Melody: from Data to Models," _Journal of Speech Sciences_, vol. 1, no. 1, pp. 55–83, 2011.
