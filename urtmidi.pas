
unit urtmidi;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$ifdef LINUX}
  dynlibs,
{$endif}
  SysUtils,
{$ifndef FPC}
  Windows,
  Forms, Dialogs,
{$endif}
  UBanks;

type
  Tarr = array[0..128] of char;

  RtMidiWrapper = record
    ptr_: pointer;
    data: pointer;
    ok: boolean;
    msg: PChar;
  end;
  PRtMidiWrapper = ^RtMidiWrapper;

  RtMidiPtr = PRtMidiWrapper;
  RtMidiInPtr = PRtMidiWrapper;
  RtMidiOutPtr = PRtMidiWrapper;

  RtMidiApi =
    (
      RT_MIDI_API_UNSPECIFIED,    //*!< Search for a working compiled API. */
      RT_MIDI_API_MACOSX_CORE,    //*!< Macintosh OS-X Core Midi API. */
      RT_MIDI_API_LINUX_ALSA,     //*!< The Advanced Linux Sound Architecture API. */
      RT_MIDI_API_UNIX_JACK,      //*!< The Jack Low-Latency MIDI Server API. */
      RT_MIDI_API_WINDOWS_MM,     //*!< The Microsoft Multimedia MIDI API. */
      RT_MIDI_API_WINDOWS_KS,     //*!< The Microsoft Kernel Streaming MIDI API. */
      RT_MIDI_API_RTMIDI_DUMMY    //*!< A compilable but non-functional API. */
    );

  RtMidiErrorType =
    (
      RT_ERROR_WARNING, RT_ERROR_DEBUG_WARNING, RT_ERROR_UNSPECIFIED, RT_ERROR_NO_DEVICES_FOUND,
      RT_ERROR_INVALID_DEVICE, RT_ERROR_MEMORY_ERROR, RT_ERROR_INVALID_PARAMETER, RT_ERROR_INVALID_USE,
      RT_ERROR_DRIVER_ERROR, RT_ERROR_SYSTEM_ERROR, RT_ERROR_THREAD_ERROR
    );

  RtMidiCCallback = procedure(TimeStamp: double; const message: PChar; userData: pointer); cdecl;

  //! Returns the size (with sizeof) of a RtMidiApi instance.
  rtmidi_sizeof_rtmidi_api = function: integer; cdecl;


  // Determine the available compiled MIDI APIs.
  // If the given `apis` parameter is null, returns the number of available APIs.
  // Otherwise, fill the given apis array with the RtMidi::Api values.
  //
  // \param apis  An array or a null value.
  //
  rtmidi_get_compiled_api = function({enum RtMidiApi **} apis: pointer): integer; cdecl; // return length for NULL argument.

  // Report an error.
  rtmidi_error = procedure(type_: RtMidiErrorType; const errorString: PChar); cdecl;

  // Open a MIDI port.
  //
  // \param port      Must be greater than 0
  // \param portName  Name for the application port.
  //
  rtmidi_open_port = procedure(device: RtMidiPtr; portNumber: integer; portName: PChar);

  // Creates a virtual MIDI port to which other software applications can
  // connect.
  //
  // \param portName  Name for the application port.
  //
  rtmidi_open_virtual_port = procedure(device: RtMidiPtr; const portName: PChar); cdecl;

  rtmidi_close_port = procedure (device: RtMidiPtr); cdecl;

  // Return the number of available MIDI ports.
  rtmidi_get_port_count = function (device: RtMidiPtr): integer; cdecl;

  // Return a string identifier for the specified MIDI input port number.
  rtmidi_get_port_name = function (device: RtMidiPtr; portNumber: integer; var bufOut: Tarr; var buffLen: integer): integer; cdecl;


  // Create a default RtMidiInPtr value, with no initialization.
  // RTMIDIAPI RtMidiInPtr rtmidi_in_create_default ();

  // Create a  RtMidiInPtr value, with given api, clientName and queueSizeLimit.
  //
  //  \param api            An optional API id can be specified.
  //  \param clientName     An optional client name can be specified. This
  //                        will be used to group the ports that are created
  //                        by the application.
  //  \param queueSizeLimit An optional size of the MIDI input queue can be
  //                        specified.
  //
  rtmidi_in_create = function(api: RtMidiApi; const clientName: PChar; queueSizeLimit: integer): RtMidiInPtr; cdecl;

  rtmidi_in_free = procedure (device: RtMidiInPtr); cdecl;

  // Returns the MIDI API specifier for the given instance of RtMidiIn.
  rtmidi_in_get_current_api = function(device: RtMidiPtr): RtMidiApi; cdecL;

  // Set a callback function to be invoked for incoming MIDI messages.
  rtmidi_in_set_callback = procedure(device: RtMidiInPtr; callback: RtMidiCCallback; userData: pointer); cdecl;

  // Cancel use of the current callback function (if one exists).
  rtmidi_in_cancel_callback = procedure(device: RtMidiInPtr); cdecl;

  // Specify whether certain MIDI message types should be queued or ignored during input.
  rtmidi_in_ignore_types = procedure(device: RtMidiInPtr; midiSysex, midiTime, midiSense: boolean); cdecl;

  // Fill the user-provided array with the data bytes for the next available
  // MIDI message in the input queue and return the event delta-time in seconds.
  //
  // \param message   Must point to a char* that is already allocated.
  //                  SYSEX messages maximum size being 1024, a statically
  //                  allocated array could
  //                  be sufficient.
  // \param size      Is used to return the size of the message obtained.
  //
  // RTMIDIAPI double rtmidi_in_get_message (RtMidiInPtr device, unsigned char **message, size_t * size);


///////////////////////////////////////////////////////////////////////////////////////////////////////////

// Create a default RtMidiInPtr value, with no initialization.
// RTMIDIAPI RtMidiOutPtr rtmidi_out_create_default ();

// Create a RtMidiOutPtr value, with given and clientName.
//
//  \param api            An optional API id can be specified.
//  \param clientName     An optional client name can be specified. This
//                        will be used to group the ports that are created
//                        by the application.
//
  rtmidi_out_create = function(api: RtMidiApi; const clientName: PChar): RtMidiOutPtr; cdecl;

// Deallocate the given pointer.
  rtmidi_out_free = procedure(device: RtMidiOutPtr); cdecl;

// Returns the MIDI API specifier for the given instance of RtMidiOut.
// RTMIDIAPI enum RtMidiApi rtmidi_out_get_current_api (RtMidiPtr device);

// Immediately send a single message out an open MIDI output port.
 rtmidi_out_send_message = function(device: RtMidiOutPtr; const message: PByte; length: integer): integer; cdecl;

 TMidiOutput = class
   device: integer;
   DeviceNames: array of string;

   constructor Create;
   destructor Destroy; override;
   procedure CloseAll;
   procedure GenerateList;
   procedure Open(index: integer);
   procedure Close();
   procedure Send(command, d1, d2: byte);
   procedure Reset;
 end;

  TMidiInput = class
    OnMidiInData: RtMidiCCallback;
    device: integer;
    DeviceNames: array of string;

    constructor Create;
    destructor Destroy; override;
    procedure CloseAll;
    procedure GenerateList;
    procedure Open(index: integer; userData: pointer);
    procedure Close();
  end;

var
  MicrosoftIndex: integer = -1;
  MidiOutput: TMidiOutput;
  MidiInput: TMidiInput;
  MidiInstr: byte = 21; // Akkordeon


implementation

var
{$ifdef FPC}
  hndLib: TLibHandle = 0;
{$else}
  hndLib: HMODULE = 0;
{$endif}
  prtmidi_in_create: rtmidi_in_create = nil;
  prtmidi_in_free: rtmidi_in_free = nil;
  prtmidi_in_set_callback: rtmidi_in_set_callback = nil;

  prtmidi_out_create: rtmidi_out_create = nil;
  prtmidi_out_free: rtmidi_out_free = nil;
  prtmidi_out_send_message: rtmidi_out_send_message = nil;

  prtmidi_open_port: rtmidi_open_port = nil;
  prtmidi_close_port: rtmidi_close_port = nil;
  prtmidi_open_virtual_port: rtmidi_open_virtual_port = nil;
  prtmidi_get_port_count: rtmidi_get_port_count = nil;
  prtmidi_get_port_name: rtmidi_get_port_name = nil;

  prtmidi_in_cancel_callback: rtmidi_in_cancel_callback = nil;
  prtmidi_in_ignore_types: rtmidi_in_ignore_types = nil;

  handle_out: RtMidiOutPtr;
  handle_in: RtMidiInPtr;


////////////////////////////////////////////////////////////////////////////////


constructor TMidiOutput.Create;
begin
  device := -1;
  SetLength(DeviceNames, 0);
end;

destructor TMidiOutput.Destroy;
begin
  CloseAll;
end;

procedure TMidiOutput.CloseAll;
begin
  Close;
end;

procedure TMidiOutput.Open(index: integer);
begin
  if (index <> device) and (index >= 0) then
    Close;
  if index >= 0 then
  begin
    prtmidi_open_port(handle_out, index, '');
    device := index;
  end;
end;

procedure TMidiOutput.Close();
begin
  if device >= 0 then
    prtmidi_close_port(handle_out);
  device := -1;
end;

procedure TMidiOutput.GenerateList;
var
  i, k, count: integer;
  c: Tarr;
begin
  count := prtmidi_get_port_count(handle_out);
  SetLength(DeviceNames, count);
{$ifdef CONSOLE}
  writeln('MIDI output:');
{$endif}
  for i := 0 to count-1 do
  begin
    c[0] := #0;
    k := High(c);
    prtmidi_get_port_name(handle_out, i, c, k);
    DeviceNames[i] := c;
  {$ifdef CONSOLE}
    writeln(c);
  {$endif}
  end;
end;

procedure TMidiOutput.Send(command, d1, d2: byte);
var
  c: array[0..3] of byte;
  len: integer;
begin
  if Device >= 0 then
  begin
    c[0] := command;
    c[1] := d1;
    c[2] := d2;
    c[3] := 0;
    len := 3;
    if (command shr 4) = 12 then
      len := 2;
    prtmidi_out_send_message(handle_out, @c, len);
  end;
end;

procedure TMidiOutput.Reset;
  var
    i: integer;
begin
  for i := 0 to 15 do
    begin
      Sleep(5);
      MidiOutput.Send($B0 + i, 120, 0);  // all sound off
    end;
  Sleep(5);
end;

procedure OpenMidiMicrosoft;
begin
  MidiOutput.Open(MicrosoftIndex);
  try
    MidiOutput.Reset;
    MidiOutput.Send($c0, MidiInstr, $00);
    MidiOutput.Send($c1, MidiInstr, $00);
    MidiOutput.Send($c2, MidiInstr, $00);
    MidiOutput.Send($c3, MidiInstr, $00);
    MidiOutput.Send($c4, MidiInstr, $00);
    MidiOutput.Send($c5, MidiInstr, $00);
    MidiOutput.Send($c6, MidiInstr, $00);
  finally
  end;
{$if defined(CONSOLE)}
  writeln('Midi Port-', MicrosoftIndex, ' opend');
{$endif}
end;

////////////////////////////////////////////////////////////////////////////////


constructor TMidiInput.Create;
begin
  device := -1;
  SetLength(DeviceNames, 0);
end;

destructor TMidiInput.Destroy;
begin
  Close;
end;

procedure TMidiInput.CloseAll;
begin
  Close;
end;

procedure TMidiInput.Open(index: integer; userData: pointer);
begin
  if (device >= 0) then
    Close;

  prtmidi_open_port(handle_in, index, '');

  if @OnMidiInData <> nil then
    prtmidi_in_set_callback(handle_in, OnMidiInData, userData);
end;

procedure TMidiInput.Close();
begin
  if handle_in <> nil then
    prtmidi_close_port(handle_in);
end;

procedure TMidiInput.GenerateList;
var
  i, k, Count: integer;
  c: Tarr;
begin
  Count := prtmidi_get_port_count(handle_in);
  SetLength(DeviceNames, Count);
{$ifdef CONSOLE}
  writeln('MIDI input:');
{$endif}
  for i := 0 to count-1 do
  begin
    c[0] := #0;
     k := High(c);
    prtmidi_get_port_name(handle_in, i, c, k);
    DeviceNames[i] := c;
  {$ifdef CONSOLE}
    writeln(c);
  {$endif}
  end;
end;

////////////////////////////////////////////////////////////////////////////////

const
{$ifdef LINUX}
  lib = '/usr/local/lib/librtmidi.so';
{$else}
  {$ifdef MACOS}
    lib = 'librtmidi.6.dylib';
  {$else}
    lib = 'rtmidilib.dll';
  {$endif}
{$endif}

{$ifndef FPC}
function GetProcedureAddress(hModule: HMODULE; name: LPCWSTR): FARPROC;
begin
  result := GetProcAddress(hModule, name);
end;
{$endif}

initialization

  MidiOutput := TMidiOutput.Create;
  MidiInput := TMidiInput.Create;

{$ifdef FPC}
  hndLib := LoadLibrary(PChar(lib));
  if hndLib <> NilHandle then
{$else}
  hndLib := LoadLibrary(lib);
  if hndLib <> 0 then
{$endif}
  begin
    prtmidi_open_port :=  GetProcedureAddress(hndLib, 'rtmidi_open_port');
    prtmidi_close_port :=  GetProcedureAddress(hndLib, 'rtmidi_close_port');
    prtmidi_open_virtual_port :=  GetProcedureAddress(hndLib, 'rtmidi_open_virtual_port');
    prtmidi_get_port_count :=  GetProcedureAddress(hndLib, 'rtmidi_get_port_count');
    prtmidi_get_port_name :=  GetProcedureAddress(hndLib, 'rtmidi_get_port_name');

    prtmidi_in_create :=  GetProcedureAddress(hndLib, 'rtmidi_in_create');
    prtmidi_in_free :=  GetProcedureAddress(hndLib, 'rtmidi_in_free');
    prtmidi_in_set_callback :=  GetProcedureAddress(hndLib, 'rtmidi_in_set_callback');

    prtmidi_out_create :=  GetProcedureAddress(hndLib, 'rtmidi_out_create');
    prtmidi_out_free :=  GetProcedureAddress(hndLib, 'rtmidi_out_free');
    prtmidi_out_send_message :=  GetProcedureAddress(hndLib, 'rtmidi_out_send_message');

    prtmidi_in_cancel_callback := GetProcedureAddress(hndLib, 'rtmidi_in_cancel_callback');
    prtmidi_in_ignore_types := GetProcedureAddress(hndLib, 'rtmidi_in_ignore_types');

    handle_out := prtmidi_out_create(RT_MIDI_API_LINUX_ALSA, 'MyMidi');
    handle_in := prtmidi_in_create(RT_MIDI_API_LINUX_ALSA, 'MyMidi', 100);

  end else begin
  {$ifdef CONSOLE}
    writeln('RTMidi-Bibliothek fehlt!');
  {$endif}
    halt;
  end;
finalization

  MidiOutput.Free;
  MidiInput.Free;
  if hndLib <> 0 then
  begin
    FreeLibrary(hndLib);
    prtmidi_in_free(handle_out);
    prtmidi_out_free(handle_in);
  end;
end.


