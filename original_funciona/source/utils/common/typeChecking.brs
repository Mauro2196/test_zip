' ------------------------------------------------------------------------------
' type-checking Utilities
'

function isInvalid(val as dynamic) as boolean
    valType = type(val)
    return valType = "Invalid" or valType = "roInvalid"
end function


function isValid(val as dynamic) as boolean
    return not isInvalid(val)
end function


function isInitialized(val as dynamic) as boolean
    valType = lCase(type(val))
    return not valType = "<uninitialized>"
end function

' If an integer is the field of a node, its type is `roInt`.
' If an integer is the value of an array or an assoc array, its type is `roInteger`,
'   UNLESS the value was first the field of node, in which case its type will be `roInt`.
function isInteger(val as dynamic) as boolean
    valType = type(val)
    return valType = "Integer" or valType = "roInt" or valType = "roInteger"
end function


function isString(val as dynamic) as boolean
    valType = type(val)
    return valType = "String" or valType = "roString"
end function


function isStringNotEmpty(val as dynamic) as boolean
    return isString(val) and val.trim() <> ""
end function


function isStringEmpty(val as dynamic) as boolean
    return not isStringNotEmpty(val)
end function


function isLongInteger(val as dynamic) as boolean
    valType = type(val)
    return valType = "LongInteger" or valType = "roLongInteger"
end function


function isFloat(val as dynamic) as boolean
    valType = type(val)
    return valType = "Float" or valType = "roFloat"
end function


function isDouble(val as dynamic) as boolean
    valType = type(val)
    return valType = "Double" or valType = "roDouble"
end function


function isNumber(val as dynamic) as boolean
    return isInteger(val) or isLongInteger(val) or isFloat(val) or isDouble(val)
end function


function isBoolean(val as dynamic) as boolean
    valType = type(val)
    return valType = "Boolean" or valType = "roBoolean"
end function


function isArray(val as dynamic) as boolean
    valType = type(val)
    return  valType = "roArray"
end function

function isEmptyArray(val as dynamic) as boolean
    if not isArray(val) then return true

    return val.count() = 0
end function


function isAssocArray(val as dynamic) as boolean
    valType = type(val)
    return  valType = "roAssociativeArray"
end function

function isEmptyAssocArray(val as dynamic) as boolean
    if not isAssocArray(val) then return true
    ' removing possible name clashes
    if val.doesExist("count")
        val._count = val.count
        val.delete("count")
    end if

    return val.count() = 0
end function


function isFunction(val as dynamic) as boolean
    valType = type(val)
    return  valType = "Function" or valType = "roFunction"
end function


function isNode(val as dynamic, subtype = "" as string) as boolean
    return type(val) = "roSGNode" and (ucase(val.subtype()) = ucase(subtype) or subtype = "")
end function


function isEvent(val as dynamic) as boolean
    return type(val) = "roSGNodeEvent"
end function


function isEqual(val1 as dynamic, val2 as dynamic) as boolean
    if type(val1) <> type(val2) then return false
    if isAssocArray(val1) or isArray(val1)
        return formatJson(val1) = formatJson(val2)
    else
        return val1 = val2
    end if
end function


function implementsAssocArray(obj as dynamic) as boolean
    return isValid(obj) and (getInterface(obj, "ifAssociativeArray") <> invalid)
end function


function isJSONable(value as dynamic) as boolean
    if isInvalid(value) then return false
    jsonStr = formatJSON(value)
    ' an invalid formatJSON op is the only case that will return
    ' an actual empty string
    return len(jsonStr) > 0
end function


function isNil(value as dynamic) as boolean
    return isInvalid(value) or not isInitialized(value)
end function


function isFalsey(value as dynamic) as boolean
    if isNumber(value) then return value = 0
    if isString(value) then return value = ""
    if isBoolean(value) then return not value
    return isNil(value)
end function


function isTruthy(value as dynamic) as boolean
    return not isFalsey(value)
end function


function isErrorNode(value as Dynamic) as Boolean
    return isNode(value, "ERROR")
end function