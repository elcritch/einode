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
    ETuple0,
    ETuple1,
    ETuple2,
    ETuple3,
    ETuple4,
    ETuple5,
    ETuple6,
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
      un32*: uint32
    of EUInt64:
      un64*: uint64
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
    of ETuple0:
      tpl0*: tuple[]
    of ETuple1:
      tpl1*: tuple[f0: ErlTerm]
    of ETuple2:
      tpl2*: tuple[f0: ErlTerm, f1: ErlTerm]
    of ETuple3:
      tpl3*: tuple[f0: ErlTerm, f1: ErlTerm, f2: ErlTerm]
    of ETuple4:
      tpl4*: tuple[f0: ErlTerm, f1: ErlTerm, f2: ErlTerm, f3: ErlTerm]
    of ETuple5:
      tpl5*: tuple[f0: ErlTerm, f1: ErlTerm, f2: ErlTerm, f3: ErlTerm, f4: ErlTerm]
    of ETuple6:
      tpl6*: tuple[f0: ErlTerm, f1: ErlTerm, f2: ErlTerm, f3: ErlTerm, f4: ErlTerm, f5: ErlTerm]
    of ETupleN:
      tpl_elems*: seq[ErlTerm]
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

proc newETerm*(n: float32): ErlTerm =
  ## Creates a new `EFloat ErlTerm`.
  result = ErlTerm(kind: EFloat32, f32: n)

proc newETerm*(n: float64): ErlTerm =
  ## Creates a new `EFloat ErlTerm`.
  result = ErlTerm(kind: EFloat64, f64: n)

proc newETerm*(s: ErlAtom): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: EAtom, atm: s)

proc newETerm*(s: string): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: EString, str: s)

proc newETerm*(s: seq[char]): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = ErlTerm(kind: EBinary, bin: s)

proc newEList*(): ErlTerm =
  ## Creates a new `JObject JsonNode`
  result = ErlTerm(kind: EList, elems: @[])

proc newEMap*(): ErlTerm =
  ## Creates a new `JObject JsonNode`
  result = ErlTerm(kind: EMap, fields: initOrderedTable[ErlTerm, ErlTerm](4))

proc newENil*(): ErlTerm =
  ## Creates a new `ENil ErlTerm`.
  result = ErlTerm(kind: ENil)

proc getBool*(n: ErlTerm, default: bool = false): bool =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBool: return default
  else: return n.bval

proc getInt32*(n: ErlTerm, default: int32 = 0): int32 =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EInt32: return default
  else: return n.n32

proc getInt64*(n: ErlTerm, default: int64 = 0): int64 =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EInt64: return default
  else: return n.n64

proc getFloat32*(n: ErlTerm, default: float32 = 0): float32 =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EFloat32: return default
  else: return n.f32

proc getFloat64*(n: ErlTerm, default: float64 = 0): float64 =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EFloat64: return default
  else: return n.f64

proc getAtom*(n: ErlTerm, default: ErlAtom = AtomOk ): ErlAtom =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EFloat64: return default
  else: return n.atm

proc getString*(n: ErlTerm, default: string = ""): string =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EString: return default
  else: return n.str

proc getBinary*(n: ErlTerm, default: seq[char] = @[]): seq[char] =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBinary: return default
  else: return n.bin

proc getBitBinary*(n: ErlTerm, default: seq[char] = @[]): seq[char] =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBitBinary: return default
  else: return n.bit

proc getCharList*(n: ErlTerm, default: seq[char] = @[]): seq[char] =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != ECharList: return default
  else: return n.chars

proc getRef*(n: ErlTerm): Option[ErlRef] =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBitBinary: return none(ErlRef)
  else: return some(n.eref)

proc getPid*(n: ErlTerm): Option[ErlPid] =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBitBinary: return none(ErlPid)
  else: return some(n.epid)

proc getFun*(n: ErlTerm): Option[ErlFun] =
  ## Retrieves the string value of a `JString JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JString``, or if ``n`` is nil.
  if n.isNil or n.kind != EBitBinary: return none(ErlFun)
  else: return some(n.efun)

proc getFields*(n: ErlTerm,
    default = initOrderedTable[ErlTerm, ErlTerm](4)):
        OrderedTable[ErlTerm, ErlTerm] =
  ## Retrieves the key, value pairs of a `JObject JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JObject``, or if ``n`` is nil.
  if n.isNil or n.kind != EMap: return default
  else: return n.fields

proc getList*(n: ErlTerm, default: seq[ErlTerm] = @[]): seq[ErlTerm] =
  ## Retrieves the array of a `JArray JsonNode`.
  ##
  ## Returns ``default`` if ``n`` is not a ``JArray``, or if ``n`` is nil.
  if n.isNil or n.kind != EList: return default
  else: return n.elems


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
  ## Construct JsonNode from tuples and objects.
  result = newETerm()
  for k, v in o.fieldPairs: result[k] = %v

proc `%`*(o: ref object): ErlTerm =
  ## Generic constructor for JSON data. Creates a new `JObject JsonNode`
  if o.isNil:
    result = newENil()
  else:
    result = %(o[])

proc `%`*(o: enum): ErlTerm =
  ## Construct a JsonNode that represents the specified enum value as a
  ## string. Creates a new ``JString JsonNode``.
  result = %($o)

proc toJson(x: NimNode): NimNode {.compileTime.} =
  case x.kind
  of nnkBracket: # array
    if x.len == 0: return newCall(bindSym"newEList")
    result = newNimNode(nnkBracket)
    for i in 0 ..< x.len:
      result.add(toJson(x[i]))
    result = newCall(bindSym("%", brOpen), result)
  of nnkTableConstr: # object
    if x.len == 0: return newCall(bindSym"newEMap")
    result = newNimNode(nnkTableConstr)
    for i in 0 ..< x.len:
      x[i].expectKind nnkExprColonExpr
      result.add newTree(nnkExprColonExpr, x[i][0], toJson(x[i][1]))
    result = newCall(bindSym("%", brOpen), result)
  of nnkCurly: # empty object
    x.expectLen(0)
    result = newCall(bindSym"newEMap")
  of nnkNilLit:
    result = newCall(bindSym"newENil")
  of nnkPar:
    if x.len == 1: result = toJson(x[0])
    else: result = newCall(bindSym("%", brOpen), x)
  else:
    result = newCall(bindSym("%", brOpen), x)

macro `%*`*(x: untyped): untyped =
  ## Convert an expression to a JsonNode directly, without having to specify
  ## `%` for every element.
  result = toJson(x)

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
    of EPid:
      result = a.epid == b.epid
    of ERef:
      result = a.eref == b.eref
    of EFun:
      result = a.efun == b.efun
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

proc hash*(n: ErlPid): Hash =
    n.val.hash()
proc hash*(n: ErlAtom): Hash =
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
    of EString:
      result = hash(n.str)
    of EBinary:
      result = hash(n.bin)
    of EBitBinary:
      result = hash(n.bit)
    of EPid:
      result = hash(n.epid)
    of ERef:
      result = hash(n.eref)
    of EFun:
      result = hash(n.epid)
    of EList:
      result = hash(n.elems)
    of ECharList:
      result = hash(n.chars)
    of EMap:
      result = hash(n.fields)


proc hash*(n: OrderedTable[ErlTerm, ErlTerm]): Hash =
  for key, val in n:
    result = result xor (hash(key) !& hash(val))
  result = !$result

proc hash*(n: OrderedTable[ErlTerm, ErlTerm]): Hash =
  for key, val in n:
    result = result xor (hash(key) !& hash(val))
  result = !$result

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
  assert(node.kind == JObject)
  when defined(nimErlGet):
    if not node.fields.hasKey(name): return nil
  result = node.fields[name]

proc `[]`*(node: ErlTerm, index: int): ErlTerm {.inline.} =
  ## Gets the node at `index` in an Array. Result is undefined if `index`
  ## is out of bounds, but as long as array bound checks are enabled it will
  ## result in an exception.
  assert(not isNil(node))
  assert(node.kind == JArray)
  return node.elems[index]


