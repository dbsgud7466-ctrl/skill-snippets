;;============================================================
;; 인버터 핀 좌표 읽기
;; 와이어 연결 전 각 트랜지스터의 G/D/S/B 위치 확인
;;
;; CIW 실행:
;;   load("INV_PinCoordinate.il")
;;============================================================

;;------------------------------------------------------------
;; Helper: 인스턴스 이름으로 인스턴스 객체 가져오기
;;------------------------------------------------------------
procedure( getInst(cv instName)
  let( (found)
    found = nil
    foreach( inst cv~>instances
      when( inst~>name == instName
        found = inst
      )
    )
    if( found
      then found
      else
        printf("ERROR: 인스턴스 '%s' 를 찾을 수 없습니다\n" instName)
        nil
    )
  )
)

;;------------------------------------------------------------
;; Helper: 특정 핀의 중심 좌표 반환
;;------------------------------------------------------------
procedure( getPinCenter(inst pinName)
  let( (term pin bbox cx cy)
    term = nil
    foreach( trm inst~>master~>terminals
      when( trm~>name == pinName
        term = trm
      )
    )
    if( term == nil then
      printf("ERROR: 핀 '%s' 없음 (인스턴스: %s)\n" pinName inst~>name)
      return(nil)
    )
    pin  = car(term~>pins)
    bbox = pin~>fig~>bBox
    cx = (xCoord(car(bbox)) + xCoord(cadr(bbox))) / 2.0
    cy = (yCoord(car(bbox)) + yCoord(cadr(bbox))) / 2.0
    ; 인스턴스 위치(origin) 반영
    cx = cx + xCoord(inst~>xy)
    cy = cy + yCoord(inst~>xy)
    list(cx cy)
  )
)

;;------------------------------------------------------------
;; Main: 인버터 핀 좌표 읽기
;;------------------------------------------------------------
procedure( readInvPins()
  let( (lib cell cv MP MN
        MPG MPD MPS MPB
        MNG MND MNS MNB)

    lib  = "Y_Skill_Test"
    cell = "INV"

    ;;--- cellview 열기 ("a" = append, 기존 내용 유지)
    cv = dbOpenCellViewByType(lib cell "schematic" "schematic" "a")
    if( cv == nil then
      printf("ERROR: cellView 열기 실패 — %s/%s\n" lib cell)
      return(nil)
    )
    printf("OK  cellView 열림: %s/%s/schematic\n" lib cell)

    ;;--- 인스턴스 가져오기
    MP = getInst(cv "MP0")
    MN = getInst(cv "MN0")

    if( !MP || !MN then
      printf("ERROR: 인스턴스를 찾지 못했습니다\n")
      dbClose(cv)
      return(nil)
    )

    ;;--- 핀 좌표 읽기 (G=게이트 D=드레인 S=소스 B=벌크)
    MPG = getPinCenter(MP "G")   MPD = getPinCenter(MP "D")
    MPS = getPinCenter(MP "S")   MPB = getPinCenter(MP "B")

    MNG = getPinCenter(MN "G")   MND = getPinCenter(MN "D")
    MNS = getPinCenter(MN "S")   MNB = getPinCenter(MN "B")

    ;;--- 결과 출력
    printf("\n========== 핀 좌표 결과 ==========\n")
    printf("MP0 (PMOS):\n")
    printf("  G(게이트)  = %L\n" MPG)
    printf("  D(드레인)  = %L\n" MPD)
    printf("  S(소스)    = %L\n" MPS)
    printf("  B(벌크)    = %L\n" MPB)
    printf("MN0 (NMOS):\n")
    printf("  G(게이트)  = %L\n" MNG)
    printf("  D(드레인)  = %L\n" MND)
    printf("  S(소스)    = %L\n" MNS)
    printf("  B(벌크)    = %L\n" MNB)
    printf("===================================\n\n")

    dbSave(cv)
    dbClose(cv)
    printf("DONE\n")
  )
)

readInvPins()
