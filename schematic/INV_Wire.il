;;============================================================
;; 인버터 Wire + Label 생성
;; Y_Skill_Test / INV  (Virtuoso 6.1.8 / tsmc18)
;;
;; 연결 규칙:
;;   Source  : 위(PMOS) / 아래(NMOS) 0.5 → VDD / VSS 라벨
;;   Body    : 오른쪽 0.5 → VDD(PMOS) / VSS(NMOS) 라벨
;;   Gate    : MP0↔MN0 L자 연결, 중심 왼쪽 0.5 → IN 라벨
;;   Drain   : MP0↔MN0 L자 연결, 중심 오른쪽 0.5 → OUT 라벨
;;
;; CIW 실행: vi로 저장 후 load("INV_Wire.il")
;;============================================================

;;------------------------------------------------------------
;; Helper: 인스턴스 이름으로 인스턴스 객체 반환
;;------------------------------------------------------------
procedure( getInst(cv instName)
  let( (result)
    foreach( inst cv~>instances
      when( inst~>name == instName
        result = inst ) )
    result ) )

;;------------------------------------------------------------
;; Helper: 핀 이름으로 중심 좌표 반환 (transform 포함)
;;   반환값: list(x y)
;;   사용법: car(...)  = x좌표
;;           cadr(...) = y좌표
;;------------------------------------------------------------
procedure( getPinCenter(inst pinName)
  let( (bBox cx cy result)
    foreach( term inst~>master~>terminals
      when( term~>name == pinName
        bBox = car(term~>pins)~>fig~>bBox
        cx = (caar(bBox) + caadr(bBox)) / 2.0
        cy = (cadar(bBox) + cadadr(bBox)) / 2.0
        result = dbTransformPoint(cx:cy inst~>transform) ) )
    result ) )

;;------------------------------------------------------------
;; Main: 인버터 Wire + Label 생성
;;------------------------------------------------------------
procedure( makeInvWires()
  let( (lib cell cv MP MN w
        ;; 핀 좌표 변수 (x/y 분리)
        MPGx MPGy MPDx MPDy MPSx MPSy MPBx MPBy
        MNGx MNGy MNDx MNDy MNSx MNSy MNBx MNBy
        ;; 계산된 끝점 좌표
        PS_endY PB_endX          ;; PMOS Source 위끝 / Body 오른쪽끝
        NS_endY NB_endX          ;; NMOS Source 아래끝 / Body 오른쪽끝
        Gvx GvTopY GvBotY        ;; Gate 수직선 x / 위끝y / 아래끝y
        gMidY IN_x               ;; Gate 중심y / IN 라벨 x
        Dvx DvTopY DvBotY        ;; Drain 수직선 x / 위끝y / 아래끝y
        dMidY OUT_x)             ;; Drain 중심y / OUT 라벨 x

    lib  = "Y_Skill_Test"
    cell = "INV"

    ;;--- cellview 열기 ("a" = 기존 소자 유지하고 추가)
    cv = dbOpenCellViewByType(lib cell "schematic" "schematic" "a")
    if( cv == nil then printf("ERROR\n") return(nil) )
    printf("OK cellView 열림\n")

    ;;--- 인스턴스 객체 가져오기
    MP = getInst(cv "MP0")   ;; PMOS
    MN = getInst(cv "MN0")   ;; NMOS

    ;;--- 핀 좌표 읽기 (x, y 변수로 분리 저장)
    ;;    x:y 표현식 안에 연산식을 쓰면 에러나므로 반드시 변수로 분리
    MPGx = car(getPinCenter(MP "G"))    MPGy = cadr(getPinCenter(MP "G"))
    MPDx = car(getPinCenter(MP "D"))    MPDy = cadr(getPinCenter(MP "D"))
    MPSx = car(getPinCenter(MP "S"))    MPSy = cadr(getPinCenter(MP "S"))
    MPBx = car(getPinCenter(MP "B"))    MPBy = cadr(getPinCenter(MP "B"))

    MNGx = car(getPinCenter(MN "G"))    MNGy = cadr(getPinCenter(MN "G"))
    MNDx = car(getPinCenter(MN "D"))    MNDy = cadr(getPinCenter(MN "D"))
    MNSx = car(getPinCenter(MN "S"))    MNSy = cadr(getPinCenter(MN "S"))
    MNBx = car(getPinCenter(MN "B"))    MNBy = cadr(getPinCenter(MN "B"))

    ;;--- 끝점 좌표 미리 계산
    PS_endY = MPSy + 0.5     ;; PMOS Source 위로 0.5
    PB_endX = MPBx + 0.5     ;; PMOS Body  오른쪽으로 0.5 (수정)
    NS_endY = MNSy - 0.5     ;; NMOS Source 아래로 0.5
    NB_endX = MNBx + 0.5     ;; NMOS Body  오른쪽으로 0.5 (수정)

    Gvx    = MPGx - 0.5      ;; Gate 수직선 x (-0.5)
    GvTopY = MPGy            ;; Gate 수직선 위끝 y
    GvBotY = MNGy            ;; Gate 수직선 아래끝 y
    gMidY  = (MPGy + MNGy) / 2.0   ;; Gate 수직선 중심 y
    IN_x   = Gvx - 0.5       ;; IN 라벨 x (중심에서 왼쪽 0.5)

    Dvx    = MPDx + 0.5      ;; Drain 수직선 x (+0.5)
    DvTopY = MPDy            ;; Drain 수직선 위끝 y
    DvBotY = MNDy            ;; Drain 수직선 아래끝 y
    dMidY  = (MPDy + MNDy) / 2.0   ;; Drain 수직선 중심 y
    OUT_x  = Dvx + 1.0       ;; OUT 라벨 x (중심에서 오른쪽 1.0)

    ;;----------------------------------------------------------
    ;; [1] PMOS Source → VDD
    ;;     S(MPSx, MPSy) 에서 위로 0.5 → (MPSx, PS_endY)
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(MPSx:MPSy  MPSx:PS_endY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) MPSx:PS_endY
          "VDD" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK [1] PMOS Source → VDD\n")

    ;;----------------------------------------------------------
    ;; [2] PMOS Body → VDD
    ;;     B(MPBx, MPBy) 에서 오른쪽으로 0.5 → (PB_endX, MPBy)
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(MPBx:MPBy  PB_endX:MPBy)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) PB_endX:MPBy
          "VDD" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK [2] PMOS Body → VDD\n")

    ;;----------------------------------------------------------
    ;; [3] NMOS Source → VSS
    ;;     S(MNSx, MNSy) 에서 아래로 0.5 → (MNSx, NS_endY)
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(MNSx:MNSy  MNSx:NS_endY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) MNSx:NS_endY
          "VSS" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK [3] NMOS Source → VSS\n")

    ;;----------------------------------------------------------
    ;; [4] NMOS Body → VSS
    ;;     B(MNBx, MNBy) 에서 오른쪽으로 0.5 → (NB_endX, MNBy)
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(MNBx:MNBy  NB_endX:MNBy)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) NB_endX:MNBy
          "VSS" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK [4] NMOS Body → VSS\n")

    ;;----------------------------------------------------------
    ;; [5] Gate 연결: MP0 G ↔ MN0 G  (L자 4점 와이어)
    ;;     MP0 G → 왼쪽(Gvx) → 아래로 → MN0 G
    ;;----------------------------------------------------------
    schCreateWire(cv "draw" "full"
          list(MPGx:MPGy  Gvx:GvTopY  Gvx:GvBotY  MNGx:MNGy)
          0.0625 0.0625 0)
    printf("OK [5] Gate 연결 MP0 ↔ MN0\n")

    ;;----------------------------------------------------------
    ;; [6] IN wire + 라벨
    ;;     Gate 수직선 중심(Gvx, gMidY) 에서 왼쪽 0.5 → (IN_x, gMidY)
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(Gvx:gMidY  IN_x:gMidY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) IN_x:gMidY
          "IN" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK [6] IN 라벨\n")

    ;;----------------------------------------------------------
    ;; [7] Drain 연결: MP0 D ↔ MN0 D  (L자 4점 와이어)
    ;;     MP0 D → 오른쪽(Dvx) → 아래로 → MN0 D
    ;;----------------------------------------------------------
    schCreateWire(cv "draw" "full"
          list(MPDx:MPDy  Dvx:DvTopY  Dvx:DvBotY  MNDx:MNDy)
          0.0625 0.0625 0)
    printf("OK [7] Drain 연결 MP0 ↔ MN0\n")

    ;;----------------------------------------------------------
    ;; [8] OUT wire + 라벨
    ;;     Drain 수직선 중심(Dvx, dMidY) 에서 오른쪽 1.0 → (OUT_x, dMidY)
    ;;----------------------------------------------------------
    w = schCreateWire(cv "draw" "full"
          list(Dvx:dMidY  OUT_x:dMidY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) OUT_x:dMidY
          "OUT" "lowerLeft" "R0" "fixed" 0.0625 nil)
    printf("OK [8] OUT 라벨\n")

    ;;--- 저장 및 닫기
    dbSave(cv)
    dbClose(cv)
    printf("==========================================\n")
    printf("DONE: %s/%s/schematic wire 완료\n" lib cell)
    printf("==========================================\n") ) )

makeInvWires()
