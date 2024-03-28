Unit uDatiDataset;

{$MODE DELPHI}{$H+}

Interface

Uses
  Classes,
  SysUtils,
  TypInfo,
  PropEdits,
  LResources,
  //*
  DB,
  ZAbstractConnection,
  ZConnection,
  ZDataset;

Type

  { TDatiDataset }

  TDatiDataset = Class(ZDataset.TZQuery)
  private
  Const
    FTableName = 'tbldati';
  private
    FConn: TZAbstractConnection;
    Function GetCreateTable: string;
    Procedure pBeforeConnect(Sender: TObject);
  public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;

    Procedure Open;
    //*
    Procedure SaveToFile(aFileName: string);
    Procedure SaveToStream(aStream: TStream);
    //*
    Procedure LoadFromFile(aFileName: string);
    Procedure LoadFromStream(aStream: TStream);
  published
    Property FieldDefs stored True;
  End;

Procedure Register;

Implementation

{$IFDEF FPC}
 Procedure UnlistPublishedProperty(ComponentClass: TPersistentClass; Const PropertyName: string);
 Var
   pi: PPropInfo;
 Begin
   pi := TypInfo.GetPropInfo(ComponentClass, PropertyName);
   If (pi <> nil) Then
     RegisterPropertyEditor(pi^.PropType, ComponentClass, PropertyName, PropEdits.THiddenPropertyEditor);
 End;
{$ENDIF}

Procedure Register;
Begin
  {$I uDatiDataset_icon.lrs}
  RegisterComponents('Datilas', [TDatiDataset]);
  UnlistPublishedProperty(TDatiDataset, 'Connection');
  UnlistPublishedProperty(TDatiDataset, 'Sequence');
  UnlistPublishedProperty(TDatiDataset, 'UpdateObject');
  UnlistPublishedProperty(TDatiDataset, 'SQL');
End;

{ TDatiDataset }

Function TDatiDataset.GetCreateTable: string;
Var
  sl: TStringList;
  i: integer;
  d: TFieldDef;
  f: TField;
Begin
  Self.Close;
  If Self.FieldDefs.Count > 0 Then
    Self.Fields.Clear;

  If ((Self.FieldDefs.Count < 1) and (Self.Fields.Count < 1)) Then
    Raise Exception.Create('No field to be created');

  sl := TStringList.Create;
  Try
    sl.Add('CREATE TABLE IF NOT EXISTS ' + FTableName + '(');

    For i := 0 To Pred(Self.Fields.Count) Do
    Begin
      f := Self.Fields[i];
      Case f.DataType Of
        ftUnknown: sl.Add(f.FieldName + ' BLOB,');
        ftString: sl.Add(f.FieldName + ' VARCHAR(' + f.Size.ToString + '),');
        ftSmallint: sl.Add(f.FieldName + ' SMALLINT,');
        ftInteger: sl.Add(f.FieldName + ' INTEGER,');
        ftWord: sl.Add(f.FieldName + ' INTEGER,');
        ftBoolean: sl.Add(f.FieldName + ' BOOLEAN,');
        ftFloat: sl.Add(f.FieldName + ' NUMERIC,');
        ftCurrency: sl.Add(f.FieldName + ' DECIMAL(16,6),');
        ftBCD: sl.Add(f.FieldName + ' NUMERIC,');
        ftDate, ftTime, ftDateTime: sl.Add(f.FieldName + ' DATETIME,');

        ftBytes, ftVarBytes, ftAutoInc: sl.Add(f.FieldName + ' INTEGER,');
        ftBlob, ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary,

        ftCursor, ftOraBlob, ftOraClob, ftVariant, ftInterface,
        ftDataSet: sl.Add(f.FieldName + ' BLOB,');

        ftMemo, ftWideMemo, ftFmtMemo: sl.Add(f.FieldName + ' LONGTEXT,');

        ftFixedChar: sl.Add(f.FieldName + ' CHAR(' + f.Size.ToString + '),');
        ftWideString: sl.Add(f.FieldName + ' VARCHAR(36),');
        ftLargeint: sl.Add(f.FieldName + ' BIGINT,');

        ftGuid: sl.Add(f.FieldName + ' VARCHAR(36),');
        ftTimeStamp: sl.Add(f.FieldName + ' DATETIME,');
        ftFMTBcd: sl.Add(f.FieldName + ' NUMERIC,');
        ftFixedWideChar: sl.Add(f.FieldName + ' CHAR(' + f.Size.ToString + '),');
      End;
    End;

    For i := 0 To Pred(Self.FieldDefs.Count) Do
    Begin
      d := Self.FieldDefs[i];
      Case d.DataType Of
        ftUnknown: sl.Add(d.Name + ' BLOB,');
        ftString: sl.Add(d.Name + ' VARCHAR(' + d.Size.ToString + '),');
        ftSmallint: sl.Add(d.Name + ' SMALLINT,');
        ftInteger: sl.Add(d.Name + ' INTEGER,');
        ftWord: sl.Add(d.Name + ' INTEGER,');
        ftBoolean: sl.Add(d.Name + ' BOOLEAN,');
        ftFloat: sl.Add(d.Name + ' NUMERIC,');
        ftCurrency: sl.Add(d.Name + ' DECIMAL(16,6),');
        ftBCD: sl.Add(d.Name + ' NUMERIC,');
        ftDate, ftTime, ftDateTime: sl.Add(d.Name + ' DATETIME,');

        ftBytes, ftVarBytes, ftAutoInc: sl.Add(d.Name + ' INTEGER,');
        ftBlob, ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary,

        ftCursor, ftOraBlob, ftOraClob, ftVariant, ftInterface,
        ftDataSet: sl.Add(d.Name + ' BLOB,');

        ftMemo, ftWideMemo, ftFmtMemo: sl.Add(d.Name + ' LONGTEXT,');

        ftFixedChar: sl.Add(d.Name + ' CHAR(' + d.Size.ToString + '),');
        ftWideString: sl.Add(d.Name + ' VARCHAR(36),');
        ftLargeint: sl.Add(d.Name + ' BIGINT,');

        ftGuid: sl.Add(d.Name + ' VARCHAR(36),');
        ftTimeStamp: sl.Add(d.Name + ' DATETIME,');
        ftFMTBcd: sl.Add(d.Name + ' NUMERIC,');
        ftFixedWideChar: sl.Add(d.Name + ' CHAR(' + f.Size.ToString + '),');
      End;
    End;

    Result := sl.Text;

    SetLength(Result, Result.Length - 3);
    Result := Result + ');';
  Finally
    sl.Clear;
    sl.Free;
    Self.FieldDefs.Clear;
    Self.Fields.Clear;
  End;
End;

Procedure TDatiDataset.pBeforeConnect(Sender: TObject);
Begin
  TZConnection(Sender).Protocol := 'sqlite-3';
  TZConnection(Sender).ClientCodepage := 'UTF-8';
  TZConnection(Sender).Database := ':memory:';
  TZConnection(Sender).Properties.Values['ExtendedErrorMessage'] := 'true';
End;

Constructor TDatiDataset.Create(AOwner: TComponent);
Begin
  FConn := TZConnection.Create(nil);
  FConn.BeforeConnect := pBeforeConnect;

  Inherited Create(AOwner);

  Self.Connection := FConn;
End;

Procedure TDatiDataset.Open;
Begin
  If self.Active Then Exit;

  If not FConn.Connected Then
    FConn.Connect;

  FConn.ExecuteDirect(GetCreateTable);
  //*
  self.Close;
  self.FieldDefs.Clear;
  self.Fields.Clear;
  self.SQL.Clear;
  self.SQL.Add('SELECT * FROM ' + FTableName);
  //*
  Inherited Open;
End;

Destructor TDatiDataset.Destroy;
Begin
  self.Close;
  FConn.Disconnect;
  FreeAndNil(FConn);

  Inherited Destroy;
End;

Procedure TDatiDataset.SaveToFile(aFileName: string);
Begin
  If self.Active Then
  Begin
    DeleteFile(aFileName);
    FConn.ExecuteDirect('VACUUM INTO "' + aFileName + '"');
  End
  Else
    Raise Exception.Create('DataSet is not active');
End;

Procedure TDatiDataset.SaveToStream(aStream: TStream);
Var
  sFile: string;
Begin
  sFile := '.' + PathDelim + FormatDateTime('"dati"hhnnsszzz', Now) + '.dati';
  Self.SaveToFile(sFile);
  Try
    TMemoryStream(aStream).Clear;
    TMemoryStream(aStream).Position := 0;
    TMemoryStream(aStream).LoadFromFile(sFile);
  Finally
    DeleteFile(sFile);
  End;
End;

Procedure TDatiDataset.LoadFromFile(aFileName: string);
Var
  qryFile: TZQuery;
  ConnFile: TZConnection;
  lSQLFile: string;
  i: integer;
Begin
  lSQLFile := '';
  If not FileExists(aFileName) Then
    Raise Exception.Create(Format('The file "%s" does not exist.', [aFileName]));

  ConnFile := TZConnection.Create(nil);
  qryFile := TZQuery.Create(nil);
  Try
    ConnFile.Protocol := 'sqlite-3';
    ConnFile.ClientCodepage := 'UTF-8';
    ConnFile.Database := aFileName;
    ConnFile.Properties.Values['ExtendedErrorMessage'] := 'true';
    ConnFile.Connect;

    qryFile.Connection := ConnFile;
    qryFile.Close;
    qryFile.SQL.Clear;
    qryFile.SQL.Add('SELECT sql FROM sqlite_master');
    qryFile.SQL.Add('WHERE type=''table'' AND tbl_name=' + QuotedStr(FTableName));
    qryFile.Open;
    lSQLFile := qryFile.Fields[0].AsString.Trim;

    If ((lSQLFile = '') or (qryFile.IsEmpty)) Then
      Raise Exception.Create('Standard table does not exist');

    If not FConn.Connected Then
      FConn.Connect;

    self.Close;
    FConn.ExecuteDirect('DROP TABLE IF EXISTS ' + FTableName);
    FConn.ExecuteDirect(lSQLFile);
    //*
    qryFile.Close;
    qryFile.SQL.Clear;
    qryFile.SQL.Add('SELECT * FROM ' + FTableName);
    qryFile.Open;
    qryFile.FetchAll;
    qryFile.First;
    //*
    self.Close;
    self.FieldDefs.Clear;
    self.Fields.Clear;
    self.SQL.Clear;
    self.SQL.Add('SELECT * FROM ' + FTableName);
    Inherited Open;

    qryFile.DisableControls;
    self.DisableControls;
    Try
      While not qryFile.EOF Do
      Begin
        self.Append;

        For i := 0 To Pred(qryFile.Fields.Count) Do
          self.Fields[i].Value := qryFile.Fields[i].Value;

        self.Post;

        qryFile.Next;
      End;
    Finally
      self.EnableControls;
    End;
    self.First;
  Finally
    qryFile.Close;
    ConnFile.Disconnect;
    FreeAndNil(qryFile);
    FreeAndNil(ConnFile);
  End;
End;

Procedure TDatiDataset.LoadFromStream(aStream: TStream);
Var
  sFile: string;
Begin
  sFile := '.' + PathDelim + FormatDateTime('"dati"hhnnsszzz', Now) + '.dati';
  Try
    TMemoryStream(aStream).LoadFromStream(aStream);
    TMemoryStream(aStream).SaveToFile(sFile);
    Self.LoadFromFile(sFile);
  Finally
    DeleteFile(sFile);
  End;
End;

End.
