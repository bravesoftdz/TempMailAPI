unit TempmailAPI;

interface

uses
  System.Classes,
  System.Generics.Collections;

Type
  /// <summary>
  /// ��������: ��������� ����� �������� '��������', ��������� ��� ������ ��� �����������.
  /// ��� �������� ������ ��������� �������� � ������� 10 ����� ����� �����������.
  /// </summary>
  TTempMailItem = Class
    /// <summary>���������� ������������� ������ � md5 ����, ����������� �������� </summary>
    mail_id: String;
    /// <summary>md5 ��� ��������� ������ </summary>
    mail_address_id: String;
    /// <summary> �����������</summary>
    mail_from: String;
    /// <summary>���� </summary>
    mail_subject: String;
    /// <summary>������������ ��������� </summary>
    mail_preview: String;
    /// <summary>C�������� � ��������� ��� � html ������� (��������) </summary>
    mail_text_only: String;
    /// <summary> C�������� ������ � ��������� �������</summary>
    mail_text: String;
    /// <summary> C�������� ������ � html �������</summary>
    mail_html: String;

    mail_timestamp: TDateTime;
  End;

  TTempMailClientAPI = Class(TComponent)
  Private Const
    SERVER_API = 'http://api.temp-mail.ru/request/%S/format/json/';
  private
    FDomains: TList<String>;
    FLetters: TObjectList<TTempMailItem>;
  protected

    Function EMailToMD5(Const EMail: String): String;
  public
    // ��� �������� � ��������� ������ �����
    Function getMail(Const EMail: String): Boolean;
    /// <summary> ������ ������� </summary>
    Function getDomains: Boolean;
    /// <summary>�������� ������ </summary>
    Function delete(Const Item: TTempMailItem): Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Domains: TList<String> read FDomains;
    property Letters: TObjectList<TTempMailItem> read FLetters;
  End;

implementation

uses
  XSuperObject, // <-- https://github.com/onryldz/x-superobject
  System.SysUtils,
  System.JSON,
  System.Net.HttpClient,
  System.Hash;

{ TTempMailClient }

constructor TTempMailClientAPI.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDomains := TList<String>.Create;
  FLetters := TObjectList<TTempMailItem>.Create;
end;

function TTempMailClientAPI.delete(Const Item: TTempMailItem): Boolean;
var
  HTTP: THTTPClient;
begin
  Result := false;
  HTTP := THTTPClient.Create;
  try
    with HTTP.Get(Format(SERVER_API, ['delete/id/' + Item.mail_id + '/'])) do
    Begin
      if StatusCode = 404 then
        Exit;
      { TODO -oOwner -cGeneral : �������� �������� ���������� }
    End;
    Result := True;
  finally
    HTTP.Free;
  end;
end;

destructor TTempMailClientAPI.Destroy;
begin
  FDomains.Free;
  FLetters.Free;
  inherited Destroy;
end;

function TTempMailClientAPI.getDomains: Boolean;
var
  HTTP: THTTPClient;
  iSuper: ISuperArray;
  I: Integer;
begin
  Result := false;
  HTTP := THTTPClient.Create;
  try
    with HTTP.Get(Format(SERVER_API, ['domains'])) do
    Begin
      if StatusCode = 404 then
        Exit;
      iSuper := TSuperArray.Create(ContentAsString);
      for I := 0 to iSuper.Length - 1 do
        FDomains.Add(iSuper.S[I]);
    End;
    Result := True;
  finally
    HTTP.Free;
  end;
end;

function TTempMailClientAPI.EMailToMD5(const EMail: String): String;
begin
  Result := THashMD5.GetHashString(EMail);
end;

function TTempMailClientAPI.getMail(const EMail: String): Boolean;
var
  HTTP: THTTPClient;
  iSuper: ISuperArray;
  I: Integer;
begin
  Result := false;
  HTTP := THTTPClient.Create;
  try
    with HTTP.Get(Format(SERVER_API, ['mail/id/' + EMailToMD5(EMail) + '/'])) do
    Begin
      iSuper := TSuperArray.Create(ContentAsString);
      if StatusCode = 404 then
        Exit;
      for I := 0 to iSuper.Length - 1 do
        FLetters.Add(TTempMailItem.FromJSON(iSuper.O[I].AsObject));
    End;
    Result := True;
  finally
    HTTP.Free;
  end;
end;

end.
