;;============================================================
;; 인버터 Wire + Label 생성
;; Y_Skill_Test / INV
;; CIW: load("INV_Wire.il")
;;============================================================

procedure( getInst(cv instName)
  let( (result)
    foreach( inst cv~>instances
      when( inst~>name == instName
        result = inst
      )
    )
    result
  )
)

procedure( getPinCenter(inst pinName)
  let( (bBox cx cy result)
    foreach( term inst~>master~>terminals
      when( term~>name == pinName
        bBox   = car(term~>pins)~>fig~>bBox
        cx     = (caar(bBox)  + caadr(bBox))  / 2.0
        cy     = (cadar(bBox) + cadadr(bBox)) / 2.0
        result = dbTransformPoint(cx:cy inst~>transform)
      )
    )
    result
  )
)

procedure( makeInvWires()
  let( (lib cell cv MP MN w
        MPG MPD MPS MPB
        MNG MND MNS MNB
        ;; 모든 좌표를 변수로 분리
        MPGx MPGy  MPDx MPDy  MPSx MPSy  MPBx MPBy
        MNGx MNGy  MNDx MNDy  MNSx MNSy  MNBx MNBy
        ;; 계산 좌표
        PS_endY  PB_endY
        NS_endY  NB_endY
        Gvx      GvTopY  GvBotY
        gMidX    gMidY   IN_x
        Dvx      DvTopY  DvBotY
        dMidX    dMidY   OUT_x)

    lib  = "Y_Skill_Test"
    cell = "INV"

    cv = dbOpenCellViewByType(lib cell "schematic" "schematic" "a")
    if( cv == nil then
      printf("ERROR: cellView 열기 실패\n")
      return(nil)
    )
    printf("OK  cellView 열림: %s/%s/schematic\n" lib cell)

    MP = getInst(cv "MP0")
    MN = getInst(cv "MN0")

    MPG = getPinCenter(MP "G")   MPD = getPinCenter(MP "D")
    MPS = getPinCenter(MP "S")   MPB = getPinCenter(MP "B")
    MNG = getPinCenter(MN "G")   MND = getPinCenter(MN "D")
    MNS = getPinCenter(MN "S")   MNB = getPinCenter(MN "B")

    printf("MP0: G=%L D=%L S=%L B=%L\n" MPG MPD MPS MPB)
    printf("MN0: G=%L D=%L S=%L B=%L\n" MNG MND MNS MNB)

    ;;--- 모든 좌표를 변수에 저장 (연산을 : 앞뒤에서 하지 않기 위해)
    MPGx = car(MPG)   MPGy = cadr(MPG)
    MPDx = car(MPD)   MPDy = cadr(MPD)
    MPSx = car(MPS)   MPSy = cadr(MPS)
    MPBx = car(MPB)   MPBy = cadr(MPB)

    MNGx = car(MNG)   MNGy = cadr(MNG)
    MNDx = car(MND)   MNDy = cadr(MND)
    MNSx = car(MNS)   MNSy = cadr(MNS)
    MNBx = car(MNB)   MNBy = cadr(MNB)

    ;;--- 끝점 좌표 계산 (변수로 미리 저장)
    PS_endY = MPSy + 0.5
    PB_endY = MPBy + 0.5
    NS_endY = MNSy - 0.5
    NB_endY = MNBy - 0.5

    Gvx     = MPGx - 0.5
    GvTopY  = MPGy
    GvBotY  = MNGy
    gMidY   = (MPGy + MNGy) / 2.0
    IN_x    = Gvx - 0.5

    Dvx     = MPDx + 0.5
    DvTopY  = MPDy
    DvBotY  = MNDy
    dMidY   = (MPDy + MNDy) / 2.0
    OUT_x   = Dvx + 0.5

    ;;----------------------------------------------------------
    ;; [1] PMOS Source → VDD
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(MPSx:MPSy  MPSx:PS_endY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) MPSx:PS_endY
      "VDD" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK  [1] PMOS Source → VDD\n")

    ;;----------------------------------------------------------
    ;; [2] PMOS Bulk → VDD
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(MPBx:MPBy  MPBx:PB_endY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) MPBx:PB_endY
      "VDD" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK  [2] PMOS Bulk → VDD\n")

    ;;----------------------------------------------------------
    ;; [3] NMOS Source → VSS
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(MNSx:MNSy  MNSx:NS_endY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) MNSx:NS_endY
      "VSS" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK  [3] NMOS Source → VSS\n")

    ;;----------------------------------------------------------
    ;; [4] NMOS Bulk → VSS
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(MNBx:MNBy  MNBx:NB_endY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) MNBx:NB_endY
      "VSS" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK  [4] NMOS Bulk → VSS\n")

    ;;----------------------------------------------------------
    ;; [5] Gate 연결: MP0 G ↔ MN0 G (L자)
    ;;----------------------------------------------------------
    schCreateWire(cv "draw" "full"
      list(MPGx:MPGy  Gvx:GvTopY  Gvx:GvBotY  MNGx:MNGy)
      0.0625 0.0625 0)
    printf("OK  [5] Gate 연결 MP0 ↔ MN0\n")

    ;;----------------------------------------------------------
    ;; [6] IN wire + 라벨
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(Gvx:gMidY  IN_x:gMidY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) IN_x:gMidY
      "IN" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK  [6] IN 라벨\n")

    ;;----------------------------------------------------------
    ;; [7] Drain 연결: MP0 D ↔ MN0 D (L자)
    ;;----------------------------------------------------------
    schCreateWire(cv "draw" "full"
      list(MPDx:MPDy  Dvx:DvTopY  Dvx:DvBotY  MNDx:MNDy)
      0.0625 0.0625 0)
    printf("OK  [7] Drain 연결 MP0 ↔ MN0\n")

    ;;----------------------------------------------------------
    ;; [8] OUT wire + 라벨
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(Dvx:dMidY  OUT_x:dMidY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) OUT_x:dMidY
      "OUT" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK  [8] OUT 라벨\n")

    dbSave(cv)
    dbClose(cv)
    printf("==========================================\n")
    printf("DONE: %s/%s/schematic wire 완료\n" lib cell)
    printf("==========================================\n")
  )
)

makeInvWires()
