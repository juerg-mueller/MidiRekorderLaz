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
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  {$ifndef mswindos}
  rtmidi,
  urtmidi,
  {$else}
  Midi in 'Midi.pas',
  {$endif }
  Forms,
  {$ifdef FPC}
  lcl, Interfaces,
  {$endif }
  UMidirekorder in 'umidirekorder.pas' {MidiGriff},
  UMidiEvent in 'UMidiEvent.pas',
  UMyMemoryStream in 'UMyMemoryStream.pas',
  UMyMidiStream in 'UMyMidiStream.pas',
  UMidiDataStream in 'UMidiDataStream.pas',
  UEventArray in 'UEventArray.pas',
  UBanks, UMidi, UFormHelper, UMidiDataIn;

begin
{$ifdef FPC}
  Application.Scaled:=True;
{$endif}
  Application.Initialize;
  Application.CreateForm(TMidiRecorder, MidiRecorder);
  Application.Run;
end.
