unit umidirekorder;
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
interface
uses
{$ifdef VCL}
  Winapi.Windows, Winapi.Messages,
{$endif}
  SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, CheckLst, syncobjs,
  ExtCtrls,
  UMidiEvent, UBanks;
type
  { TMidiGriff }
  TMidiGriff = class(TForm)
    gbMIDI: TGroupBox;
    btnStart: TButton;
    cbxMidiInput: TComboBox;
    cbxMidiOut: TComboBox;
    Label17: TLabel;
    lblKeyboard: TLabel;
    SaveDialog1: TSaveDialog;
    gbHeader: TGroupBox;
    Label8: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    lbBegleitung: TLabel;
    Label10: TLabel;
    cbxViertel: TComboBox;
    cbxTakt: TComboBox;
    edtBPM: TEdit;
    cbxMetronom: TCheckBox;
    sbMetronom: TScrollBar;
    sbMetronom1: TScrollBar;
    cbxNurTakt: TCheckBox;
    Timer1: TTimer;
    lbVolume: TLabel;
    cbxDiskantBank: TComboBox;
    cbxMidiDiskant: TComboBox;
    procedure btnStartClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbxMidiOutChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbxMidiInputChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbxTaktChange(Sender: TObject);
    procedure cbxViertelChange(Sender: TObject);
    procedure cbxDiskantBankChange(Sender: TObject);
    procedure edtBPMExit(Sender: TObject);
    procedure cbxMetronomClick(Sender: TObject);
    procedure cbxNurTaktClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure sbMetronomChange(Sender: TObject);
  private
    InRecord: boolean;
    procedure SaveMidi;
  public
    Header: TDetailHeader;
    Metronom: boolean;
    NurTakt: boolean;
    pipCount: integer;
    nextPip: TTime;
    pipDelay: TTime;

    procedure OnMidiInData_(Status, Data1, Data2: byte; Timestamp: integer);
    procedure CopyArray(cbx: TComboBox; var Bank: TArrayOfString);
  {$ifndef FPC}
    procedure OnMidiInData(Status, Data1, Data2: byte; Timestamp: integer);
  {$endif}
  end;

var
  MidiGriff: TMidiGriff;
implementation
{$ifdef FPC}
  {$R *.lfm}
{$else}
  {$R *.dfm}
{$endif}
uses
{$ifdef FPC}
  urtmidi,
{$else}
  Midi,
{$endif}
  UMidiSaveStream, UMidiDataStream;
const
  strStart = 'Aufnahme starten';
  strStop  = 'Aufnahme beenden';
var
  MidiRec: TMidiRecord;
  pipLast: byte = 0;
  pipChannel: byte = 9;
  VolumeDiscant: double = 0.9;
  VolumeMetronom: double = 0.8;
{$ifdef FPC}
procedure OnMidiInData(TimeStamp: double; const message: PChar; userData: pointer); cdecl;
var
  Status, Data1, Data2: byte;
begin
  Status := Byte(message[0]);
  Data1  := Byte(message[1]);
  Data2  := Byte(message[2]);
  MidiGriff.OnMidiInData_(Status, Data1, Data2, TimeStamp);
end;
{$else}
procedure TMidiGriff.OnMidiInData(Status, Data1, Data2: byte; Timestamp: integer);
begin
{$ifdef CONSOLE}
  writeln(Status, '  ', Data1, '  ', Data2);
{$endif}
  if InRecord then
    MidiRec.OnMidiInData(Status, Data1, Data2, Timestamp);
  MidiOutput.Send(Status, Data1, Data2);
end;
{$endif}

procedure TMidiGriff.SaveMidi;
var
  name: string;
  SaveStream: UMidiSaveStream.TMidiSaveStream;
  Simple: TSimpleDataStream;
  i: integer;
begin
  SaveStream := UMidiSaveStream.TMidiSaveStream.BuildSaveStream(MidiRec);
  if SaveStream <> nil then
  begin
    name := 'midi_rekorder';
    if FileExists(name+'.mid') then
    begin
      name := name + '_';
      i := 1;
      while FileExists(name + IntToStr(i) + '.mid', false) do
        inc(i);
      name := name + IntToStr(i);
    end;
    SaveStream.SaveToFile(name+'.mid');
    Simple := TSimpleDataStream.Create;
    if Simple.MakeSimpleFile(SaveStream) then
    begin
      Simple.SaveToFile(name + '.txt');
    end;
  {$ifdef FPC}
    Application.MessageBox(PChar(name + ' gespeichert'), '');
  {$else}
    Application.MessageBox(PWideChar(name + ' gespeichert'), '');
  {$endif}
    SaveStream.Free;
  end;                
end;

procedure TMidiGriff.sbMetronomChange(Sender: TObject);
var
  s: string;
  p: double;
begin
  with Sender as TScrollBar do
  begin
    s := Format('Lautstärke  (%d %%)', [Position]);
    p := Position / 100.0;
  end;
  if Sender = sbMetronom then begin
    lbBegleitung.Caption := s;
    VolumeMetronom := p;
  end else begin
    lbVolume.Caption := s;
    VolumeDiscant := p;
  end;
end;

procedure TMidiGriff.Timer1Timer(Sender: TObject);  // Timer für Metronom
var
  Event: TMouseEvent;
  Key: word;
  BPM, mDiv: integer;
  sec: boolean;
  pip: byte;
  vol: double;
  Time: TDateTime;

  procedure SendMidiOut(Status, Data1, Data2: byte);
  begin
    Status := Status + pipChannel;
    OnMidiInData_(Status, Data1, Data2, 0);
  end;

begin
  if Metronom then
  begin
    Time := now;
    if nextPip = 0 then begin
      nextPip := Time;
      pipDelay := Time + 1/(24.0*60.0)/BPM;
      pipCount := 0;
    end;
    BPM := Header.beatsPerMin;
    mDiv := Header.measureDiv; // ist 4 oder 8
    if NurTakt then
      sec := false
    else
    if mDiv = 8 then
    begin
      BPM := 2*BPM;
      sec := (Header.measureFact = 6) and (pipCount = 3);
    end else
      sec := true;
    pip := 0;
    if pipCount = 0 then
      pip := pipFirst
    else
    if sec then
      pip := pipSecond;
    if Time >= nextPip then
    begin
      vol := 100*VolumeMetronom;
      if vol > 126 then
        vol := 126;
      if pip > 0 then
      begin
        SendMidiOut($90, pip, trunc(vol));
      end;
      pipDelay := Time + 1/(24*60.0)/BPM/4;
      nextPip := nextPip + 1/(24.0*60.0)/BPM;
      pipLast := pip;
    end else
    if (Time >= pipDelay) and (pipDelay > 0) then
    begin
      pipDelay := 0;
      if pipLast > 0 then
      begin
        SendMidiOut($80, pipLast, 64);
        pipLast := 0;
      end;
      inc(pipCount);
      if pipCount >= Header.measureFact then
        pipCount := 0;
    end;
  end;
end;

procedure TMidiGriff.btnStartClick(Sender: TObject);
var
  i, j: integer;
begin
  if btnStart.Caption = strStop then
  begin
    InRecord := false;
    btnStart.Caption := strStart;
    for j := 0 to 9 do
      MidiOutput.Send($B0 + j, 120, 0);
//    MidiOutput.CloseAll;
    SaveMidi;
    FreeAndNil(MidiRec);
  end else
  if cbxMidiInput.ItemIndex < 1 then
  begin
    Application.MessageBox('Bitte, wählen Sie einen Midi Input', 'Fehler');
  end else begin
    MidiRec := TMidiRecord.Create(Header);
    InRecord := true;
    for i := 0 to 7 do
      OnMidiInData_($C0 + i, 21, 0, 0);
    btnStart.Caption := strStop;
  end;
end;

procedure TMidiGriff.cbxMetronomClick(Sender: TObject);
begin
  Metronom := cbxMetronom.Checked;
  if (not Metronom) and (pipLast <> 0) then
    OnMidiInData_($80 + pipChannel, pipLast, 64, 0);
  pipLast := 0;
  nextPip := 0;
end;

procedure TMidiGriff.cbxMidiInputChange(Sender: TObject);
begin
  MidiInput.CloseAll;
  MidiInput.OnMidiInData := nil;
  if cbxMidiInput.ItemIndex > 0 then
  begin
  {$ifdef FPC}
    MidiInput.OnMidiInData := @OnMidiInData;
    MidiInput.Open(cbxMidiInput.ItemIndex-1, self);
  {$else}
    MidiInput.OnMidiInData := OnMidiInData;
    MidiInput.Open(cbxMidiInput.ItemIndex-1);
  {$endif}
  end;
end;

procedure TMidiGriff.CopyArray(cbx: TComboBox; var Bank: TArrayOfString);
var
  i: integer;
begin
  cbx.Items.Clear;
  for i := 0 to Length(Bank)-1 do
    cbx.Items.Add(Bank[i]);
  cbx.ItemIndex := 0;
  SetLength(Bank, 0);
end;

procedure TMidiGriff.cbxDiskantBankChange(Sender: TObject);

  function getInt(const s: string): integer;
  var
    t: string;
  begin
    t := trim(s);
    t := Copy(s, 1, Pos(' ', s)-1);
    result := StrToIntDef(t, 0);
  end;
var
  i: integer;
  iBank, iInstr: integer;
  Bank: TArrayOfString;
begin
  iBank := getInt(cbxDiskantBank.Text);
  if Sender = cbxDiskantBank then
  begin
    GetBank(Bank, iBank);
    CopyArray(cbxMidiDiskant, Bank);
  end;
  iInstr := getInt(cbxMidiDiskant.Text);
  for i := 0 to 7 do
  begin
    OnMidiInData_($b0 + i, iBank, 0, 0);  // 0x32, LSB Bank);
    OnMidiInData_($c0 + i, iInstr, 0, 0);
  end
end;

procedure TMidiGriff.cbxMidiOutChange(Sender: TObject);
var
  OutputDevIndex: integer;
begin
  MidiOutput.Close;
  OutputDevIndex := cbxMidiOut.ItemIndex;
  if OutputDevIndex > 0 then
  begin
    MidiOutput.Open(OutputDevIndex-1);
    cbxDiskantBankChange(nil);
  end;
end;

procedure TMidiGriff.cbxNurTaktClick(Sender: TObject);
begin
  NurTakt := cbxNurTakt.Checked;
end;

procedure TMidiGriff.cbxTaktChange(Sender: TObject);
begin
  Header.measureFact := cbxTakt.ItemIndex + 2;
end;

procedure TMidiGriff.cbxViertelChange(Sender: TObject);
var
  q: integer;
begin
  case cbxViertel.ItemIndex of
    0: q := 4;
    1: q := 8;
    else q := 4;
  end;
  Header.MeasureDiv :=  q;
end;

procedure TMidiGriff.edtBPMExit(Sender: TObject);
begin
  Header.beatsPerMin := StrToInt(edtBPM.Text);
  cbxViertelChange(Sender);
end;

procedure TMidiGriff.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MidiInput.CloseAll;
end;

procedure TMidiGriff.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := btnStart.Caption = strStart;
end;

{$ifdef FPC}
procedure InsertList(Combo: TComboBox; const arr: array of string);
var
  i: integer;
begin
  for i := 0 to Length(arr)-1 do
    Combo.AddItem(arr[i], nil);
end;
{$else}
procedure InsertList(Combo: TComboBox; arr: TStringList);
var
  i: integer;
begin
  for i := 0 to arr.Count-1 do
    Combo.AddItem(arr[i], nil);
end;
{$endif}

procedure AddLine(cbx: TComboBox);
begin
  cbx.Items.Insert(0, '');
  cbx.ItemIndex := 0;
end;

procedure TMidiGriff.FormCreate(Sender: TObject);
var
  Bank: TArrayOfString;
begin
  MidiInput.GenerateList;
  MidiOutput.GenerateList;
  InRecord := false;
  InsertList(cbxMidiOut, MidiOutput.DeviceNames);
  AddLine(cbxMidiOut);
  cbxMidiOut.ItemIndex := 0;
  InsertList(cbxMidiInput, MidiInput.DeviceNames);
  AddLine(cbxMidiInput);
  cbxMidiInput.ItemIndex := 0;
  Header.Clear;
  btnStart.Caption := strStart;
  edtBPMExit(nil);
  sbMetronomChange(sbMetronom);
  sbMetronomChange(sbMetronom1);
  CopyBank(Bank, @bank_list);
  CopyArray(cbxDiskantBank, Bank);
end;

// Für Metronom
procedure TMidiGriff.OnMidiInData_(Status, Data1, Data2: byte; Timestamp: integer);
begin
  if InRecord then
    MidiRec.OnMidiInData(Status, Data1, Data2, Timestamp);
{$ifdef CONSOLE}
//  writeln('$', IntToHex(Status), '  ', Data1, '  ', Data2);
{$endif}
  MidiOutput.Send(Status, Data1, Data2);
end;

end.
