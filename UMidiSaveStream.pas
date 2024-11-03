//
// Copyright (C) 2020 J�rg M�ller, CH-5524
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see http://www.gnu.org/licenses/ .
//

unit UMidiSaveStream;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$ifdef FPC}
  LCLIntf, LCLType, LMessages,
{$endif}
  Classes, SysUtils,
  UMyMidiStream, UMidiDataStream, UMidiEvent, syncobjs;

type
  TMidiRecord = class
  private
    CriticalMidiIn: syncobjs.TCriticalSection;
  public
    eventCount: integer;
    MidiEvents: array of TMidiEvent;
    hasOns: boolean;
    OldTime: double;
    Header: TDetailHeader;

    constructor Create(const Head: TDetailHeader);
    destructor Destroy; override;
    procedure OnMidiInData(Status, Data1, Data2: byte; Timestamp: integer);
    function DeleteBends: boolean;
  end;

  TMidiSaveStream = class(TMidiDataStream)   //(TMyMidiStream)
  public
      Title: string;
      trackOffset: cardinal;
      constructor Create;
      procedure SetHead(DeltaTimeTicks: integer = 192);
      procedure AppendTrackHead(delay: integer = 0);
      procedure AppendHeaderMetaEvents(const Details: TDetailHeader);
      procedure AppendTrackEnd(IsLastTrack: boolean);
      procedure AppendEvent(const Event: TMidiEvent); overload;
      procedure AppendEvent(command, d1, d2: byte); overload;
      procedure AppendMetaEvent(EventNr: byte; b: AnsiString);
      class function BuildSaveStream(var MidiRec: TMidiRecord): TMidiSaveStream;
  end;

var
  pipFirst: byte = 76; //36; //59;
  pipSecond: byte = 77; //50; //69;

implementation

function TMidiRecord.DeleteBends: boolean;
var i, k: integer;
begin
  result := false;
  i := 0;
  k := 0;
  while i < eventCount do
  begin
    if (MidiEvents[i].command = $E0) and (MidiEvents[i].var_len = 0) then
      result := true
    else begin
      if i <> k then
        MidiEvents[k] := MidiEvents[i];
      inc(k);
    end;
    inc(i);
  end;
  if result then
    eventCount := k;
end;

constructor TMidiRecord.Create(const Head: TDetailHeader);
begin
  CriticalMidiIn := TCriticalSection.Create;
  eventCount := 0;
  SetLength(MidiEvents, 1000000);
  hasOns := false;
  OldTime := -1;
  Header := Head;
end;

destructor TMidiRecord.Destroy;
begin
  SetLength(MidiEvents, 0);
  CriticalMidiIn.Free;
end;

procedure TMidiRecord.OnMidiInData(Status, Data1, Data2: byte; Timestamp: integer);
var
  Event: TMidiEvent;
  time, delta: TDateTime;
  Ticks: integer;
begin
  CriticalMidiIn.Acquire;
  try
    if eventCount >= Length(MidiEvents)-1 then
      SetLength(MidiEvents, 2*Length(MidiEvents));

    time := Now;
    if eventCount = 0 then
      OldTime := time;
    Event.Clear;
    Event.command := Status;
    if Event.Event = 9 then
      hasOns := true;
    Event.d1 := Data1;
    Event.d2 := Data2;
    MidiEvents[eventCount] := Event;
    delta := 24*3600000.0*(time - OldTime); // ms
    Ticks := Header.MsDelayToTicks(delta);
    if eventCount > 0 then
      MidiEvents[eventCount-1].var_len := Ticks;
    delta := Header.TicksToMs(Ticks)/(24*3600000.0);
    OldTime := OldTime + delta;
    inc(eventCount);
  finally
    CriticalMidiIn.Release;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

constructor TMidiSaveStream.Create;
begin
  inherited;

  BigEndian := true;
  Title := '';
end;

procedure TMidiSaveStream.AppendMetaEvent(EventNr: byte; b: AnsiString);
var
  i,  l: integer;
begin
  l := Length(b);
  WriteByte($ff);
  WriteByte(EventNr);
  WriteByte(l);
  if l > 0 then
  begin
    for i := 1 to l do
      WriteByte(byte(b[i]));
    WriteByte(0);
  end;
end;

procedure TMidiSaveStream.SetHead(DeltaTimeTicks: integer = 192);
begin
  Position := 0;
  WriteAnsiString('MThd');
  WriteCardinal(6);
  WriteWord(1);              // file format                          + 8
  WriteWord(0);              // track count                          + 10
  WriteWord(DeltaTimeTicks); // delta time ticks per quarter note    + 12
end;

procedure TMidiSaveStream.AppendHeaderMetaEvents(const Details: TDetailHeader);
begin
  AppendMetaEvent($51, Details.GetMetaBeats51);
  if (Details.CDur <> 0) or Details.Minor then
    AppendMetaEvent($59, Details.GetMetaDurMinor59);
  AppendMetaEvent($58, Details.GetMetaMeasure58);
end;

procedure TMidiSaveStream.AppendTrackHead(delay: integer);
var
  count: word;
begin
  WriteAnsiString('MTrk');
  trackOffset := Position;
  WriteCardinal(0);           // chunck size
  WriteVariableLen(delay);
  count := GetWord(10) + 1;
  SetWord(count, 10); // increment track count
  if (count = 1) and (Length(Title) > 0) then
    AppendMetaEvent(2, AnsiString(Title)); // Copyright
end;

procedure TMidiSaveStream.AppendTrackEnd(IsLastTrack: boolean);
begin
  AppendMetaEvent($2f, '');
  SetCardinal(position - trackOffset - 4, trackOffset);
  if IsLastTrack then
    SetSize(Position);
end;

procedure TMidiSaveStream.AppendEvent(const Event: TMidiEvent);
var
  b: byte;
  i: integer;
  var_len: integer;
begin
  AppendEvent(Event.command, Event.d1, Event.d2);
  var_len := Event.var_len;
  if var_len < 0 then
    var_len := 0;
  if Event.Event = $f then
  begin
    b := Length(Event.bytes);
    WriteByte(b);
    if b > 0 then
    begin
      for i := 0 to b-1 do
        WriteByte(Event.bytes[i]);
      WriteVariableLen(var_len);
    end;
  end else
    WriteVariableLen(var_len);
end;

procedure TMidiSaveStream.AppendEvent(command, d1, d2: byte);
begin
  WriteByte(command);
  WriteByte(d1);
  if (Command shr 4) in [8..11,14] then
    WriteByte(d2);
end;

class function TMidiSaveStream.BuildSaveStream(var MidiRec: TMidiRecord): TMidiSaveStream;
var
  i, k, j, newCount: integer;
  SaveStream: TMidiSaveStream;
begin
  result := nil;
  if not MidiRec.hasOns then
    exit;

//  MidiRec.DeleteBends;

  // Stream bereinigen
  k := 0;
  newCount := 0;
  while (k < MidiRec.eventCount) do
  begin
    if // not (MidiRec.MidiEvents[k].Event in [8, 9]) or
       (MidiRec.MidiEvents[k].Channel <> 9) or
       (MidiRec.MidiEvents[k].d1 <> pipSecond) then       // Zwischentakte entfernen (pipSecond)
    begin
      if newCount <> k then
        MidiRec.MidiEvents[newCount] := MidiRec.MidiEvents[k];
      inc(newCount);
    end else
    if newCount > 0 then    
      inc(MidiRec.MidiEvents[newCount-1].var_len, MidiRec.MidiEvents[k].var_len);
    inc(k);
  end;
  if newCount < MidiRec.eventCount then
    MidiRec.eventCount := newCount;

  newCount := 0;
  while (newCount < MidiRec.eventCount) and (MidiRec.MidiEvents[newCount].Event = 12) do  // Instrumente w�hlen
  begin
    MidiRec.MidiEvents[newCount].var_len := 0;
    inc(newCount);
  end;

  i := newCount;
  k := i;
  while (k < MidiRec.eventCount) and (MidiRec.MidiEvents[k].Event <> 9) do
    inc(k);

  if (k < MidiRec.eventCount) and (MidiRec.MidiEvents[k].Channel = 9) then begin
    for j := newCount to k-1 do
      MidiRec.MidiEvents[j].var_len := 0;
  end;
{
  while (i < MidiRec.eventCount-2) and
        MidiRec.MidiEvents[i].IsSustain and MidiRec.MidiEvents[i+1].IsSustain do
    inc(i);

  while (i < MidiRec.eventCount) and MidiRec.MidiEvents[MidiRec.eventCount-1].IsSustain do
    dec(MidiRec.eventCount);


  inpush := true;
  while i < MidiRec.eventCount do
  begin
    isEvent := MidiRec.MidiEvents[i].IsSustain;
    if not isEvent or (inpush <> (MidiRec.MidiEvents[i].d2 <> 0)) then
    begin
      if isEvent then
        inpush := (MidiRec.MidiEvents[i].d2 <> 0);
      MidiRec.MidiEvents[newCount] := MidiRec.MidiEvents[i];
      inc(newCount);
    end;
  {$ifdef CONSOLE}
   // writeln(newCount, '  ', MidiEvents[i].command, '  ', MidiEvents[i].d1, '  ', MidiEvents[i].d2);
//  {$endif}
//    inc(i);

//  end;

  SaveStream := TMidiSaveStream.Create;
  try
    SaveStream.SetSize(6*newCount + 10000);
    SaveStream.Title := 'juerg5524.ch';
    SaveStream.SetHead;
    SaveStream.AppendTrackHead(0);
    SaveStream.AppendHeaderMetaEvents(MidiRec.Header);
    SaveStream.AppendTrackEnd(false);
    SaveStream.AppendTrackHead(0);
    for i := 0 to MidiRec.eventCount-1 do
      SaveStream.AppendEvent(MidiRec.MidiEvents[i]);
    SaveStream.AppendTrackEnd(true);
    result := SaveStream;
  except
    SaveStream.Free;
  end;

end;


initialization

finalization

end.
