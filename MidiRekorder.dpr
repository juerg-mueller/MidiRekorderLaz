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
  {$ifdef FPC}
  urtmidi,
  {$else}
  Midi in 'Midi.pas',
  {$endif }
  Forms,
  {$ifdef FPC}
  lcl, Interfaces,
  {$endif }
  UMidirekorder in 'umidirekorder.pas' {MidiGriff},
  UMidiSaveStream in 'UMidiSaveStream.pas',
  UMidiEvent in 'UMidiEvent.pas',
  UMyMemoryStream in 'UMyMemoryStream.pas',
  UMyMidiStream in 'UMyMidiStream.pas',
  UMidiDataStream in 'UMidiDataStream.pas',
  UEventArray in 'UEventArray.pas',
  UBanks;

begin
{$ifdef FPC}
  Application.Scaled:=True;
{$endif}
  Application.Initialize;
  Application.CreateForm(TMidiGriff, MidiGriff);
  Application.Run;
end.
