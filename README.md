Allgemeiner MIDI-Rekorder mit Metronom
======================================

Der MIDI-Rekorder kann mit Delphi oder Lazarus kompiliert werden: Mit Delphi nur für Windows, mit Lazarus zusätzlich für Linux und MAC. 

Für MAC und Linux braucht es für die MIDI-Schnittstelle jeweils eine Dynamische Library (https://github.com/thestk/rtmidi).

Installation von rtmidi unter Linux: sudo apt install librtmidi-dev

Installation von rtmidi unter MAC: brew install rtmidi

Hinweise zur Insallation von Lazarus und zum Cross-Compiling findest du hier:  https://wiki.freepascal.org/fpcupdeluxe/de

Volume- und Expression-Control werden nicht aufgenommen. Es sind die Midi-Events "$Bn $0B nn" und "$Bn $07 nn".


MIDI Ausgabe-Format
-------------------

Es sind immer zwei Tracks. Alle Noten von sämtlichen Kanälen sind im zweiten Track. Die ersten acht Kanäle werden mit dem Akkordeon als Instrument belegt. In meinem eigenen, Text basierten MIDI-File, sieht das etwa so aus:

![midi-txt](https://github.com/user-attachments/assets/8a29306b-fbb4-488e-a9ea-b344a67f12e7)
