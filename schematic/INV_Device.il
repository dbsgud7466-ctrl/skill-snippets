;;============================================================
;; Inverter Schematic — Y_Skill_Test / tsmc18
;; 참고: 5T diff amp 코드 스타일 적용
;;
;; PMOS (pmos2v) : W=8u  L=180n
;; NMOS (nmos2v) : W=4u  L=180n
;;
;; CIW 실행:
;;   load("inverter_sch.il")
;;============================================================

;;------------------------------------------------------------
;; Helper: 인스턴스 파라미터 설정 (W/L 문자열 방식)
;;------------------------------------------------------------
procedure( setInstParam(inst paramName paramValue)
  let( (prop)
    prop = dbFindProp(inst paramName)
    if( prop != nil then
      dbReplaceProp(inst paramName "string" paramValue)
    else
      dbCreateProp(inst paramName "string" paramValue)
    )
    printf("  SET  %-4s  %-4s = %s\n"
           inst~>name paramName paramValue)
  )
)

;;------------------------------------------------------------
;; Main: 인버터 Schematic 생성
;;------------------------------------------------------------
procedure( makeInverterSch()
  let( (lib cell cv
        nmosMaster pmosMaster
        ipinMaster opinMaster
        MP MN)

    lib  = "Y_Skill_Test"
    cell = "INV"

    ;;--------------------------------------------------------
    ;; [1] Master symbol 로드
    ;;     tsmc18 셀 이름이 다를 경우:
    ;;     nmos2v → nmos3v, nch 등으로 변경
    ;;--------------------------------------------------------
    nmosMaster = dbOpenCellViewByType("tsmc18" "nmos2v" "symbol" "" "r")
    pmosMaster = dbOpenCellViewByType("tsmc18" "pmos2v" "symbol" "" "r")
    ipinMaster = dbOpenCellViewByType("basic"  "ipin"   "symbol" "" "r")
    opinMaster = dbOpenCellViewByType("basic"  "opin"   "symbol" "" "r")

    if( !nmosMaster || !pmosMaster || !ipinMaster || !opinMaster then
      printf("ERROR: Master symbol 로드 실패\n")
      printf("  → tsmc18 셀 이름 확인: nmos2v / pmos2v\n")
      printf("  → Library Manager에서 tsmc18 셀 목록 확인 필요\n")
      return(nil)
    )
    printf("OK  [1/4] Master symbols 로드 완료\n")

    ;;--------------------------------------------------------
    ;; [2] Schematic CellView 생성
    ;;--------------------------------------------------------
    cv = dbOpenCellViewByType(lib cell "schematic" "schematic" "w")
    if( cv == nil then
      printf("ERROR: cellView 생성 실패 — 라이브러리 확인: %s\n" lib)
      return(nil)
    )
    printf("OK  [2/4] cellView 생성 → %s/%s/schematic\n" lib cell)

    ;;--------------------------------------------------------
    ;; [3] 인스턴스 배치
    ;;
    ;;  배치 좌표 (x y) 기준:
    ;;
    ;;   VDD
    ;;    |
    ;;   [MP0]  ← PMOS  (0.0, 1.5), 방향 R0
    ;;    |
    ;;   OUT ───────── OUT 핀
    ;;    |
    ;;   [MN0]  ← NMOS  (0.0, 0.0), 방향 R0
    ;;    |
    ;;   VSS
    ;;--------------------------------------------------------
    MP = schCreateInst(cv pmosMaster "MP0" list(0.0  1.5) "R0")
    MN = schCreateInst(cv nmosMaster "MN0" list(0.0  0.0) "R0")

    if( !MP || !MN then
      printf("ERROR: 인스턴스 배치 실패\n")
      return(nil)
    )
    printf("OK  [3/4] PMOS(MP0) / NMOS(MN0) 배치 완료\n")

    ;;--------------------------------------------------------
    ;; [4] W/L 파라미터 설정
    ;;     PMOS : W=8u  L=180n
    ;;     NMOS : W=4u  L=180n
    ;;--------------------------------------------------------
    setInstParam(MP "w" "8u")    setInstParam(MP "l" "180n")
    setInstParam(MN "w" "4u")    setInstParam(MN "l" "180n")
    printf("OK  [4/4] W/L 파라미터 설정 완료\n")

    ;;--------------------------------------------------------
    ;; [5] 핀 생성
    ;;     schCreatePin(cv master 이름 방향 offSheet 좌표 방향 powerSens groundSens sigType)
    ;;
    ;;  핀 배치 좌표:
    ;;    VDD  : 위쪽   (-2.0,  1.0)
    ;;    VSS  : 아래쪽 (-2.0, 0.75)
    ;;    IN   : 왼쪽   (-2.0,  0.5)
    ;;    OUT  : 오른쪽 (-2.125,  0.25)
    ;;--------------------------------------------------------
    schCreatePin(cv ipinMaster "VDD" "input"  nil list(-2.0  1.0)  "R0" nil nil "power")
    schCreatePin(cv ipinMaster "VSS" "input"  nil list(-2.0  0.75)  "R0" nil nil "ground")
    schCreatePin(cv ipinMaster "IN"  "input"  nil list(-2.0  0.5) "R0" nil nil "signal")
    schCreatePin(cv opinMaster "OUT" "output" nil list(-2.125  0.25) "R0" nil nil "signal")
    printf("OK  [5/5] 핀 생성 완료 (VDD / VSS / IN / OUT)\n")

    ;;--------------------------------------------------------
    ;; [6] 저장 및 닫기
    ;;--------------------------------------------------------
    dbSave(cv)
    dbClose(cv)
    printf("==========================================\n")
    printf("DONE: %s/%s/schematic 저장 완료\n" lib cell)
    printf("==========================================\n")
  )
)

makeInverterSch()
