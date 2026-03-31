;;============================================================
;; Helper procedure: Set instance parameter directly via property
;;============================================================
procedure( setInstParam(inst paramName paramValue)
  let( (prop)
    prop = dbFindProp(inst paramName)
    if( prop != nil then
      dbReplaceProp(inst paramName "string" paramValue)
    else
      dbCreateProp(inst paramName "string" paramValue)
    )
    printf("  SET %-4s  %-4s = %s\n"
           inst~>name paramName paramValue)
  )
)

;;============================================================
;; Main procedure: Generate 5T diff amp schematic
;;============================================================
procedure( make5TRamp()
  let( (lib cell cv nmosMaster pmosMaster ipinMaster opinMaster M1 M2 M3 M4 M5)
    lib  = "Y_Skill_Test"
    cell = "diffAmp5T"

    ;;----------------------------------------------------------
    ;; [1] Open master symbols (Including Pins)
    ;;----------------------------------------------------------
    nmosMaster = dbOpenCellViewByType("tsmc18" "nmos2v" "symbol" "" "r")
    pmosMaster = dbOpenCellViewByType("tsmc18" "pmos2v" "symbol" "" "r")
    ipinMaster = dbOpenCellViewByType("basic"  "ipin"   "symbol" "" "r")
    opinMaster = dbOpenCellViewByType("basic"  "opin"   "symbol" "" "r")

    if( !nmosMaster || !pmosMaster || !ipinMaster || !opinMaster then
      printf("ERROR: Master symbol load failed. Check tsmc18 or basic lib.\n")
      return(nil)
    )

    ;;----------------------------------------------------------
    ;; [2] Create new schematic cellView
    ;;----------------------------------------------------------
    cv = dbOpenCellViewByType(lib cell "schematic" "schematic" "w")
    if( cv == nil then
      printf("ERROR: cellView failed. Check lib: %s\n" lib)
      return(nil)
    )
    printf("OK  [1/4] cellView created -> %s/%s/schematic\n" lib cell)

    ;;----------------------------------------------------------
    ;; [3] Place instances
    ;;----------------------------------------------------------
    M1 = schCreateInst(cv nmosMaster "M1" list(0.0  0.0) "R0")
    M2 = schCreateInst(cv nmosMaster "M2" list(4.0  0.0) "R0")
    M3 = schCreateInst(cv pmosMaster "M3" list(0.0  4.0) "MY")
    M4 = schCreateInst(cv pmosMaster "M4" list(4.0  4.0) "MY")
    M5 = schCreateInst(cv nmosMaster "M5" list(2.0 -3.0) "R0")
    printf("OK  [2/4] All 5 instances placed\n")

    ;;----------------------------------------------------------
    ;; [4] Set W/L parameters
    ;;----------------------------------------------------------
    setInstParam(M1 "w" "4u")   setInstParam(M1 "l" "180n")
    setInstParam(M2 "w" "4u")   setInstParam(M2 "l" "180n")
    setInstParam(M3 "w" "8u")   setInstParam(M3 "l" "180n")
    setInstParam(M4 "w" "8u")   setInstParam(M4 "l" "180n")
    setInstParam(M5 "w" "4u")   setInstParam(M5 "l" "360n")
    printf("OK  [3/4] W/L parameters set\n")

    ;;----------------------------------------------------------   
    ;;----------------------------------------------------------
    ;; [5] Create Pins
    ;;     schCreatePin(cv master name direction offSheet origin orientation powerSens groundSens sigType)
    ;;----------------------------------------------------------
    schCreatePin(cv ipinMaster "INP"   "input"  nil list(-3.0  0.5) "R0" nil nil "signal")
    schCreatePin(cv ipinMaster "INN"   "input"  nil list(-3.0 -0.5) "R0" nil nil "signal")
    schCreatePin(cv ipinMaster "VBIAS" "input"  nil list(-3.0 -3.0) "R0" nil nil "signal")
    schCreatePin(cv opinMaster "OUT"   "output" nil list( 7.0  2.0) "R0" nil nil "signal")
    schCreatePin(cv ipinMaster "VDD"   "input"  nil list( 2.0  7.0) "R0" nil nil "power")
    schCreatePin(cv ipinMaster "VSS"   "input"  nil list( 2.0 -5.0) "R0" nil nil "ground")
    printf("OK  [4/4] Pins created\n")

    ;;----------------------------------------------------------
    ;; [6] Save and Close
    ;;----------------------------------------------------------
    dbSave(cv)
    dbClose(cv)
    printf("==========================================\n")
    printf("DONE: %s/%s/schematic saved.\n" lib cell)
    printf("==========================================\n")
  )
)

make5TRamp()