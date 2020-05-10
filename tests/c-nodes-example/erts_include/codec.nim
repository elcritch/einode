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
      fields*: OrderedTable[string, ErlTerm]
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

proc newETerm*(b: nil): ErlTerm =
  ## Creates a new `EBool ErlTerm`.
  result = ErlTerm(kind: EBool, bval: b)

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

proc nilETerm*(): ErlTerm =
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
    default = initOrderedTable[string, ErlTerm](4)):
        OrderedTable[string, ErlTerm] =
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

proc add*(obj: ErlTerm, key: string, val: ErlTerm) =
  ## Sets a field from a `JObject`.
  assert obj.kind == EMap
  obj.fields[key] = val

proc `%`*[T](v: T): ErlTerm =
  ## Creates a new `EString ErlTerm`.
  result = newETerm(v)



macro generic_params(T: typedesc): untyped =
  result = newNimNode(nnkTupleConstr)
  var impl = getTypeImpl(T)
  expectKind(impl, nnkBracketExpr)
  impl = impl[1]
  while true:
    case impl.kind
      of nnkSym:
        impl = impl.getImpl
        continue
      of nnkTypeDef:
        impl = impl[2]
        continue
      of nnkBracketExpr:
        for i in 1..<impl.len:
          result.add impl[i]
        break
      else:
        error "wrong kind: " & $impl.kind


proc toJson(x: NimNode): NimNode {.compileTime.} =
  case x.kind
  of nnkBracket: # array
    if x.len == 0: return newCall(bindSym"newJArray")
    result = newNimNode(nnkBracket)
    for i in 0 ..< x.len:
      result.add(toJson(x[i]))
    result = newCall(bindSym("%", brOpen), result)
  of nnkTableConstr: # object
    if x.len == 0: return newCall(bindSym"newJObject")
    result = newNimNode(nnkTableConstr)
    for i in 0 ..< x.len:
      x[i].expectKind nnkExprColonExpr
      result.add newTree(nnkExprColonExpr, x[i][0], toJson(x[i][1]))
    result = newCall(bindSym("%", brOpen), result)
  of nnkCurly: # empty object
    x.expectLen(0)
    result = newCall(bindSym"newJObject")
  of nnkNilLit:
    result = newCall(bindSym"newJNull")
  of nnkPar:
    if x.len == 1: result = toJson(x[0])
    else: result = newCall(bindSym("%", brOpen), x)
  else:
    result = newCall(bindSym("%", brOpen), x)
