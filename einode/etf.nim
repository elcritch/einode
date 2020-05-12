import macros
import typetraits
import tables
import hashes
import ei

import options
export options


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
