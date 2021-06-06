UNIT Ueditimg;


INTERFACE

Uses
   Graph, Crt, MyMouse, Button, Rolls,
   Boxs, TextBoxs, RollBoxs, Objects,
   Labels, Config, Collects,
   UMenu, ImgDb, Canvas, Icones,
   UDialog, UNewFile;

TYPE
   Peditimg = ^Oeditimg;
   Oeditimg = Object (OBox)
      FileName : Str12;
      btClick  : Byte;
      MyDb     : OImgDb;
      Menu     : OMenu;
      MenuEdit : OMenu;
      ImgList  : ORollBox;
      Canv     : OCanvas;
      Colors   : ORollBox;
      lbEdit   : OLabel;
      lbCopy   : OLabel;
      lbImage  : OLabel;
      icEdit   : OIcon;
      icCopy   : OIcon;
      icImage  : OIcon;

      Constructor Init(tx : String; M : PMouse);
      Procedure   NewImage;
      Procedure   SaveImage;
      Procedure   DeleteImage;
      Procedure   Run; Virtual;
      Procedure   Show; Virtual;
      Procedure   Draw; Virtual;
      Destructor  Done;
   End;

IMPLEMENTATION

Constructor Oeditimg.Init(Tx : String; M : PMouse);

Var
   i       : Integer;
   istr    : String;
   icode   : ImgCode;
   iLevel  : Byte;

Begin
   FileName := tx;
   BtClick  := 0;

   OBox.Init(1, 1, 638, 478, False, 'Edicao do Arquivo de Imagens : '+FileName, True, M);

   Menu.Init(1, 16, 115, HORIZONTAL, 'Menu', False, Pointer);
   Menu.Add(1, True,  'Novo');
   Menu.Add(2, False, 'Editar');
   Menu.Add(3, False, 'Salvar');
   Menu.Add(4, False, 'Excluir');
   Menu.Add(5, True,  'Sair');
   Menu.Draw;

   MenuEdit.Init(1, 300, 70, VERTICAL, 'Editar', True, Pointer);
   MenuEdit.Add(1, True, 'Copiar');
   MenuEdit.Add(2, True, 'Colar');
   MenuEdit.Add(3, True, 'Apagar');
   MenuEdit.Add(4, True, 'Espelhar');
   MenuEdit.Draw;

   ImgList.Init(10, 55, 7, 15, 'Imagens', Pointer);

   MyDB.Init(FileName);

   While (MyDB.GetHeader(icode, iLevel)) Do
   Begin
      Str(iLevel, iStr);
      ImgList.Add(icode+'.'+iStr);
   End;

   ImgList.Draw;

   Canv.Init(200, 55, 16, 32, 10, '', Pointer);
   Canv.Draw;

   Colors.Init(420, 55, 2, 16, 'Cor', Pointer);

   Colors.Align := CENTER;
   For i := 0 To 15 Do
   Begin
      Str(i, istr);
      Colors.Add(istr);
   End;
   Colors.Draw;


   lbImage.Init(100,  55, 'Imagem', Pointer);
   lbEdit.Init (100, 155, 'Edicao', Pointer);
   lbCopy.Init (100, 255, 'Copia',  Pointer);

   icImage.Init(115,  90, 16, 32, Pointer);
   icEdit.Init (115, 190, 16, 32, Pointer);
   icCopy.Init (115, 290, 16, 32, Pointer);

   lbImage.Draw;
   lbEdit.Draw;
   lbCopy.Draw;
   icImage.Draw;
   icEdit.Draw;
   icCopy.Draw;
End;

Procedure Oeditimg.NewImage;

Var
   n : PNewFile;

Begin
   New(n, Init(400, 330, 7, Pointer));
   n^.Run;

   If (n^.btClick = OK) Then
      Canv.Text := n^.FileName;

   If (n^.FileName <> '') Then
   Begin
      Menu.ActiveItem(3, True);
      Canv.Clear;
      icEdit.Clear;
   End;

   Dispose(n, Done);
End;

Procedure OEditimg.SaveImage;

Var
   iCode   : ImgCode;
   iStr    : String;
   iLevel  : Byte;
   iSprite : ImgSprite;
   i, j, a : Integer;

Begin
   If (Canv.Text <> '') Then
   Begin
      a := 1;
      For j := 1 To icEdit.Height Do
      Begin
          For i := 1 To icEdit.Width Do
          Begin
             iSprite[a] := Canv.GetPixelColor(i, j);
             icImage.SetPixelColor(i, j, Canv.GetPixelColor(i, j));
             a := a+1;
          End;
      End;

      a := Pos('.', Canv.Text);
      If (a < 1) Then
      Begin
         iCode  := Canv.Text;
         iLevel := 0;
      End Else Begin
         iCode := Copy(Canv.Text, 1, a-1);
         Val(Canv.Text[a+1], iLevel, i);
         If (i <> 0) Then iLevel := 0;
      End;

      MyDB.Put(iCode, iLevel, iSprite);

      i := ImgList.GetPos;

      ImgList.Free;
      While (MyDB.GetHeader(icode, iLevel)) Do
      Begin
         Str(iLevel, iStr);
         ImgList.Add(icode+'.'+iStr);
      End;

      ImgList.SetPos(i);
      ImgList.Draw;
      icImage.Draw;
      Menu.ActiveItem(3, True);
      Menu.ActiveItem(4, True);
   End;
End;


Procedure OEditImg.DeleteImage;

Var
   dlg     : PDialog;
   i, a    : Integer;
   iCode   : ImgCode;
   iLevel  : Byte;
   istr    : String;

Begin
   New(dlg, Init(400, 330, 200, 100, True, 'Apagar', True, Pointer));
   dlg^.AddLine('Voce realmente desaja');
   dlg^.AddLine('apagar esta imagem?');
   dlg^.AddButton(70, 15, 'Confirma', OK);
   dlg^.AddButton(70, 15, 'Cancela', CANCEL);
   dlg^.Draw;
   dlg^.Run;
   If (dlg^.btClick = OK) Then
   Begin
      a := Pos('.', ImgList.Text);
      iCode := Copy(ImgList.Text, 1, a-1);
      Val(ImgList.Text[a+1], iLevel, i);
      icImage.Clear;
      MyDB.Cut(iCode, iLevel);
      Menu.ActiveItem(2, False);
      Menu.ActiveItem(3, False);
      Menu.ActiveItem(4, False);

      ImgList.Text := 'Imagens';
      i := ImgList.GetPos;
      ImgList.Free;
      MyDB.Resetdb;
      While (MyDB.GetHeader(icode, iLevel)) Do
      Begin
         Str(iLevel, iStr);
         ImgList.Add(icode+'.'+iStr);
      End;
      ImgList.SetPos(i-1);
      ImgList.Draw;
      icImage.Clear;
      icImage.Draw;
   End;
   dlg^.Clear;
   Dispose(dlg, Done);
End;


Procedure Oeditimg.Run;

Var
   ExitRepeat : Boolean;
   Color   : Byte;
   Code    : Integer;
   i, j, a : Integer;
   iCode   : ImgCode;
   iLevel  : Byte;
   iSprite : ImgSprite;

Begin
   ExitRepeat := False;
   Repeat
      OBox.Run;
      Menu.Run;
      MenuEdit.Run;
      ImgList.Run;
      Canv.Run;
      Colors.Run;
      lbImage.Run;
      lbEdit.Run;
      lbCopy.Run;
      icImage.Run;
      icEdit.Run;
      icCopy.Run;
      ScreenShow;

      {*** Menu Object Events ***}

      If (Menu.Selected) Then
      Begin
         Case (Menu.btClick) of
            1 : NewImage;
            2 : Begin
                   For j := 1 To icEdit.Height Do
                      For i := 1 To icEdit.Width Do
                      Begin
                         icEdit.SetPixelColor(i, j, icImage.GetPixelColor(i, j));
                         Canv.SetPixelColor(i, j, icImage.GetPixelColor(i, j));
                      End;
                   Menu.ActiveItem(3, True);
                   Canv.Text := ImgList.Text;
                End;
            3 : SaveImage;
            4 : DeleteImage;
            5 : ExitRepeat := True;
         End;
      End;

      {*** MenuEdit Object Events ***}

      If (MenuEdit.Selected) Then
      Begin
         Case (MenuEdit.btClick) of
            1 : Begin
                   For j := 1 To icEdit.Height Do
                      For i := 1 To icEdit.Width Do
                         icCopy.SetPixelColor(i, j, icEdit.GetPixelColor(i, j));
                   icCopy.Draw;
                End;
            2 : Begin
                   For j := 1 To icEdit.Height Do
                      For i := 1 To icEdit.Width Do
                      Begin
                         icEdit.SetPixelColor(i, j, icCopy.GetPixelColor(i, j));
                         Canv.SetPixelColor(i, j, icCopy.GetPixelColor(i, j));
                      End;
                   icCopy.Draw;
                   Canv.Draw;
                End;
            3 : Begin
                   icEdit.Clear;
                   Canv.Clear;
                End;
            4 : Begin
                   For j := 1 To icEdit.Height Do
                      For i := 1 To icEdit.Width Do
                         Canv.SetPixelColor(i, j, icEdit.GetPixelColor(icEdit.Width-i+1, j));
                   For j := 1 To icEdit.Height Do
                      For i := 1 To icEdit.Width Do
                         icEdit.SetPixelColor(i, j, Canv.GetPixelColor(i, j));
                   icEdit.Draw;
                   Canv.Draw;

                End;
         End;
      End;

      {*** Image Listting Object Events ***}

      If (ImgList.Selected) Then
      Begin
         ImgList.Text := ImgList.TextSelect;
         a := Pos('.', ImgList.Text);
         iCode := Copy(ImgList.TextSelect, 1, a-1);
         Val(ImgList.TextSelect[a+1], iLevel, i);

         If (MyDB.Get(iCode, iLevel, iSprite)) Then
         Begin
            a := 1;
            For j := 1 To icImage.Height Do
            Begin
               For i := 1 To icImage.Width Do
               Begin
                  icImage.SetPixelColor(i, j, iSprite[a]);
                  a := a+1;
               End;
            End;
            Menu.ActiveItem(2, True);
            Menu.ActiveItem(4, True);
         End;
         ImgList.Draw;
      End;

      {*** Colors Select Object Events ***}

      If(Colors.Selected) Then
      Begin
         Val(Colors.TextSelect, Color, Code);
         If (Code = 0) then
            Canv.SetCanvasColor(Color);
      End;

      {*** Canvas Object Events ***}

      If(Canv.Selected) Then
      Begin
         For j := 1 To icEdit.Height Do
            For i := 1 To icEdit.Width Do
               icEdit.SetPixelColor(i, j, Canv.GetPixelColor(i, j));
      End;
   Until (ExitRepeat);
End;

Procedure Oeditimg.Show;
Begin
   OBox.Show;
End;

Procedure Oeditimg.Draw;
Begin
   OBox.Draw;
   lbImage.Draw;
   lbEdit.Draw;
   lbCopy.Draw;
   icImage.Draw;
   icEdit.Draw;
   icCopy.Draw;
   Colors.Draw;
   Canv.Draw;
   ImgList.Draw;
   MenuEdit.Draw;
   Menu.Draw;
End;

Destructor Oeditimg.Done;
Begin
   MyDB.Done;
   lbImage.Done;
   lbEdit.Done;
   lbCopy.Done;
   icImage.Done;
   icEdit.Done;
   icCopy.Done;
   Colors.Done;
   Canv.Done;
   ImgList.Done;
   MenuEdit.Done;
   Menu.Done;
   OBox.Done;
End;

End.
