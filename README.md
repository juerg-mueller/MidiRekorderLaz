Allgemeiner MIDI-Rekorder mit Metronom
======================================

Der MIDI-Rekorder ist mit Delphi und Lazarus kompilierbar. 

Der MIDI-Rkorder kann für Linux und für den MAC generiert werden. Dazu ist für die MIDI-Schnittstelle jeweils eine Dynamische Library notwendig (https://github.com/thestk/rtmidi).

Installation von rtmidi unter Linux: sudo apt install librtmidi-dev

Installation von rtmidi unter MAC: brew install rtmidi

Hinweis zur Insallation von Lazarus und Cross-Compiling findest du hier:  https://wiki.freepascal.org/fpcupdeluxe/de

Volume- und Expression-Control werden nicht aufgenommen. Es sind die Midi-Events "$Bn $0B nn" und "$Bn $07 nn".
