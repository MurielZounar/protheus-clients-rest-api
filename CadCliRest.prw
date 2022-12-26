#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'

WSRESTFUL CadClientes DESCRIPTION 'API responsável por manipular e listar cadastros de clientes'
  WSDATA id AS STRING OPTIONAL

  WSMETHOD GET         DESCRIPTION 'Retorna todos os clientes cadastrados'                           WSSYNTAX 'CADCLIENTES/'       PATH '/cadclientes'
  WSMETHOD GET GetById DESCRIPTION 'Retorna um cliente com base no código (id) fornecido'            WSSYNTAX 'CADCLIENTES/{id}'   PATH '/cadclientes/{id}'
  WSMETHOD PUT         DESCRIPTION 'Altera/atualiza um cliente com base no código (id) fornecido'    WSSYNTAX 'CADCLIENTES/{id}'   PATH '/cadclientes/{id}'
  WSMETHOD POST        DESCRIPTION 'Cria um cadastro de cliente'                                     WSSYNTAX 'CADCLIENTES'        PATH '/cadclientes'
  WSMETHOD DELETE      DESCRIPTION 'Exclui um cadastro de cliente com base no código (id) fornecido' WSSYNTAX 'CADCLIENTES/{id}'   PATH '/cadclientes/{id}'
END WSRESTFUL

//* Método que retorna todos os clientes:

WSMETHOD GET WSSERVICE CadClientes
  Local lPost     := .T.
  Local cResponse := ''
  Local aClients  := {}
  Private oJSon   := NIL

  ::SetContentType('application/json')

  aClients := QueryBuilder('', '')

  cResponse := EncodeUTF8(FWJsonSerialize(aClients, .F., .F.))
  ::SetResponse(cResponse)
Return lPost

//* Método que retorna um cliente com base no ID:
WSMETHOD GET GetById PATHPARAM id WSSERVICE CadClientes
  Local lPost   := .F.
  Local cResponse := ''
  local aClient := {}
  Private oJson := NIL
  
  ::SetContentType('application/json')
  
  aClient := QueryBuilder(::id, 'GetById')

  if LEN(aClient) > 0
    lPost := .T.
    cResponse := EncodeUTF8(FWJsonSerialize(aClient, .F., .F.))
    ::SetResponse(cResponse)
  else
    cResponse := "Cliente não encontrado!"
    SetRestFault(404, cResponse)
  endif
Return lPost

//* Método que altera um cliente com base no ID:
WSMETHOD PUT PATHPARAM id WSSERVICE CadClientes
  Local lPost     := .F.
  Local cLiente   := PadL(Upper(AllTrim(::id)), 6, '0')
  Local cResponse := ''
  Local oModel    := FwLoadModel('MATA030')
  local oResponse := JsonObject():New()
  local oRequest  := JsonObject():New()
  Local cName     := ''
  Local cRedName  := ''
  Local cType     := ''
  Local cAdress   := ''
  Local cCity     := ''
  Local cState    := ''

  ::SetContentType('application/json')

  if SA1->(DbSeek(xFilial('SA1') + cLiente))
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()

    oRequest:fromJson(::GetContent())

    cName     := oRequest['name']
    cRedName  := oRequest['reducedname']
    cType     := oRequest['type']
    cAdress   := oRequest['address']
    cCity     := oRequest['city']
    cState    := oRequest['state']

    if !Empty(cName)
      oModel:getModel('MATA030_SA1'):SetValue('A1_NOME', cName)
    endif

    if !Empty(cRedName)
      oModel:getModel('MATA030_SA1'):SetValue('A1_NREDUZ', cRedName)
    endif

    if !Empty(cType)
      oModel:getModel('MATA030_SA1'):SetValue('A1_TIPO', cType)
    endif

    if !Empty(cAdress)
      oModel:getModel('MATA030_SA1'):SetValue('A1_END', cAdress)
    endif

    if !Empty(cCity)
      oModel:getModel('MATA030_SA1'):SetValue('A1_MUN', cCity)
    endif

    if !Empty(cState)
      oModel:getModel('MATA030_SA1'):SetValue('A1_EST', cState)
    endif

    if (oModel:VldData() .AND. oModel:CommitData())
      lPost := .T.
      oResponse['success'] := 'Alteracao Realizada com Sucesso!'
      cResponse := EncodeUTF8(FWJsonSerialize(oResponse))
      ::SetResponse(cResponse)
    else
      aError := oModel:GetErrorMessage()
      cResponse := 'ERRO: ' + aError[5] + ' | ' + aError[6] + ' | ' + aError[7] + ' | '
      SetRestFault(400, cResponse)
    endif

    oModel:Deactivate()
  else
    cResponse := "Cliente não encontrado!"
    SetRestFault(404, cResponse)
  endif
Return lPost

//* Método que cadastra um cliente:
WSMETHOD POST WSSERVICE CadClientes
  Local lPost     := .F.
  Local cResponse := ''
  Local oModel    := FwLoadModel('MATA030')
  local oRequest  := JsonObject():New()
  Local cName     := ''
  Local cRedName  := ''
  Local cType     := ''
  Local cAdress   := ''
  Local cCity     := ''
  Local cState    := ''

  ::SetContentType('application/json')

  oModel:SetOperation(MODEL_OPERATION_INSERT)
  oModel:Activate()

  oRequest:fromJson(::GetContent())

  cCode     := oRequest['code']
  cStore    := oRequest['store']
  cName     := oRequest['name']
  cRedName  := oRequest['reducedname']
  cType     := oRequest['type']
  cAdress   := oRequest['address']
  cCity     := oRequest['city']
  cState    := oRequest['state']

  if !Empty(cName) .AND. !Empty(cRedName) .AND. !Empty(cType) .AND. !Empty(cAdress) .AND. !Empty(cCity) .AND. !Empty(cState) .AND. !Empty(cCode) .AND. !Empty(cStore)
    oModel:getModel('MATA030_SA1'):SetValue('A1_COD', cCode)
    oModel:getModel('MATA030_SA1'):SetValue('A1_LOJA', cStore)
    oModel:getModel('MATA030_SA1'):SetValue('A1_NOME', cName)
    oModel:getModel('MATA030_SA1'):SetValue('A1_NREDUZ', cRedName)
    oModel:getModel('MATA030_SA1'):SetValue('A1_TIPO', cType)
    oModel:getModel('MATA030_SA1'):SetValue('A1_END', cAdress)
    oModel:getModel('MATA030_SA1'):SetValue('A1_MUN', cCity)
    oModel:getModel('MATA030_SA1'):SetValue('A1_EST', cState)

    if (oModel:VldData() .AND. oModel:CommitData())
      lPost := .T.
      oResponse['success'] := 'Cliente Cadastrado com Sucesso!'
      cResponse := EncodeUTF8(FWJsonSerialize(oResponse))
      ::SetResponse(cResponse)
    else
      aError := oModel:GetErrorMessage()
      cResponse := 'ERRO: ' + aError[5] + ' | ' + aError[6] + ' | ' + aError[7] + ' | '
      SetRestFault(400, cResponse)
    endif
  else
    cResponse := 'ERRO: Preencha todos os campos!'
    SetRestFault(400, cResponse)
  endif

  oModel:Deactivate()  
Return lPost

//* Método que deleta um cliente com base no ID:
WSMETHOD DELETE PATHPARAM id WSSERVICE CadClientes
  local lPost     := .F.
  Local cClient   := PadL(Upper(AllTrim(::id)), 6, '0')
  Local cResponse := ''
  Local oModel    := FwLoadModel('MATA030')
  local oResponse := JsonObject():New()

  ::SetContentType('application/json')

  if SA1->(DbSeek(xFilial('SA1') + cClient))
    oModel:SetOperation(MODEL_OPERATION_DELETE)
    oModel:Activate()

    if (oModel:VldData() .AND. oModel:CommitData())
      lPost := .T.
      oResponse['success'] := 'Cliente Deletado com Sucesso!'
      cResponse := EncodeUTF8(FWJsonSerialize(oResponse))
      ::SetResponse(cResponse)
    else
      aError := oModel:GetErrorMessage()
      cResponse := 'ERRO: ' + aError[5] + ' | ' + aError[6] + ' | ' + aError[7] + ' | '
      SetRestFault(400, cResponse)
    endif
  else
    cResponse := 'ERRO: Cliente nao encontrado!'
    SetRestFault(400, cResponse)
  endif

  oModel:Deactivate() 
Return lPost

//* Função que monta a consulta SQL para os métodos GET de acordo com o método que a chamou.
Static Function QueryBuilder(cId, cMethName)
  Local aRet := {}
  Local cAlias    := GetNextAlias()
  local cQuery    := ''

  cQuery := 'SELECT A1_COD, A1_NOME' + CRLF
  cQuery += 'FROM ' + RetSqlName('SA1') + ' SA1' + CRLF
  cQuery += "WHERE A1_FILIAL = '" + xFilial('SA1') + "'" + CRLF

  if cMethName == 'GetById'
    cQuery += "AND A1_COD = '" + cId + "'" + CRLF
  endif

  cQuery += "AND D_E_L_E_T_ = ' '"

  TCQUERY cQuery ALIAS &(cAlias) NEW

  &(cAlias)->(DbGoTop())

  while &(cAlias)->(!EOF())
    oJSon := JsonObject():New()
    oJSon['code'] := &(cAlias)->(A1_COD)
    oJSon['name'] := &(cAlias)->(A1_NOME)
    Aadd(aRet, oJson)

    &(cAlias)->(DbSkip())
  enddo

  &(cAlias)->(DbCloseArea())
Return aRet
