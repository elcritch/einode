import macros
import typetraits
import tables
import hashes
import ei

import options
export options

type
  ErlAtom* = object
    val*: string
  ErlRef* = object
    val*: string
  ErlPid* = object
    val*: string
  ErlFun* = object
    val*: string
  ErlCharlist* = seq[char]

proc hash*(a: ErlAtom): Hash =
  result = a.val.hash
  result = !$result

const AtomOk* = ErlAtom(val: "ok")
const AtomError* = ErlAtom(val: "error")
const AtomTrue* = ErlAtom(val: "true")
const AtomFalse* = ErlAtom(val: "false")


type
  ErlTermKind* = enum ## possible JSON node types
    ENil,
    EBool,
    EInt32,
    EUInt32,
    EInt64,
    EUInt64,
    EFloat32,
    EFloat64,
    EAtom,
    # Erlang Types
    EString,
    EBinary,
    EBitBinary,
    # Erlang Types
    ERef,
    EPid,
    EFun,
    # Composite
    EMap,
    EList,
    ECharList,
    ETupleN

  ErlTerm* = ref ErlTermObj ## JSON node
  ErlTermObj* {.acyclic.} = object
    case kind*: ErlTermKind
    of ENil:
      nil
    of EBool:
      bval*: bool
    of EInt32:
      n32*: int32
    of EUInt32:
      u32*: uint32
    of EUInt64:
      u64*: uint64
    of EInt64:
      n64*: int64
    of EFloat32:
      f32*: float32
    of EFloat64:
      f64*: float64
    of EAtom:
      atm*: ErlAtom
    # Erlang Types
    of EString:
      str*: string
    of EBinary:
      bin*: seq[char]
    of EBitBinary:
      bit*: seq[char]
    # Erlang Types
    of ERef:
      eref*: ErlRef
    of EPid:
      epid*: ErlPid
    of EFun:
      efun*: ErlFun
    # Composite
    of EMap:
      fields*: OrderedTable[ErlTerm, ErlTerm]
    of ETupleN:
      items*: seq[ErlTerm]
    of EList:
      elems*: seq[ErlTerm]
    of ECharList:
      chars*: seq[char]

proc newETerm*(s: bool): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: EBool, bval: s)

proc newETerm*(n: int): ErlTerm =
  ## Creates a new `EInt ErlTerm`.
  result = ErlTerm(kind: EInt64, n64: n)

proc newETerm*(n: int32): ErlTerm =
  ## Creates a new `EInt ErlTerm`.
  result = ErlTerm(kind: EInt32, n32: n)

proc newETerm*(n: int64): ErlTerm =
  ## Creates a new `EInt ErlTerm`.
  result = ErlTerm(kind: EInt64, n64: n)

proc newETerm*(n: uint32): ErlTerm =
  ## Creates a new `EInt ErlTerm`.
  result = ErlTerm(kind: EUInt32, u32: n)

proc newETerm*(n: uint64): ErlTerm =
  ## Creates a new `EInt ErlTerm`.
  result = ErlTerm(kind: EUInt64, u64: n)

proc newETerm*(n: float32): ErlTerm =
  ## Creates a new `EFloat ErlTerm`.
  result = ErlTerm(kind: EFloat32, f32: n)

proc newETerm*(n: float64): ErlTerm =
  ## Creates a new `EFloat ErlTerm`.
  result = ErlTerm(kind: EFloat64, f64: n)

proc newETerm*(s: ErlAtom): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: EAtom, atm: s)

proc newETerm*(s: ErlPid): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: EPid, epid: s)

proc newETerm*(s: ErlRef): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: ERef, eref: s)

proc newETerm*(s: string): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: EString, str: s)

proc newETerm*(s: seq[char]): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: EBinary, bin: s)

proc newETuple*(): ErlTerm =
  ## Creates a new `JObject ErlTerm`
  result = ErlTerm(kind: ETupleN, items: @[])

proc newEList*(): ErlTerm =
  ## Creates a new `JObject ErlTerm`
  result = ErlTerm(kind: EList, elems: @[])

proc newEMap*(): ErlTerm =
  ## Creates a new `JObject ErlTerm`
  result = ErlTerm(kind: EMap, fields: initOrderedTable[ErlTerm, ErlTerm](4))

proc newENil*(): ErlTerm =
  ## Creates a new `ENil ErlTerm`.
  result = ErlTerm(kind: ENil)

proc getBool*(n: ErlTerm, default: bool = false): bool =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBool: return default
  else: return n.bval

proc getInt32*(n: ErlTerm, default: int32 = 0): int32 =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EInt32: return default
  else: return n.n32

proc getInt64*(n: ErlTerm, default: int64 = 0): int64 =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EInt64: return default
  else: return n.n64

proc getFloat32*(n: ErlTerm, default: float32 = 0): float32 =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EFloat32: return default
  else: return n.f32

proc getFloat64*(n: ErlTerm, default: float64 = 0): float64 =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EFloat64: return default
  else: return n.f64

proc getAtom*(n: ErlTerm, default: ErlAtom = AtomOk ): ErlAtom =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EFloat64: return default
  else: return n.atm

proc getString*(n: ErlTerm, default: string = ""): string =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EString: return default
  else: return n.str

proc getBinary*(n: ErlTerm, default: seq[char] = @[]): seq[char] =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBinary: return default
  else: return n.bin

proc getBitBinary*(n: ErlTerm, default: seq[char] = @[]): seq[char] =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBitBinary: return default
  else: return n.bit

proc getCharList*(n: ErlTerm, default: seq[char] = @[]): seq[char] =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != ECharList: return default
  else: return n.chars

proc getRef*(n: ErlTerm): Option[ErlRef] =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBitBinary: return none(ErlRef)
  else: return some(n.eref)

proc getPid*(n: ErlTerm): Option[ErlPid] =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBitBinary: return none(ErlPid)
  else: return some(n.epid)

proc getFun*(n: ErlTerm): Option[ErlFun] =
  ## Retrieves the string value of a `JString ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBitBinary: return none(ErlFun)
  else: return some(n.efun)

proc getFields*(n: ErlTerm,
    default = initOrderedTable[ErlTerm, ErlTerm](4)):
        OrderedTable[ErlTerm, ErlTerm] =
  ## Retrieves the key, value pairs of a `JObject ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JObject``, or if ``n`` is nil.
  if n.isNil or n.kind != EMap: return default
  else: return n.fields

proc getList*(n: ErlTerm, default: seq[ErlTerm] = @[]): seq[ErlTerm] =
  ## Retrieves the array of a `JArray ErlTerm`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JArray``, or if ``n`` is nil.
  if n.isNil or n.kind != EList: return default
  else: return n.elems


proc hash*(n: ErlPid): Hash =
    n.val.hash()
proc hash*(n: ErlRef): Hash =
    n.val.hash()
proc hash*(n: ErlFun): Hash =
    n.val.hash()

proc hash*(n: OrderedTable[ErlTerm, ErlTerm]): Hash {.noSideEffect.}

proc hash*(n: ErlTerm): Hash =
  ## Compute the hash for a JSON node
  case n.kind
    of ENil:
      result = Hash(0)
    of EBool:
      result = hash(n.bval.int)
    of EInt32:
      result = hash(n.n32)
    of EInt64:
      result = hash(n.n64)
    of EFloat32:
      result = hash(n.f32)
    of EFloat64:
      result = hash(n.f64)
    of EUInt32:
      result = hash(n.u32)
    of EUInt64:
      result = hash(n.u64)
    of EString:
      result = hash(n.str)
    of EBinary:
      result = hash(n.bin)
    of EBitBinary:
      result = hash(n.bit)
    of EAtom:
      result = hash(n.atm)
    of EPid:
      result = hash(n.epid)
    of ERef:
      result = hash(n.eref)
    of EFun:
      result = hash(n.epid)
    of EList:
      result = hash(n.elems)
    of ETupleN:
      result = hash(n.items)
    of ECharList:
      result = hash(n.chars)
    of EMap:
      result = hash(n.fields)


proc hash*(n: OrderedTable[ErlTerm, ErlTerm]): Hash =
  for key, val in n:
    result = result xor (hash(key) !& hash(val))
  result = !$result

proc add*(father, child: ErlTerm) =
  ## Adds `child` to a JArray node `father`.
  assert father.kind == EList
  father.elems.add(child)

proc add*(obj: ErlTerm, key: ErlTerm, val: ErlTerm) =
  ## Sets a field from a `JObject`.
  assert obj.kind == EMap
  obj.fields[key] = val

proc `%`*[T](v: T): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = newETerm(v)

proc `[]=`*(obj: ErlTerm, key: ErlTerm, val: ErlTerm) {.inline.} =
  ## Sets a field from a `JObject`.
  assert(obj.kind == EMap)
  obj.fields[key] = val

proc `%`*[T: object](o: T): ErlTerm =
  ## Construct ErlTerm from tuples and objects.
  result = newETerm()
  for k, v in o.fieldPairs: result[k] = %v

proc `%`*(o: ref object): ErlTerm =
  ## Generic constructor for JSON data. Creates a new `JObject ErlTerm`
  if o.isNil:
    result = newENil()
  else:
    result = %(o[])

proc `%`*(o: enum): ErlTerm =
  ## Construct a ErlTerm that represents the specified enum value as a
  ## string. Creates a new ``JString ErlTerm``.
  result = %($o)

proc toTerm(x: NimNode): NimNode {.compileTime.} =
  case x.kind
  of nnkBracket: # array
    if x.len == 0: return newCall(bindSym"newEList")
    result = newNimNode(nnkBracket)
    for i in 0 ..< x.len:
      result.add(toTerm(x[i]))
    result = newCall(bindSym("%", brOpen), result)
  of nnkTableConstr: # object
    if x.len == 0: return newCall(bindSym"newEMap")
    result = newNimNode(nnkTableConstr)
    for i in 0 ..< x.len:
      x[i].expectKind nnkExprColonExpr
      result.add newTree(nnkExprColonExpr, x[i][0], toTerm(x[i][1]))
    result = newCall(bindSym("%", brOpen), result)
  of nnkCurly: # empty object
    x.expectLen(0)
    result = newCall(bindSym"newEMap")
  of nnkNilLit:
    result = newCall(bindSym"newENil")
  of nnkPar:
    if x.len == 1: result = toTerm(x[0])
    else: result = newCall(bindSym("%", brOpen), x)
  else:
    result = newCall(bindSym("%", brOpen), x)

macro `%*`*(x: untyped): untyped =
  ## Convert an expression to a ErlTerm directly, without having to specify
  ## `%` for every element.
  result = toTerm(x)

proc `==`*(a, b: ErlTerm): bool =
  ## Check two nodes for equality
  if a.isNil:
    if b.isNil: return true
    return false
  elif b.isNil or a.kind != b.kind:
    return false
  else:
    case a.kind
    of ENil:
      result = true
    of EBool:
      result = a.bval == b.bval
    of EInt32:
      result = a.n32 == b.n32
    of EInt64:
      result = a.n64 == b.n64
    of EUInt32:
      result = a.u32 == b.u32
    of EUInt64:
      result = a.u64 == b.u64
    of EFloat32:
      result = a.f32 == b.f32
    of EFloat64:
      result = a.f64 == b.f64
    of EString:
      result = a.str == b.str
    of EBinary:
      result = a.bin == b.bin
    of EBitBinary:
      result = a.bit == b.bit
    of EAtom:
      result = a.atm == b.atm
    of EPid:
      result = a.epid == b.epid
    of ERef:
      result = a.eref == b.eref
    of EFun:
      result = a.efun == b.efun
    of ETupleN:
      result = a.items == b.items
    of EList:
      result = a.elems == b.elems
    of ECharList:
      result = a.chars == b.chars
    of EMap:
      # we cannot use OrderedTable's equality here as
      # the order does not matter for equality here.
      if a.fields.len != b.fields.len: return false
      for key, val in a.fields:
        if not b.fields.hasKey(key): return false
        if b.fields[key] != val: return false
      result = true


proc len*(n: ErlTerm): int =
  ## If `n` is a `JArray`, it returns the number of elements.
  ## If `n` is a `JObject`, it returns the number of pairs.
  ## Else it returns 0.
  case n.kind
  of EList: result = n.elems.len
  of EMap: result = n.fields.len
  else: discard

proc `[]`*(node: ErlTerm, name: ErlTerm): ErlTerm {.inline.} =
  ## Gets a field from a `JObject`, which must not be nil.
  ## If the value at `name` does not exist, raises KeyError.
  assert(not isNil(node))
  assert(node.kind == EMap)
  when defined(nimErlGet):
    if not node.fields.hasKey(name): return nil
  result = node.fields[name]

proc `[]`*(node: ErlTerm, index: int): ErlTerm {.inline.} =
  ## Gets the node at `index` in an Array. Result is undefined if `index`
  ## is out of bounds, but as long as array bound checks are enabled it will
  ## result in an exception.
  assert(not isNil(node))
  assert(node.kind == EList)
  return node.elems[index]

proc hasKey*(node: ErlTerm, key: ErlTerm): bool =
  ## Checks if `key` exists in `node`.
  assert(node.kind == EMap)
  result = node.fields.hasKey(key)

proc contains*(node: ErlTerm, key: ErlTerm): bool =
  ## Checks if `key` exists in `node`.
  assert(node.kind == EMap)
  node.fields.hasKey(key)

proc contains*(node: ErlTerm, val: ErlTerm): bool =
  ## Checks if `val` exists in array `node`.
  assert(node.kind == EList)
  find(node.elems, val) >= 0

proc `{}`*(node: ErlTerm, keys: varargs[ErlTerm]): ErlTerm =
  ## Traverses the node and gets the given value. If any of the
  ## keys do not exist, returns ``nil``. Also returns ``nil`` if one of the
  ## intermediate data structures is not an object.
  ##
  ## This proc can be used to create tree structures on the
  ## fly (sometimes called `autovivification`:idx:):
  ##
  ## .. code-block:: nim
  ##   myjson{"parent", "child", "grandchild"} = newJInt(1)
  ##
  result = node
  for key in keys:
    if isNil(result) or result.kind != EMap:
      return nil
    result = result.fields.getOrDefault(key)

proc `{}`*(node: ErlTerm, index: varargs[int]): ErlTerm =
  ## Traverses the node and gets the given value. If any of the
  ## indexes do not exist, returns ``nil``. Also returns ``nil`` if one of the
  ## intermediate data structures is not an array.
  result = node
  for i in index:
    if isNil(result) or result.kind != EList or i >= node.len:
      return nil
    result = result.elems[i]

proc getOrDefault*(node: ErlTerm, key: ErlTerm): ErlTerm =
  ## Gets a field from a `node`. If `node` is nil or not an object or
  ## value at `key` does not exist, returns nil
  if not isNil(node) and node.kind == EMap:
    result = node.fields.getOrDefault(key)

proc `{}`*(node: ErlTerm, key: ErlTerm): ErlTerm =
  ## Gets a field from a `node`. If `node` is nil or not an object or
  ## value at `key` does not exist, returns nil
  node.getOrDefault(key)

proc `{}=`*(node: ErlTerm, keys: varargs[ErlTerm], value: ErlTerm) =
  ## Traverses the node and tries to set the value at the given location
  ## to ``value``. If any of the keys are missing, they are added.
  var node = node
  for i in 0..(keys.len-2):
    if not node.hasKey(keys[i]):
      node[keys[i]] = newEMap()
    node = node[keys[i]]
  node[keys[keys.len-1]] = value

proc delete*(obj: ErlTerm, key: ErlTerm) =
  ## Deletes ``obj[key]``.
  assert(obj.kind == EMap)
  if not obj.fields.hasKey(key):
    raise newException(KeyError, "key not in object")
  obj.fields.del(key)

proc copy*(p: ErlTerm): ErlTerm =
  ## Performs a deep copy of `a`.
  case p.kind
  of ENil:
    result = newENil()
  of EBool:
    result = newETerm(p.bval)
  of EInt32:
    result = newETerm(p.n32)
  of EInt64:
    result = newETerm(p.n64)
  of EUInt32:
    result = newETerm(p.u32)
  of EUInt64:
    result = newETerm(p.u64)
  of EFloat32:
    result = newETerm(p.f32)
  of EFloat64:
    result = newETerm(p.f64)
  of EString:
    result = newETerm(p.str)
  of EBinary:
    result = newETerm(p.bin)
  of EBitBinary:
    result = newETerm(p.bit)
  of EAtom:
    result = newETerm(p.atm)
  of EPid:
    result = newETerm(p.epid)
  of ERef:
    result = newETerm(p.eref)
  of EFun:
    result = newETerm(p.epid)
  of ECharList:
    result = newETerm(p.chars)
  of ETupleN:
    result = newETuple()
    for i in items(p.elems):
      result.elems.add(copy(i))
  of Emap:
    result = newEMap()
    for key, val in pairs(p.fields):
      result.fields[key] = copy(val)
  of EList:
    result = newEList()
    for i in items(p.elems):
      result.elems.add(copy(i))


proc toUgly*(result: var string, node: ErlTerm) =
  ## Converts `node` to its JSON Representation, without
  ## regard for human readability. Meant to improve ``$`` string
  ## conversion performance.
  ##
  ## JSON representation is stored in the passed `result`
  ##
  ## This provides higher efficiency than the ``pretty`` procedure as it
  ## does **not** attempt to format the resulting JSON to make it human readable.
  ## 
  case p.kind
  of ENil:
    result = newENil()
  of EBool:
    result = newETerm(p.bval)
  of EInt32:
    result = newETerm(p.n32)
  of EInt64:
    result = newETerm(p.n64)
  of EUInt32:
    result = newETerm(p.u32)
  of EUInt64:
    result = newETerm(p.u64)
  of EFloat32:
    result = newETerm(p.f32)
  of EFloat64:
    result = newETerm(p.f64)
  of EString:
    result = newETerm(p.str)
  of EBinary:
    result = newETerm(p.bin)
  of EBitBinary:
    result = newETerm(p.bit)
  of EAtom:
    result = newETerm(p.atm)
  of EPid:
    result = newETerm(p.epid)
  of ERef:
    result = newETerm(p.eref)
  of EFun:
    result = newETerm(p.epid)
  of ECharList:
    result = newETerm(p.chars)
  of ETupleN:
    result = newETuple()
    for i in items(p.elems):
      result.elems.add(copy(i))
  of Emap:
    result = newEMap()
    for key, val in pairs(p.fields):
      result.fields[key] = copy(val)
  of EList:
    result = newEList()
    for i in items(p.elems):
      result.elems.add(copy(i))
  
