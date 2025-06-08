program MidiRekorder;
// Für MAC
//
// brew install rtmidi
// brew install lazarus
// Für Linux
//
// sudo apt install librtmidi-dev
// sudo apt install fluidsynth
uses
{$ifdef unix}
  cthreads,
  pthreads,
{$endif}
  UMidi,
{$if not defined(mswindows) or defined(USE_RTMIDI)}
  rtmidi,
  urtmidi,
{$else}
  Midi in 'Midi.pas',
{$endif}
  Forms,
{$ifdef FPC}
  lcl, Interfaces,
{$endif}
  UMidirekorder in 'umidirekorder.pas' {MidiRecorder},
  UMidiEvent in 'UMidiEvent.pas',
  UMyMemoryStream in 'UMyMemoryStream.pas',
  UMyMidiStream in 'UMyMidiStream.pas',
  UMidiDataStream in 'UMidiDataStream.pas',
  UEventArray in 'UEventArray.pas',
  UBanks, UMidiDataIn, CriticalSection;

begin
{$ifdef FPC}
  Application.Scaled:=True;
{$endif}
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMidiRecorder, MidiRecorder);
  Application.Run;
end.
