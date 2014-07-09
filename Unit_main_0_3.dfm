object Form1: TForm1
  Left = 170
  Top = 123
  AutoScroll = False
  Caption = 'CatchBall'
  ClientHeight = 510
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object Pole: TShape
    Left = 20
    Top = 20
    Width = 450
    Height = 450
    Pen.Color = clGreen
    Pen.Mode = pmMask
    Pen.Style = psDot
    OnMouseDown = PoleMouseDown
    OnMouseMove = PoleMouseMove
  end
  object paddle: TShape
    Left = 20
    Top = 20
    Width = 2
    Height = 80
    Pen.Color = clYellow
    Pen.Width = 2
  end
  object Intpaddle: TShape
    Left = 469
    Top = 20
    Width = 2
    Height = 80
    Pen.Color = clRed
    Pen.Width = 2
  end
  object ball: TShape
    Left = 225
    Top = 225
    Width = 20
    Height = 20
    Shape = stCircle
  end
  object playerScoreLabel: TLabel
    Left = 224
    Top = 488
    Width = 9
    Height = 16
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object computerScoreLabel: TLabel
    Left = 272
    Top = 488
    Width = 9
    Height = 16
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 168
    Top = 472
    Width = 161
    Height = 16
    Caption = #1057#1095#1105#1090': ('#1048#1075#1088#1086#1082':'#1050#1086#1084#1087#1100#1102#1090#1077#1088')'
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 472
  end
end
