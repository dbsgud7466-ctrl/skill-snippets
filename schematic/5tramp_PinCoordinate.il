procedure( add5TWiresAndLabels()
  let( (lib cell cv M1 M2 M3 M4 M5
        M1G M1D M1S M1B
        M2G M2D M2S M2B
        M3G M3D M3S M3B
        M4G M4D M4S M4B
        M5G M5D M5S M5B
        w midX midY)

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

    printf("M1: G=%L D=%L S=%L B=%L\n" M1G M1D M1S M1B)
    printf("M2: G=%L D=%L S=%L B=%L\n" M2G M2D M2S M2B)
    printf("M3: G=%L D=%L S=%L B=%L\n" M3G M3D M3S M3B)
    printf("M4: G=%L D=%L S=%L B=%L\n" M4G M4D M4S M4B)
    printf("M5: G=%L D=%L S=%L B=%L\n" M5G M5D M5S M5B)

    dbSave(cv)
    dbClose(cv)
    printf("DONE\n")
  )
)

add5TWiresAndLabels()