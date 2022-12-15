'eslint-disable roku/function-no-return-type
function getCommandMap() as Object
    return {
        "isInFocus" : "UIIsInFocus",
        "getElementText" : "UIgetElementText",
        "inputElementText" : "UIinputElementText",
        "getElementMeasures" : "UIgetElementMeasures",
        "getAttrElementChild" : "UIgetAttrElementChild",
        "isInFocusElementChild" : "UIisInFocusElementChild",
        "getElementChildCount" : "UIgetElementChildCount",
        "getElementLabelChild" : "UIgetElementLabelChild",
        "isVisible" : "UIisVisible",
        "GetAttrElement" : "UIGetAttrElement",
        "getViewName" : "UIgetViewName",
        "getNodeData" : "UIgetNodeData",
    }
End function

function UIgetNodeData(args) as Object
    m.mainScene=m.top.getParent()
    elementFindbyId = getNodebyId(args.data.id)
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    if elementFindbyId.content = invalid then return getError("Element doesnt have content node")
    contentNodes = getChildNodes(elementFindbyId.content)
    nodeContent = elementFindbyId.content.getFields()
    arrayContentChilds = []
    for each node in contentNodes
        contentNodefields = node.getFields()
        contentNodeChilds = getChildNodes(node)
        childs = []
        for each item in contentNodeChilds
            childFields = sanitizeFields(item.getFields(),["ProgressNode"])
            childs.push(childFields)
        end for
        contentNodefields["childs"] = childs
        arrayContentChilds.push(contentNodefields)
    end for
    nodeContent["childs"] = arrayContentChilds
    response = CreateObject("roAssociativeArray")
    response[args.data["command"]] = nodeContent
    return response
End function

function UIgetViewName(args) as Object
    viewName = ""
    viewNode = Lodash().get(getValidRouter(), "route.view")
    if (viewNode <> invalid) then viewName = viewNode.subType()
    response = CreateObject("roAssociativeArray")
    response["viewName"] = viewName
    return response
End function

function UIgetElementLabelChild(args) as Object
    m.mainScene=m.top.getParent()
    m.response = CreateObject("roAssociativeArray")
    j=0
    elementFindbyId = getNodebyId(args.data.id).getChild(Val(args.data.numberChild)).findNode("infoGrp")
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    for i = 0 to elementFindbyId.getChildCount()-1
        elementFindbyIdChild = elementFindbyId.getChild(i)
        if elementFindbyIdChild.subtype() = "Label"
            m.response[box("LabelChildText "+ strI(j)).replace(" ","")] = elementFindbyIdChild.text
            j=j+1
        end if
    end for
    return m.response
End function

function UIgetElementChildCount(args) as Object
    m.mainScene=m.top.getParent()
    elementFindbyId = getNodebyId(args.data.id)
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    response = CreateObject("roAssociativeArray")
    response["childCount"] = elementFindbyId.getChildCount()
    return response
End function

function UIGetAttrElement(args) as Object
    m.mainScene=m.top.getParent()
    elementFindbyId = getNodebyId(args.data.id)
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    response = CreateObject("roAssociativeArray")
    response[args.data["command"]] = elementFindbyId[args.data["Attr"]]
    return response
End function

function UIisInFocusElementChild(args) as Object
    m.mainScene=m.top.getParent()
    elementFindbyId = getNodebyId(args.data.id)
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    elementFindbyIdChild = elementFindbyId.getChild(Val(args.data.numberChild))
    response = CreateObject("roAssociativeArray")
    response["hasFocus"] = elementFindbyIdChild.hasFocus()
    return response
End function

function UIgetAttrElementChild(args) as Object
    m.mainScene=m.top.getParent()
    elementFindbyId = getNodebyId(args.data.id)
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    elementFindbyIdChild = elementFindbyId.getChild(Val(args.data.numberChild))
    response = CreateObject("roAssociativeArray")
    response[args.data["Attr"]] = elementFindbyIdChild[args.data["Attr"]]
    return response
End function

function UIIsInFocus(args) as Object
    m.mainScene=m.top.getParent()
    elementFindbyId = getNodebyId(args.data.id)
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    response = CreateObject("roAssociativeArray")
    response[args.data["command"]] = elementFindbyId.hasFocus()
    return response
End function

function UIisVisible(args) as Object
    m.mainScene=m.top.getParent()
    elementFindbyId = getNodebyId(args.data.id)
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    response = CreateObject("roAssociativeArray")
    response[args.data["command"]] = elementFindbyId.visible
    return response
End function

function UIgetElementText(args) as Object
    m.mainScene=m.top.getParent()
    elementFindbyId = getNodebyId(args.data.id)
    if elementFindbyId["error"] <> invalid then return elementFindbyId
    response = CreateObject("roAssociativeArray")
    response[args.data["command"]] = elementFindbyId.text
    return response
End function

function callCommand(command, args) as Object
    return m.top.callFunc(command, args)
End function

Sub automationTracker()
    appInfo = CreateObject("roAppInfo")
    handlersMap = getCommandMap()

    print "Automation run"  ' eslint-disable-line roku/no-print

    buffer = CreateObject("roByteArray")
    buffer[1024] = 0
    messagePort = CreateObject("roMessagePort")
    addr = CreateObject("roSocketAddress")

    inputPort = CreateObject("roMessagePort")
    inputObj  = CreateObject("roInput")
    inputObj.SetMessagePort(inputPort)

    while True
        automationEnabled = true
        port = 0
        msg = wait(0, inputPort)

        if type(msg) = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                if type(info) = "roAssociativeArray" then
                    port = info.port.toInt()
                end if
            end if
        end if

        if automationEnabled then
            UDPPeer(addr, messagePort, port, buffer, handlersMap, m.config)
        end if
    end while

End Sub

sub UDPPeer(addr, messagePort, port, buffer, handlersMap, config)
    ?"MAIN...."  ' eslint-disable-line roku/no-print
    connections = {}
    appManager = createObject("roAppManager")
    screensaverTimer = CreateObject("roTimespan")
    screensaverTimer.Mark()

    addr.setPort(port)

    tcpListen = CreateObject("roStreamSocket")
    tcpListen.setMessagePort(messagePort)
    tcpListen.setAddress(addr)
    tcpListen.notifyReadable(true)
    tcpListen.listen(4)

    wasConnected = false

    if not tcpListen.eOK()
        print "Error creating listen socket"  ' eslint-disable-line roku/no-print
    end if

    while True
        event = wait(0, messagePort)

        if type(event) = "roSocketEvent"
            print "GOT HERE"  ' eslint-disable-line roku/no-print
            changedID = event.getSocketID()

            if changedID = tcpListen.getID() and tcpListen.isReadable()
                newConnection = tcpListen.accept()

                if newConnection = Invalid
                    print "accept failed"  ' eslint-disable-line roku/no-print
                else
                    print "accepted new connection " newConnection.getID()  ' eslint-disable-line roku/no-print
                    newConnection.notifyReadable(true)
                    newConnection.setMessagePort(messagePort)
                    connections[Stri(newConnection.getID())] = newConnection
                end if
            else
                ' Activity on an open connection
                connection = connections[Stri(changedID)]
                closed = False

                if connection.isReadable()
                    received = connection.receive(buffer, 0, 512)
                    print "received is " received  ' eslint-disable-line roku/no-print

                    if received > 0
                        print "Received in Roku: '"; buffer.ToAsciiString(); "'"  ' eslint-disable-line roku/no-print
                        str = buffer.ToAsciiString().Left(received)
                        request = ParseJson(str)
                        buffer = CreateObject("roByteArray")
                        buffer[1024] = 0
                        data = onDataReceive(str)

                        'connection.send(buffer, 0, data)
                        res = "[start]" + data + "[end]"
                        resList = splitStringByLength(res, 3000)
                        count = resList.count() - 1
                        for i = 0 to count
                            connection.SendStr(resList[i])
                            sleep(20)
                        end for
                    else if received=0 ' client closed
                        closed = True
                    end if
                end if

                if closed or not connection.eOK()
                    print "closing connection " changedID  ' eslint-disable-line roku/no-print
                    connection.close()
                    buffer[512] = 0
                    connections.delete(Stri(changedID))
                end if
            end if
        end if
    end while

    print "Main loop exited"  ' eslint-disable-line roku/no-print
    tcpListen.close()

    for each id in connections
        connections[id].close()
    end for
end sub

Sub init()
    m.mainScene=m.top.getParent()
    m.top.functionName = "automationTracker"
End Sub

function convertToAssosarray(node as dynamic) as Object
    if type(node) = "roSGNode"
        nodeAssosarray = node.getFields()
        for each item in nodeAssosarray.Items()
            if type(item.value) = "roSGNode"
                nodeAssosarray.AddReplace(item.key,convertToAssosarray(item.value))
            end if
        end for
    end if

    return nodeAssosarray
end function

function onDataReceive(data as dynamic) as Object
    dataReceive=Parsejson(data)
    handlersMap = getCommandMap()
    handler = handlersMap[dataReceive.data["command"]]
    if handler <> Invalid then
        response = callCommand(handler, dataReceive)
    else
        response = getError("No such command")
    end if
    ?response  ' eslint-disable-line roku/no-print
    return FormatJson(response)
end function

function getNodebyId(id as string) as Object
    elementbyID = m.mainScene.findNode(id)
    if elementbyID <> Invalid then
        return elementbyID
    else
        return getError("Node not found")
    end if
end function

' Returns error object
' @param {string} message - error message
Function getError(message as String) as Object
    return { error: { message: message } }
End Function

function getValidRouter() as dynamic
    scene = m.top.getScene()
    router = Lodash().get(scene, "application.router")
    if (router <> invalid) and router.subtype() = "Router" then return router
    return invalid
end function

Function splitStringByLength(str, length) as Dynamic
    list = []
    indexPosition = 0

    while indexPosition < str.len()
        list.push(str.mid(indexPosition, length))
        indexPosition = indexPosition + length
    end while

    return list
End function
