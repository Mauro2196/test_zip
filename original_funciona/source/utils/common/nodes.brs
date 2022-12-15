' requires:
' - source/utils/common/typeChecking.brs
' ------------------------------------------------------------------------------
' Node Utilities
'
function getGlobalNode() as object
    return getGlobalAA().global
end function


' Returns the node specified by the `nodeIdPath`, if it exists.
' If the node doesn't exist, returns `invalid`.
function getNodeByIdPath(nodeIdPath as string, node = getGlobalNode() as object) as object
    if (node = invalid) then return invalid

    idPath = nodeIdPath.split(".")
    for each id in idPath
        node = node.findNode(id)
        if (node = invalid) then return invalid
    end for

    return node
end function


function getChildNodes(parent as object) as object
    if not isNode(parent) then return []
    return parent.getChildren(parent.getChildCount(), 0)
end function


' helper to sanitize contentNode data
function getSanitizedFields(contentNode as object, optionalBlacklist = ["focusable"] as object) as object
    return sanitizeFields(contentNode.getFields(), optionalBlacklist)
end function


' Removes fields that cannot be removed from node objects.
function sanitizeFields(fields as object, optionalBlacklist = [] as object) as object
    blackList = ["change", "focusedChild"]
    blackList.append(optionalBlacklist)
    for each field in blackList
        fields.delete(field)
    end for
    return fields
end function


function replaceChildNodes(parent as object, newChildNodes as object) as object
    clearChildren(parent)
    parent.appendChildren(newChildNodes)
    return newChildNodes
end function


' Removes the child node from the parent, and
function removeChildNodeById(parent as object, childId as string) as object
    childNode = parent.findNode(childId)
    parent.removeChild(childNode)
    return childNode
end function


function setNodeFields(node as object, fields = {} as object) as object
    return __setNodeFields(node, sanitizeFields(fields))
end function


function createNode(nodeSubtype = "ContentNode" as string, fields = {} as object) as object
    return __createNode(nodeSubtype, sanitizeFields(fields))
end function


function createChildNodes(parent as object, numChildNodes = 0 as integer, nodeSubtype = "ContentNode" as string, fields = {} as object) as object
    return __createChildNodes(parent, numChildNodes, nodeSubtype, sanitizeFields(fields))
end function


function createNodes(numNodes = 0 as integer, nodeSubtype = "ContentNode" as string, fields = {} as object) as object
    return __createNodes(numNodes, nodeSubtype, sanitizeFields(fields))
end function


function createNodesInHashMapValues(hashMap as object, nodeSubtype = "ContentNode" as string) as object
    if isInvalid(hashMap) then return invalid

    hashMapNodes = {}
    for each key in hashMap
        if isArray(hashMap[key])
            hashMapNodes[key] = Lodash().map(hashMap[key], __createNodeTx, { nodeSubtype: nodeSubtype })
        else
            hashMapNodes[key] = createNode(nodeSubtype, hashMap[key])
        end if
    end for
    return hashMapNodes
end function


' Functions below do NOT sanitize fields.
function __setNodeFields(node as object, fields = {} as object) as object
    node.update(fields, true)
    return node
end function


' Creates a node of subtype `nodeSubtype`
function __createNode(nodeSubtype = "ContentNode" as string, fields = {} as object) as object
    return __setNodeFields(createObject("roSGNode", nodeSubtype), fields)
end function


' Creates `numChildNodes` as children of `parent`.
function __createChildNodes(parent as object, numChildNodes = 0 as integer, nodeSubtype = "ContentNode" as string, fields = {} as object) as object
    childNodes = __createNodes(numChildNodes, nodeSubtype, fields)
    parent.appendChildren(childNodes)
    return childNodes
end function


function __createNodes(numNodes = 0 as integer, nodeSubtype = "ContentNode" as string, fields = {} as object) as object
    nodes = []
    for i = 0 to numNodes - 1
        nodes[i] = __createNode(nodeSubtype, fields)
    end for
    return nodes
end function


' util to clear out node children
function clearChildren(component as object) as boolean
    childrenCount = component.getChildCount()
    if childrenCount = 0 then return true
    if component.isInFocusChain() then setFocusOn(component)
    return component.removeChildrenIndex(childrenCount, 0)
end function


function copyNode(node as object, deepCopy = false as boolean) as dynamic
    if isInvalid(node) or type(node) <> "RoSGNode" then return invalid' eslint-disable-line roku/no-uninitialized-functions
    return node.clone(deepCopy)
end function


function getChildNodeIndex(parentNode as object, id as string) as integer
    childCount = parentNode.getChildCount()
    for i = 0 to childCount - 1
        child = parentNode.getChild(i)
        if child.id = id then return i
    end for
    return -1
end function


' CVAA stuff
function say(caption as string, sayNow = true as boolean) as integer
    if isInvalid(m.__audioGuide)' eslint-disable-line roku/no-uninitialized-functions
        m.__audioGuide = {
            guide: createObject("roAudioGuide")
            regex: createObject("roRegex", "\.?\n+", "i")
        }
    end if

    textSplitted = m.__audioGuide.regex.split(caption)

    if textSplitted.count() > 1
        return Lodash().reduce(textSplitted, __sayTxtReducer, 0, { sayNow: sayNow })' eslint-disable-line roku/no-uninitialized-functions
    end if

    return m.__audioGuide.guide.say(caption, sayNow, true)
end function


function __sayTxtReducer(audioId as integer, captionItem as string, idx as integer, props = {} as object) as integer' eslint-disable-line roku/no-unused-params
    return m.__audioGuide.guide.say(captionItem, ((idx = 0) and props.sayNow), true)
end function


sub flushSay()
    if m.__audioGuide = invalid then return
    m.__audioGuide.guide.flush()
end sub


' ********* PLEASE READ *********
' no more setFocus directly over a component in favor of this
' global utility function which performs additional stuff if needed
function setFocusOn(component as dynamic, keepRef = true as boolean, shortCircuit = invalid as dynamic, setFocus = true as boolean) as boolean
    if not isNode(component) then return false' eslint-disable-line roku/no-uninitialized-functions
    ' check condition to short-circuit bye!
    if isFunction(shortCircuit)' eslint-disable-line roku/no-uninitialized-functions
        isNotFocusable = shortCircuit(component)
        if isBoolean(isNotFocusable) and isNotFocusable then return false' eslint-disable-line roku/no-uninitialized-functions
    end if
    ' lets keep record of previous focus item
    scene = m.top.getScene()
    if not scene.hasField("__focusReference") then scene.addField("__focusReference", "node", false)
    if keepRef then scene.setFields({ __focusReference: component })
    ' now lets focus...
    component.setFocus(setFocus)
    ' CVAA stuff
    if isValid(component.audioGuideCaption) and (component.audioGuideCaption <> "") and setFocus' eslint-disable-line roku/no-uninitialized-functions
        say(component.audioGuideCaption)
    end if

    return component.hasFocus() or component.isInFocusChain()
end function


function setFocusBack() as boolean
    ' no queue? return false
    scene = m.top.getScene()
    if not scene.hasField("__focusQueue") then return false
    queue = scene.__focusQueue
    while queue.count() > 0
        target = queue.peek()
        if isNode(target) and not (target.hasFocus() or target.isInFocusChain()) then exit while' eslint-disable-line roku/no-uninitialized-functions
        queue.pop()
    end while

    scene.setFields({ __focusQueue: queue })
    ' all references that were focused before, do not exist now
    if queue.count() = 0 then return false

    return setFocusOn(target)
end function


' found if a node is child of another one
function isDescendantOf(child as object, targetParent as object) as boolean
    ' no nodes? bye!
    if not isNode(child) or not isNode(targetParent) then return false' eslint-disable-line roku/no-uninitialized-functions
    parent = child.getParent()
    ' root node found or unnatached node, bye!
    if isInvalid(parent) then return false' eslint-disable-line roku/no-uninitialized-functions
    ' traverse upward the hierarchy to detect a parent
    if parent.isSameNode(targetParent)
        return true
    else
        return isDescendantOf(parent, targetParent)
    end if
end function


' found if a node is child of another one
function isDescendantOfSubType(child as object, targetParentType as string) as boolean
    ' no nodes? bye!
    if not isNode(child) then return false' eslint-disable-line roku/no-uninitialized-functions
    parent = child.getParent()
    ' root node found or unnatached node, bye!
    if isInvalid(parent) then return false' eslint-disable-line roku/no-uninitialized-functions
    ' traverse upward the hierarchy to detect a parent by type
    if parent.subtype() = targetParentType
        return true
    else
        return isDescendantOfSubType(parent, targetParentType)
    end if
end function


function destroyNode(mRefNameOfNode as string, parentOfNode = invalid as object) as boolean
    node = m[mRefNameOfNode]
    m.delete(mRefNameOfNode)
    return (parentOfNode = invalid) or parentOfNode.removeChild(node)
end function


function replaceTokens(strIn as string, recquery as string, value as string) as object
    result = strIn
    regExp = CreateObject("roRegex", recquery, "i")
    if regExp.IsMatch(strIn)
        result = regExp.ReplaceAll(strIn, value)
    end if

    return result
end function


function addRegisterChild(parent as object, child as object, childRef = "") as boolean
    if not (isNode(child) and isNode(parent) and ((childRef + child.id) <> "")) then return false' eslint-disable-line roku/no-uninitialized-functions
    ' valid node, go ahead
    if childRef = "" then key = child.id else key = childRef
    childField = {}
    childField[key] = child
    parent.addFields(childField)
    parent.appendChild(child)

    return true
end function


function sortNodeArray(array as object, sortFieldName as string, isReverse = false) as object
    _ = Lodash()' eslint-disable-line roku/no-uninitialized-functions
    flags = "i"
    if isReverse then flags = "ri"
    sortableList = _.map(array, __sortNodeTx)
    sortableList.sortBy(sortFieldName, flags)
    ' return sorted version
    return _.map(sortableList, __sortNodeTx)
end function


function __sortNodeTx(item as object, idx as integer, props = {}) as dynamic' eslint-disable-line roku/no-unused-params
    if not isNode(item) then return item.__node' eslint-disable-line roku/no-uninitialized-functions
    data = item.getFields()
    data.__node = item

    return data
end function


function __createNodeTx(item as object, idx = 0 as integer, props = {}) as object
    return createNode(props.nodeSubtype, item)
end function


function setTimeout(funcName as string, timerConf = {} as object) as object
    timer = m.top.createChild("Timer")
    timer.update(timerConf)
    timer.observeField("fire", funcName)
    timer.control = "start"
    return timer
end function
