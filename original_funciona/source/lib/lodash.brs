'---- LODASH PARTIAL IMPLEMENTATION FOR BRIGHTSCRIPT ARRAYS... and node chidren converted to arrays
' forEach, filter, indexOf, map, reduce, find, findLast, findIndex, findLastIndex, clone,
' slice, lastIndexOf, get, arrayFrom, chunk, set
' @author: german.galvis@zemoga.com
' v.1.0.0 - use the same value for default value in lodash call
' * @param {String - read only} current version (modify if a new version will be pushed)
' * @returns {Object} Returns lodash instance.
function lodash(version = "1.0.0" as string) as object
    ' a long funny name which shouldn't be used by anyone else...
    instanceId = "_lodashInstanceWhichShouldBeUnique_v" + version
    ' return instance if present
    if m[instanceId] <> invalid then return m[instanceId]
    m[instanceId] = {
        _id: instanceId
        ' * Clone objects which posess JSON data valid types
        ' *
        ' * @param {Object} assocArray to obtain keys (shallow)
        ' * @returns {Object} Returns copy of object - values not references.
        clone: function(hash as object) as object
            if not m.__implementsAssociativeArray(hash) then return invalid
            return parseJson(formatJson(hash))
        end function


        ' * Creates an array of elements split into groups the length of `size`.
        ' * If `array` can't be split evenly, the final chunk will be the remaining
        ' * elements.
        ' * @param {Array} array The array to process.
        ' * @param {number} [size=1] The length of each chunk
        ' * @returns {Array} Returns the new array of chunks.
        chunk: function(array as object, size = 0 as integer) as object
            index = 0
            length = array.count() - 1
            resIndex = 0
            'edge cases
            if size <= 0 or size > array.count() then return array

            result = []
            while (index <= length)
                resIndex = index + (size - 1)
                result.push(m.slice(array, index, resIndex))
                index += size
            end while
            return result
        end function


        ' * A specialized version of `_.forEach` for arrays without support for
        ' * iteratee shorthands.
        ' *
        ' * @param {Array} array The array to iterate over.
        ' * @param {Function} iteratee The function invoked per iteration.
        ' * @param {Object} [params] Optional params to use in iteratee.
        ' * @returns {Array} Returns `array`.
        forEach: function(array as object, iteratee as function, params = {} as object) as object
            index = -1
            length = array.count() - 1

            for index = 0 to length
                if (iteratee(array[index], index, params) = false) then
                    exit for
                end if
            end for
            return array
        end function


        ' * Return a group of items that fulfill the predicate criteria
        ' * Predicate can either be a function or any value to seek into element props
        ' *
        ' * @param {Array} array The array to iterate over.
        ' * @param {Function|Object|String|Number} the condition to pass per iteration
        ' * @returns {Array} Returns the new filtered array.
        ' * @example
        ' *
        ' * users = [
        ' *   { 'user': 'barney',  'age': 36, 'active': true },
        ' *   { 'user': 'fred',    'age': 40, 'active': false },
        ' *   { 'user': 'pebbles', 'age': 1,  'active': true }
        ' * ]
        ' *
        ' * _.filter(users, function(o)
        ' *                 return o.age < 30
        ' *               end function
        ' * )
        ' * // => [object for 'barney', object for 'fred']
        ' *
        ' * ... or by property
        ' *
        ' * _.filter(users, {active:true})
        ' * // => [object for 'barney', object for 'pebbles']
        filter: function(array as object, predicate as object, params = {} as object) as object
            length = array.count() - 1
            resIndex = 0
            result = []

            for index = 0 to length
                value = array[index]
                ' support for shorthands
                if type(predicate) <> "roFunction" then
                    condition = m.__propsComp(value, predicate, false)
                else
                    condition = predicate(value, index, params)
                end if

                if (condition) then
                    result[resIndex] = value
                    resIndex = resIndex + 1
                end if
            end for
            return result
        end function


        '/**
        ' * The base implementation of `_.indexOf`
        ' *
        ' * @param {Array} array The array to search.
        ' * @param {*} value The value to search for.
        ' * @param {boolean} Specify iterating from right to left.
        ' * @returns {Integer} Returns the index of the matched value, else `-1`.
        ' */
        indexOf: function(array as object, value as dynamic, fromRight = false) as integer
            length = array.count() - 1
            if fromRight then index = length else index = -1
            condition = length >= 0

            while (condition)
                if fromRight then
                    i = index
                    condition = index >= 0
                    index -= 1
                else
                    index += 1
                    i = index
                    condition = index < length
                end if

                typeRef = type(array[i], 3)
                typeVal = type(value, 3)
                if (typeRef = typeVal) and array[i] = value then return i
            end while

            return -1
        end function


        '/**
        ' * indexOf from right to left - sugar syntax for  _.indexOf(array, value, true)
        ' *
        ' * @param {Array} array The array to search.
        ' * @param {*} value The value to search for.
        ' * @returns {Integer} Returns the index of the matched value, else `-1`.
        ' */
        lastIndexOf: function(array as object, value as dynamic) as integer
            return m.indexOf(array, value, true)
        end function



        '/**
        ' * A specialized version of `_.map` for arrays without support for iteratee
        ' * shorthands.
        ' *
        ' * @param {Array} array The array to iterate over.
        ' * @param {Function} iteratee The function invoked per iteration.
        ' * @param {Object} [params] Optional params to use in iteratee.
        ' * @returns {Array} Returns the new mapped array.
        ' */
        map: function(array as object, iteratee as function, params = {} as object) as object
            length = array.count() - 1
            result = []

            for index = 0 to length
                result[index] = iteratee(array[index], index, params)
            end for

            return result
        end function


        '/**
        ' * A specialized version of `_.reduce` for arrays without support for
        ' * iteratee shorthands.
        ' *
        ' * @param {Array} array The array to iterate over.
        ' * @param {Function} iteratee The function invoked per iteration.
        ' * @param {*} [accumulator] The initial value.
        ' * @param {Object} [params] Optional params to use in iteratee.
        ' * @returns {*} Returns the accumulated value.
        ' */
        reduce: function(array as object, iteratee as function, accumulator = invalid as dynamic, params = {} as object) as dynamic
            length = array.count() - 1

            initialIndex = 0
            if (accumulator = invalid) and length > 0
                initialIndex += 1
                accumulator = array[initialIndex]
            end if

            for index = initialIndex to length
                accumulator = iteratee(accumulator, array[index], index, params)
            end for

            return accumulator
        end function


        '/**
        ' * Iterates over elements of `collection`, returning the first element
        ' * `predicate` returns true for. The predicate is invoked with three
        ' * arguments: (value, index|key, collection).
        ' *
        ' * @param {Array|AssociativeArray} collection The collection to search.
        ' * @param {Function} The function invoked per iteration.
        ' * @returns {*} Returns the matched element, else `invalid`.
        ' * @example
        ' *
        ' * users = [
        ' *   { 'user': 'barney',  'age': 36, 'active': true },
        ' *   { 'user': 'fred',    'age': 40, 'active': false },
        ' *   { 'user': 'pebbles', 'age': 1,  'active': true }
        ' * ]
        ' *
        ' * _.find(users, function(o)
        ' *                 return o.age < 40
        ' *               end function
        ' * )
        ' * // => object for 'barney'
        ' *
        ' * ... or by property
        ' *
        ' * _.find(users, {age:36})
        ' * // => object for 'barney'
        ' */
        find: function(array as object, predicate as object, params = {} as object) as dynamic
            index = m.__baseFind(array, predicate, false, params)
            if index > -1 then
                return array[index]
            else
                return invalid
            end if
        end function


        '/**
        ' * Same as find, but iterating from last to first
        ' *
        findLast: function(array as object, predicate as object, params = {} as object) as dynamic
            index = m.__baseFind(array, predicate, true, params)
            if index > -1 then
                return array[index]
            else
                return invalid
            end if
        end function


        '/**
        ' * Same as find, returns element position inside array
        ' *
        findIndex: function(array as object, predicate as object, params = {} as object) as dynamic
            return m.__baseFind(array, predicate, false, params)
        end function


        '/**
        ' * Same as findIndex, but iterating from last to first
        ' *
        findIndexLast: function(array as object, predicate as object, params = {} as object) as dynamic
            return m.__baseFind(array, predicate, true, params)
        end function


        '/**
        ' * Creates a slice of `array` from `start` up to, including, `end`.
        ' *
        ' * @param {Array} array The array to slice.
        ' * @param {Integer} [start=0] The start position.
        ' * @param {Integer} [end=array.length] The end position.
        ' * @returns {Array} Returns the slice of `array`.
        ' */
        slice: function(array as object, first = 0, final = -1) as object
            max = array.count() - 1
            result = []

            ' overriding negative values for slice
            if (final < 0 or final > max) then final = max
            if first < 0 then first = 0
            ' return empty if first greater than final
            if (max < 0) or (first > final) then return result
            for idx = first to final
                result.push(array[idx])
            end for

            return result
        end function


        '/**
        ' * The base implementation of `_.get`
        ' *
        ' * @private
        ' * @param {dynamic} object The object to query.
        ' * @param {string} path The path of the property to get.
        ' * @param {dynamic} optional value in case no match.
        ' * @returns {*} Returns the resolved value.
        ' */
        get: function(obj as dynamic, path = "" as string, optionalValue = invalid as dynamic) as dynamic
            index = 0
            pathArray = path.split(".")
            len = pathArray.count()
            ' short circuit for invalid values
            if not (m.__implementsAssociativeArray(obj) or m.__implementsArray(obj)) or len = 0 then return optionalValue

            for index = 0 to len - 1
                if m.__implementsAssociativeArray(obj)
                    obj = obj[pathArray[index]]
                else if m.__implementsArray(obj) and pathArray[index].toInt().toStr() = pathArray[index]
                    obj = obj[pathArray[index].toInt()]
                else
                    obj = invalid
                end if
                if obj = invalid then exit for
            end for

            if (obj = invalid) or (index < len) then return optionalValue

            return obj
        end function


        '/**
        ' * The base implementation of `_.set`
        ' *
        ' * @private
        ' * @param {dynamic} object The object to query.
        ' * @param {string} path The path of the property to get.
        ' * @param {dynamic} value to assign.
        ' * @returns {*} Returns input object.
        ' */
        set: function(srcObj as dynamic, path = "" as string, value = invalid as dynamic) as dynamic
            index = 0
            pathArray = path.split(".")
            len = pathArray.count()
            maxIdx = len - 1
            ' short circuit for invalid values
            if not m.__implementsAssociativeArray(srcObj) or len = 0 then return srcObj

            obj = srcObj
            for index = 0 to maxIdx
                prop = pathArray[index]
                if not m.__implementsAssociativeArray(obj[prop]) then obj[prop] = {}
                if index = maxIdx
                    ' assign final value
                    obj[prop] = value
                else
                    obj = obj[prop]
                end if
            end for

            return srcObj
        end function


        '/**
        ' * Tries to create an array based on interfaces
        ' *
        ' * @param {Object} Array-like Object to convert
        ' */
        arrayFrom: function(collection as object) as object
            validInterfaceAdapter = {
                "ifSGNodeChildren": function(node as object) as object
                    length = node.getChildCount()
                    result = []
                    for i = 0 to (length - 1) step 1
                        result[i] = node.getChild(i)
                    end for
                    return result
                end function

                "ifAssociativeArray": function(assocArray as object) as object
                    result = []
                    for each key in assocArray
                        obj = {}
                        obj[key] = assocArray[key]
                        result.push(obj)
                    end for
                    return result
                end function
            }

            for each validType in validInterfaceAdapter
                if lCase(type(getInterface(collection, validType))) = validType
                    return validInterfaceAdapter[validType](collection)
                end if
            end for
            '...there was nothing
            return [collection]
        end function


        '/******************************************************************************
        ' *
        ' * HELPERS AND BASE FUNCTIONS ("__" prefixed)
        ' *
        ' * The base implementation of `_.findIndex` and `_.findLastIndex` without
        ' * support for iteratee shorthands.
        ' *
        ' * @param {Array} array The array to search.
        ' * @param {Function|AssociativeArray|String} predicate The function invoked per iteration.
        ' * @param {boolean} Specify iterating from right to left.
        ' * @returns {number} Returns the index of the matched value, else `-1`.
        ' */
        __baseFind: function(array as object, predicate as object, fromRight = false, params = {} as object) as integer
            length = array.count() - 1
            if fromRight then index = length else index = -1
            condition = length >= 0

            while (condition)
                if fromRight then
                    i = index
                    index -= 1
                    condition = index >= 0
                else
                    index += 1
                    i = index
                    condition = index < length
                end if

                if type(predicate) <> "roFunction"
                    if m.__propsComp(array[i], predicate) then return i
                else
                    if predicate(array[i], i, params) then return i
                end if
            end while

            return -1
        end function


        '/**
        ' * Base property comparator / contents check / property existence check
        ' *
        ' * @param {Object} AssociativeArray reference
        ' * @param {Dynamic} AssociativeArray to compare against or key to check for existence
        ' * @param {boolean} ask for the exact same number of keys - if false, one AssociativeArray
        ' *                  can contain a partial number of keys of the other and return true
        ' * @returns {boolean} Returns the object property check
        ' */
        __propsComp: function(srcObj as object, refObj as object, strict = false) as boolean
            ' no AssociativeArray for source? false then
            if not m.__implementsAssociativeArray(srcObj) then return false
            ' lets check for valid reference type returns
            refType = type(refObj)
            validRefObjects = {
                "roAssociativeArray": function(src as object, ref as object, strict = false) as boolean
                    srcLen = src.count()
                    refLen = ref.count()
                    if srcLen < refLen then props = src else props = ref
                    for each prop in props
                        if src[prop] <> ref[prop] then return false
                    end for
                    if strict then
                        return srcLen = refLen
                    else
                        return true
                    end if
                end function

                "roString": function(src as object, ref as string, strict = false) as boolean
                    return src[ref] <> invalid
                end function
            }

            if validRefObjects[refType] <> invalid then
                return validRefObjects[refType](srcObj, refObj, strict)
            else
                return false
            end if
        end function


        '/**
        ' * base check for associative array interface
        __implementsAssociativeArray: function(obj as object) as boolean
            return getInterface(obj, "ifAssociativeArray") <> invalid
        end function


        '/**
        ' * base check for array interface
        __implementsArray: function(obj as object) as boolean
            return getInterface(obj, "ifArray") <> invalid
        end function
    }

    return m[instanceId]
end function