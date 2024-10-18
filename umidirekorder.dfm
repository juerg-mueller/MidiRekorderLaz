object MidiGriff: TMidiGriff
  Left = 1222
  Top = 573
  Caption = 'MIDI Rekorder'
  ClientHeight = 411
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 13
  object gbMIDI: TGroupBox
    Left = 0
    Top = 0
    Width = 536
    Height = 168
    Align = alTop
    Caption = 'MIDI'
    TabOrder = 0
    ExplicitWidth = 532
    DesignSize = (
      536
      168)
    object Label17: TLabel
      Left = 35
      Top = 72
      Width = 83
      Height = 13
      Caption = 'Synthesizer (out)'
    end
    object lblKeyboard: TLabel
      Left = 35
      Top = 34
      Width = 69
      Height = 13
      Caption = 'Harmonika (in)'
    end
    object lbVolume: TLabel
      Left = 35
      Top = 115
      Width = 42
      Height = 13
      Caption = 'lbVolume'
    end
    object btnStart: TButton
      Left = 415
      Top = 66
      Width = 114
      Height = 25
      Caption = 'Aufnahme starten'
      TabOrder = 0
      OnClick = btnStartClick
    end
    object cbxMidiInput: TComboBox
      Left = 135
      Top = 27
      Width = 266
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnChange = cbxMidiInputChange
      ExplicitWidth = 262
    end
    object cbxMidiOut: TComboBox
      Left = 135
      Top = 65
      Width = 266
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      OnChange = cbxMidiOutChange
      ExplicitWidth = 262
    end
    object sbMetronom1: TScrollBar
      Left = 135
      Top = 113
      Width = 261
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Max = 140
      Min = 20
      PageSize = 0
      Position = 100
      TabOrder = 3
      OnChange = sbMetronomChange
      ExplicitWidth = 257
    end
  end
  object gbHeader: TGroupBox
    Left = 0
    Top = 261
    Width = 536
    Height = 150
    Align = alBottom
    Caption = 'Taktangaben'
    TabOrder = 1
    ExplicitTop = 260
    ExplicitWidth = 532
    DesignSize = (
      536
      150)
    object Label8: TLabel
      Left = 35
      Top = 19
      Width = 21
      Height = 13
      Caption = 'Takt'
    end
    object Label12: TLabel
      Left = 35
      Top = 46
      Width = 84
      Height = 13
      Caption = 'Viertel pro Minute'
    end
    object Label2: TLabel
      Left = 35
      Top = 104
      Width = 48
      Height = 13
      Caption = 'Metronom'
    end
    object lbBegleitung: TLabel
      Left = 35
      Top = 82
      Width = 51
      Height = 13
      Caption = 'Lautst'#228'rke'
    end
    object Label10: TLabel
      Left = 35
      Top = 125
      Width = 41
      Height = 13
      Caption = 'Nur Takt'
    end
    object cbxViertel: TComboBox
      Left = 211
      Top = 13
      Width = 70
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Viertel'
      OnChange = cbxViertelChange
      Items.Strings = (
        'Viertel'
        'Achtel')
    end
    object cbxTakt: TComboBox
      Left = 135
      Top = 13
      Width = 70
      Height = 21
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 0
      Text = '4'
      OnChange = cbxTaktChange
      Items.Strings = (
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12')
    end
    object edtBPM: TEdit
      Left = 135
      Top = 40
      Width = 70
      Height = 21
      Alignment = taRightJustify
      TabOrder = 2
      Text = '120'
      OnExit = edtBPMExit
    end
    object cbxMetronom: TCheckBox
      Left = 135
      Top = 102
      Width = 20
      Height = 19
      TabOrder = 4
      OnClick = cbxMetronomClick
    end
    object sbMetronom: TScrollBar
      Left = 135
      Top = 82
      Width = 266
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Max = 120
      Min = 20
      PageSize = 0
      Position = 80
      TabOrder = 3
      OnChange = sbMetronomChange
      ExplicitWidth = 262
    end
    object cbxNurTakt: TCheckBox
      Left = 135
      Top = 123
      Width = 20
      Height = 19
      TabOrder = 5
      OnClick = cbxNurTaktClick
    end
  end
  object gbMidiInstrument: TGroupBox
    Left = 0
    Top = 168
    Width = 536
    Height = 93
    Align = alClient
    Caption = 'MIDI Instrument'
    TabOrder = 2
    ExplicitWidth = 532
    ExplicitHeight = 92
    object Label3: TLabel
      Left = 35
      Top = 52
      Width = 79
      Height = 13
      Caption = 'MIDI Instrument'
    end
    object Label4: TLabel
      Left = 35
      Top = 15
      Width = 23
      Height = 13
      Caption = 'Bank'
    end
    object cbxMidiDiskant: TComboBox
      Left = 135
      Top = 49
      Width = 264
      Height = 21
      Style = csDropDownList
      ItemIndex = 21
      TabOrder = 0
      Text = '22 Accordion'
      OnChange = cbxDiskantBankChange
      Items.Strings = (
        '1 Acoustic Grand Piano (Fl'#195#188'gel)'
        '2 Bright Acoustic Piano (Klavier)'
        '3 Electric Grand Piano'
        '4 Honky-tonk'
        '5 Electric Piano 1 (Rhodes)'
        '6 Electric Piano 2 (Chorus)'
        '7 Harpsichord (Cembalo)'
        '8 Clavi (Clavinet)'
        '9 Celesta'
        '10 Glockenspiel'
        '11 Music Box (Spieluhr)'
        '12 Vibraphone'
        '13 Marimba'
        '14 Xylophone'
        '15 Tubular Bells (R'#195#182'hrenglocken)'
        '16 Dulcimer (Hackbrett)'
        '17 Drawbar Organ (Hammond)'
        '18 Percussive Organ'
        '19 Rock Organ'
        '20 Church Organ (Kirchenorgel)'
        '21 Reed Organ (Drehorgel)'
        '22 Accordion'
        '23 Harmonica'
        '24 Tango Accordion (Bandeon)'
        '25 Acoustic Guitar (Nylon)'
        '26 Acoustic Guitar (Steel - Stahl)'
        '27 Electric Guitar (Jazz)'
        '28 Electric Guitar (clean - sauber)'
        '29 Electric Guitar (muted - ged'#195#164'mpft)'
        '30 Overdriven Guitar ('#195#188'bersteuert)'
        '31 Distortion Guitar (verzerrt)'
        '32 Guitar harmonics (Harmonien)'
        '33 Acoustic Bass'
        '34 Electric Bass (finger)'
        '35 Electric Bass (pick - gezupft)'
        '36 Fretless Bass (bundloser Bass)'
        '37 Slap Bass 1'
        '38 Slap Bass 2'
        '39 Synth Bass 1'
        '40 Synth Bass 2'
        '41 Violin (Violine - Geige)'
        '42 Viola (Viola - Bratsche)'
        '43 Cello (Violoncello - Cello)'
        '44 Contrabass (Violone - Kontrabass)'
        '45 Tremolo Strings'
        '46 Pizzicato Strings'
        '47 Orchestral Harp (Harfe)'
        '48 Timpani (Pauke)'
        '49 String Ensemble 1'
        '50 String Ensemble 2'
        '51 SynthString 1'
        '52 SynthString 2'
        '53 Choir Aahs'
        '54 Voice Oohs'
        '55 Synth Voice'
        '56 Orchestra Hit'
        '57 Trumpet (Trompete)'
        '58 Trombone (Posaune)'
        '59 Tuba'
        '60 Muted Trumpet (ged'#195#164'mpfe Trompete)'
        '61 French Horn (franz'#195#182'sisches Horn)'
        '62 Brass Section (Bl'#195#164'sersatz)'
        '63 SynthBrass 1'
        '64 SynthBrass 2'
        '65 Soprano Sax'
        '66 Alto Sax'
        '67 Tenor Sax'
        '68 Baritone Sax'
        '69 Oboe'
        '70 English Horn'
        '71 Bassoon (Fagott)'
        '72 Clarinet'
        '73 Piccolo'
        '74 Flute (Fl'#195#182'te)'
        '75 Recorder (Blockfl'#195#182'te)'
        '76 Pan Flute'
        '77 Blown Bottle'
        '78 Shakuhachi'
        '79 Whistle (Pfeifen)'
        '80 Ocarina'
        '81 Square (Rechteck)'
        '82 Sawtooth (S'#195#164'gezahn)'
        '83 Calliop'
        '84 Chiff'
        '85 Charang'
        '86 Voice'
        '87 Fifths'
        '88 Bass + Lead'
        '89 New Age'
        '90 Warm'
        '91 Polysynth'
        '92 Choir'
        '93 Bowed (Streicher)'
        '94 Metallic'
        '95 Halo'
        '96 Sweep'
        '97 Rain (Regen)'
        '98 Soundtrack'
        '99 Crystal'
        '100 Atmosphere'
        '101 Brightness'
        '102 Goblins'
        '103 Echoes'
        '104 Sci-Fi (Science Fiction)'
        '105 Sitar Ethnik'
        '106 Banjo'
        '107 Shamisen'
        '108 Koto'
        '109 Kalimba'
        '110 Bag Pipe (Dudelsack)'
        '111 Fiddle'
        '112 Shanai'
        '113 Tinkle Bell (Glocke)'
        '114 Agogo'
        '115 Steel Drums'
        '116 Woodblock'
        '117 Taiko Drum'
        '118 Melodic Tom'
        '119 Synth Drum'
        '120 Reverse Cymbal (Becken r'#195#188'ckw'#195#164'rts)'
        '121 Guitar Fret. Noise (Gitarrensaitenquitschen)'
        '122 Breath Noise (Atem)'
        '123 Seashore (Meeresbrandung)'
        '124 Bird Tweet (Vogelgezwitscher)'
        '125 Telephone Ring'
        '126 Helicopter'
        '127 Applause'
        '128 Gun Shot (Gewehrschuss)')
    end
    object cbxDiskantBank: TComboBox
      Left = 135
      Top = 6
      Width = 264
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = '00 - General Midi'
      OnChange = cbxDiskantBankChange
      Items.Strings = (
        '00 - General Midi'
        '01 - Piano'
        '02 - E-Piano'
        '03 - Organ'
        '04 - Organ - Drawbar Registrations'
        '05 - Perc. Tuned Instr.'
        '06 - String Instr.'
        '07 - Guitar'
        '08 - Harmonica and more'
        '09 - Full Strings & Disco Strings'
        '10 - Solo Strings'
        '11 - Synth Strings'
        '12 - Brass Solo'
        '13 - Brass Section'
        '14 - Classic Brass'
        '15 - Saxophon'
        '16 - Winds'
        '17 - Classic Winds'
        '18 - Choir'
        '19 - Bass'
        '20 - Synthesizer'
        '21 - FX und Percussion'
        '22'
        '23'
        '24'
        '25'
        '26'
        '27'
        '28'
        '29'
        '30'
        '31'
        '32'
        '33'
        '34'
        '35'
        '36'
        '37'
        '38'
        '39'
        '40 - Accordion French, German, Slvenia and others'
        '41 - Bass and Chord Melo.'
        '42 - Cordovox'
        '43'
        '44'
        '45'
        '46'
        '47'
        '48'
        '49'
        '50'
        '51'
        '52'
        '53'
        '54'
        '55'
        '56'
        '57'
        '58'
        '59'
        '60'
        '61'
        '62'
        '63'
        '64'
        '65'
        '66'
        '67'
        '68'
        '69'
        '70')
    end
  end
  object SaveDialog1: TSaveDialog
    FileName = 'Recorded.mid'
    Filter = 'MIDI|*.mid'
    InitialDir = '.'
    Left = 480
    Top = 24
  end
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
    Left = 416
    Top = 16
  end
end
