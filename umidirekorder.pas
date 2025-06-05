unit umidirekorder;
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
interface

uses
  UMidi, UMidiDataStream, UMidiDataIn,
{$ifdef VCL}
  Winapi.Windows, Winapi.Messages,
{$endif}
  SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, CheckLst, syncobjs,
  ExtCtrls,
  UMidiEvent, UBanks;
type
  { TMidiRecorder }
  TMidiRecorder = class(TForm)
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
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure sbMetronomChange(Sender: TObject);
  private
    InRecord: boolean;
    procedure SaveMidi;
  public
    Header: TDetailHeader;
    Metronom: TMetronom;

    procedure OnMidiInData(DeviceIndex: LongInt; Status, Data1, Data2: byte; Timestamp: Int64);
    procedure CopyArray(cbx: TComboBox; var Bank: TArrayOfString);
  end;

var
  MidiRecorder: TMidiRecorder;

  MidiEventRecorder: TMidiEventRecorder;
  MidiInBuffer: TMidiInRingBuffer;

implementation
{$ifdef FPC}
  {$R *.lfm}
{$else}
  {$R *.dfm}
{$endif}
uses
{$ifndef mswindows}
  urtmidi;
{$else}
  Midi;
{$endif}

const
  strStart = 'Aufnahme starten';
  strStop  = 'Aufnahme beenden';

procedure TMidiRecorder.OnMidiInData(DeviceIndex: LongInt; Status, Data1, Data2: byte; Timestamp: Int64);
var
  Data: TMidiInData;
begin
  Data.Clear;
  Data.DeviceIndex := DeviceIndex;
  Data.Status := Status;
  Data.Data1 := Data1;
  Data.Data2 := Data2;
  Data.Timestamp := Timestamp;
  MidiInBuffer.Put(Data);
end;

procedure TMidiRecorder.SaveMidi;
var
  name: string;
  SaveStream: TMidiSaveStream;
  Simple: TSimpleDataStream;
  i: integer;
begin
  SaveStream := MidiEventRecorder.MakeRecordStream(Header);
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
    Simple := TSimpleDataStream.MakeSimpleDataStream(SaveStream);
    if Simple <> nil then
    begin
      Simple.SaveToFile(name + '.mid.txt');
      Simple.Free;
    end;
  {$ifdef FPC}
    Application.MessageBox(PChar(name + ' gespeichert'), '');
  {$else}
    Application.MessageBox(PWideChar(name + ' gespeichert'), '');
  {$endif}
    SaveStream.Free;
  end;                
end;

procedure TMidiRecorder.sbMetronomChange(Sender: TObject);
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

procedure TMidiRecorder.Timer1Timer(Sender: TObject);  // Timer für Metronom
var
  rec: TMidiInData;
begin
  while MidiInBuffer.Get(rec) do
  begin
    if InRecord and ((rec.Status shr 4) <= 11) then
    begin
      if ((rec.Status shr 4) = 9) and (rec.Data2 = 0) then // running Status
      begin
        dec(rec.Status, $10);
        rec.Data2 := 64;
      end;
      MidiEventRecorder.Append(rec.GetMidiEvent);
    end;
    SendMidiEvent(rec.GetMidiEvent);
  end;

  if Metronom.DoPip(Header) then
  begin
    rec.Init(Metronom.MidiEvent);
    if InRecord and Metronom.IsFirst then // Taktbeginn
      MidiInBuffer.Put(rec)
    else
      SendMidiEvent(rec.GetMidiEvent);
  end;
end;

procedure TMidiRecorder.btnStartClick(Sender: TObject);
var
  i, j: integer;
begin
  if btnStart.Caption = strStop then
  begin
    InRecord := false;
    btnStart.Caption := strStart;
    for j := 0 to 9 do
      SendMidi($B0 + j, 120, 0);
    MidiOutput.Reset;
    MidiEventRecorder.Stop;
    SaveMidi;
  end else
  if cbxMidiInput.ItemIndex < 1 then
  begin
    Application.MessageBox('Bitte, wählen Sie einen Midi Input!', 'Fehler');
  end else begin
    MidiEventRecorder.Start;
    InRecord := true;
    btnStart.Caption := strStop;
  end;
end;

procedure TMidiRecorder.cbxMetronomClick(Sender: TObject);
begin
  Metronom.SetOn(cbxMetronom.Checked);
  if not Metronom.On_ then
  begin
    SendMidi($80 + pipChannel, pipFirst, 64);
    SendMidi($80 + pipChannel, pipSecond, 64);
  end;
end;

procedure TMidiRecorder.cbxMidiInputChange(Sender: TObject);
begin
  MidiInput.CloseAll;
  //MidiInput.OnMidiData := nil;
  if cbxMidiInput.ItemIndex > 0 then
  begin
    MidiInput.OnMidiData := OnMidiInData;
    MidiInput.Open(cbxMidiInput.ItemIndex-1);
  end;
end;

procedure TMidiRecorder.CopyArray(cbx: TComboBox; var Bank: TArrayOfString);
var
  i: integer;
begin
  cbx.Items.Clear;
  for i := 0 to Length(Bank)-1 do
    cbx.Items.Add(Bank[i]);
  cbx.ItemIndex := 0;
  SetLength(Bank, 0);
end;

procedure TMidiRecorder.cbxDiskantBankChange(Sender: TObject);

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
  Bank: TArrayOfString;
begin
  SetLength(Bank, 0);
  MidiBankDiskant := getInt(cbxDiskantBank.Text);
  if Sender = cbxDiskantBank then
  begin
    GetBank(Bank, MidiBankDiskant);
    CopyArray(cbxMidiDiskant, Bank);
  end;
  MidiInstrDiskant := getInt(cbxMidiDiskant.Text);
  for i := 0 to 7 do
  begin
//    OnMidiInData_($b0 + i, 0, MidiBankDiskant, 0);  // 0x32, LSB Bank);
//    OnMidiInData_($c0 + i, MidiInstrDiskant, 0, 0);
  end
end;

procedure TMidiRecorder.cbxMidiOutChange(Sender: TObject);
var
  OutputDevIndex: integer;
begin
  if cbxMidiOut.ItemIndex >= 0 then
  begin
    if MicrosoftIndex >= 0 then
      MidiOutput.Close(MicrosoftIndex);
    if cbxMidiOut.ItemIndex = 0 then
      MicrosoftIndex := -1
    else
      MicrosoftIndex := cbxMidiOut.ItemIndex-1;

    OpenMidiMicrosoft;
  end;
end;

procedure TMidiRecorder.cbxNurTaktClick(Sender: TObject);
begin
  NurTakt := cbxNurTakt.Checked;
  if Metronom.On_ and not NurTakt then
  begin
    SendMidi($80 + pipChannel, pipSecond, 64);
  end;
end;

procedure TMidiRecorder.FormDestroy(Sender: TObject);
begin
  MidiInBuffer.Free;
  MidiEventRecorder.Free;
end;

procedure TMidiRecorder.cbxTaktChange(Sender: TObject);
begin
  Header.measureFact := cbxTakt.ItemIndex + 2;
  MidiInBuffer.Header := Header;
end;

procedure TMidiRecorder.cbxViertelChange(Sender: TObject);
var
  q: integer;
begin
  case cbxViertel.ItemIndex of
    0: q := 4;
    1: q := 8;
    else q := 4;
  end;
  Header.MeasureDiv :=  q;
  MidiInBuffer.Header := Header;
end;

procedure TMidiRecorder.edtBPMExit(Sender: TObject);
begin
  Header.QuarterPerMin := StrToInt(edtBPM.Text);
  cbxViertelChange(Sender);
end;

procedure TMidiRecorder.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  cbxMetronom.Checked := false;
  MidiInput.CloseAll;
end;

procedure TMidiRecorder.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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

procedure TMidiRecorder.FormCreate(Sender: TObject);
var
  Bank: TArrayOfString;
begin
  MidiEventRecorder := TMidiEventRecorder.Create;
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
  MidiInBuffer := TMidiInRingBuffer.Create(Header);
  btnStart.Caption := strStart;
  edtBPMExit(nil);
  sbMetronomChange(sbMetronom);
  sbMetronomChange(sbMetronom1);
  CopyBank(Bank, @bank_list);
  CopyArray(cbxDiskantBank, Bank);
  {$if defined(CPU64) or defined(WIN64)}
    {$ifdef fpc}
      Caption := Caption + ' (Lazarus 64)';
    {$else}
      Caption := Caption + ' (64)';
    {$endif}
  {$else}
    {$ifdef fpc}
      Caption := Caption + ' (Lazarus 32)';
    {$else}
      Caption := Caption + ' (32)';
    {$endif}
  {$endif}
end;

end.
