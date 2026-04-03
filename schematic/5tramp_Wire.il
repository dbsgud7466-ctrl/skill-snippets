procedure( getPinCenter(inst pinName)
  let( (bBox cx cy result)
    foreach( term inst~>master~>terminals
      when( term~>name == pinName
        bBox = car(term~>pins)~>fig~>bBox
        cx = (caar(bBox) + caadr(bBox)) / 2.0
        cy = (cadar(bBox) + cadadr(bBox)) / 2.0
        result = dbTransformPoint(cx:cy inst~>transform)
      )
    )
    result
  )
)

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

procedure( add5TWiresAndLabels()
  let( (lib cell cv M1 M2 M3 M4 M5
        M1G M1D M1S M1B
        M2G M2D M2S M2B
        M3G M3D M3S M3B
        M4G M4D M4S M4B
        M5G M5D M5S M5B
        w net9X net9Y vddY midX
        M3D_x M3D_y bypassY bypassX
        M4D_x M4D_y M2D_y midOutY)

    lib  = "Y_Skill_Test"
    cell = "diffAmp5T"

    cv = dbOpenCellViewByType(lib cell "schematic" "schematic" "a")
    if( cv == nil then
      printf("ERROR\n")
      return(nil)
    )

    M1 = getInst(cv "M1")
    M2 = getInst(cv "M2")
    M3 = getInst(cv "M3")
    M4 = getInst(cv "M4")
    M5 = getInst(cv "M5")

    M1G = getPinCenter(M1 "G")  M1D = getPinCenter(M1 "D")
    M1S = getPinCenter(M1 "S")  M1B = getPinCenter(M1 "B")
    M2G = getPinCenter(M2 "G")  M2D = getPinCenter(M2 "D")
    M2S = getPinCenter(M2 "S")  M2B = getPinCenter(M2 "B")
    M3G = getPinCenter(M3 "G")  M3D = getPinCenter(M3 "D")
    M3S = getPinCenter(M3 "S")  M3B = getPinCenter(M3 "B")
    M4G = getPinCenter(M4 "G")  M4D = getPinCenter(M4 "D")
    M4S = getPinCenter(M4 "S")  M4B = getPinCenter(M4 "B")
    M5G = getPinCenter(M5 "G")  M5D = getPinCenter(M5 "D")
    M5S = getPinCenter(M5 "S")  M5B = getPinCenter(M5 "B")

    net9X   = car(M3D)
    net9Y   = cadr(M3D)
    vddY    = cadr(M3S) + 0.5
    midX    = (car(M3S) + car(M4S)) / 2.0
    M3D_x   = car(M3D)
    M3D_y   = cadr(M3D)
    bypassY = M3D_y - 0.5
    bypassX = M3D_x + 0.5
    M4D_x   = car(M4D)
    M4D_y   = cadr(M4D)
    M2D_y   = cadr(M2D)
    midOutY = (M4D_y + M2D_y) / 2.0

    ; [A] VDD - M3S M4S 수직 후 수평 + 라벨
    schCreateWire(cv "draw" "full"
      list(car(M3S):cadr(M3S)  car(M3S):vddY)
      0.0625 0.0625 0)
    schCreateWire(cv "draw" "full"
      list(car(M4S):cadr(M4S)  car(M4S):vddY)
      0.0625 0.0625 0)
    w = schCreateWire(cv "draw" "full"
          list(car(M3S):vddY  car(M4S):vddY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) midX:vddY+0.1
                       "VDD" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [B] VDD Label - M3B (왼쪽으로)
    w = schCreateWire(cv "draw" "full"
          list(car(M3B):cadr(M3B)  car(M3B)-0.5:cadr(M3B))
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M3B)-0.5:cadr(M3B)
                       "VDD" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [C] VDD Label - M4B (오른쪽으로)
    w = schCreateWire(cv "draw" "full"
          list(car(M4B):cadr(M4B)  car(M4B)+0.5:cadr(M4B))
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M4B)+0.5:cadr(M4B)
                       "VDD" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [D] VSS Label - M5S (아래로)
    w = schCreateWire(cv "draw" "full"
          list(car(M5S):cadr(M5S)  car(M5S):cadr(M5S)-0.5)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M5S):cadr(M5S)-0.5
                       "VSS" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [E] VSS Label - M1B (오른쪽으로)
    w = schCreateWire(cv "draw" "full"
          list(car(M1B):cadr(M1B)  car(M1B)+0.5:cadr(M1B))
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M1B)+0.5:cadr(M1B)
                       "VSS" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [F] VSS Label - M2B (왼쪽으로)
    w = schCreateWire(cv "draw" "full"
          list(car(M2B):cadr(M2B)  car(M2B)-0.5:cadr(M2B))
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M2B)-0.5:cadr(M2B)
                       "VSS" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [G] VSS Label - M5B (오른쪽으로)
    w = schCreateWire(cv "draw" "full"
          list(car(M5B):cadr(M5B)  car(M5B)+0.5:cadr(M5B))
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M5B)+0.5:cadr(M5B)
                       "VSS" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [H] INP Label - M1G (왼쪽으로)
    w = schCreateWire(cv "draw" "full"
          list(car(M1G):cadr(M1G)  car(M1G)-0.5:cadr(M1G))
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M1G)-0.5:cadr(M1G)
                       "INP" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [I] INN Label - M2G (오른쪽으로)
    w = schCreateWire(cv "draw" "full"
          list(car(M2G):cadr(M2G)  car(M2G)+0.5:cadr(M2G))
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M2G)+0.5:cadr(M2G)
                       "INN" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [J] VBIAS Label - M5G (왼쪽으로)
    w = schCreateWire(cv "draw" "full"
          list(car(M5G):cadr(M5G)  car(M5G)-0.5:cadr(M5G))
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) car(M5G)-0.5:cadr(M5G)
                       "VBIAS" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [K] OUT: M4D -> M2D 수직 + 중간에서 오른쪽 0.5 + OUT 라벨
    schCreateWire(cv "draw" "full"
      list(M4D_x:M4D_y  M4D_x:M2D_y)
      0.0625 0.0625 0)
    w = schCreateWire(cv "draw" "full"
          list(M4D_x:midOutY  M4D_x+0.5:midOutY)
          0.0625 0.0625 0)
    schCreateWireLabel(cv car(w) M4D_x+0.5:midOutY
                       "OUT" "lowerLeft" "R0" "fixed" 0.0625 nil)

    ; [L] Wire net9: M3D -> M1D (수직)
    schCreateWire(cv "draw" "full"
      list(car(M3D):cadr(M3D)  car(M1D):cadr(M1D))
      0.0625 0.0625 0)

    ; [M] Wire diode: M3G -> net9 (오른쪽으로 Body 우회)
    schCreateWire(cv "draw" "full"
      list(bypassX:cadr(M3G)  bypassX:bypassY)
      0.0625 0.0625 0)
    schCreateWire(cv "draw" "full"
      list(bypassX:bypassY  M3D_x:bypassY)
      0.0625 0.0625 0)
   
    ; [N] Wire M4G -> M3G
    schCreateWire(cv "draw" "full"
      list(car(M4G):cadr(M4G)  car(M3G):cadr(M3G))
      0.0625 0.0625 0)

    ; [O] Wire net8: M1S -> M2S (수평)
    schCreateWire(cv "draw" "full"
      list(car(M1S):cadr(M1S)  car(M2S):cadr(M2S))
      0.0625 0.0625 0)

    ; [P] Wire M5D -> net8 (수직)
    schCreateWire(cv "draw" "full"
      list(car(M5D):cadr(M5D)  car(M5D):cadr(M1S))
      0.0625 0.0625 0)

    dbSave(cv)
    dbClose(cv)
    printf("==========================================\n")
    printf("DONE: Wire and Label complete\n")
    printf("==========================================\n")
  )
)

add5TWiresAndLabels()