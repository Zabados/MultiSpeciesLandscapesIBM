extensions [ gis table profiler csv]
globals [OutAge processedCaught tempPatches SubTurtles Rangehabs NumberHabs starttime maximumAge output Leavers IntrohabAss IntroSpecialistTable IntroPopGrowExpTable IntoHabMortExpTable IntroAgeTable IntroMaxReproRateTable IntroSpeedTable IntroExtraMortTable IntroStartNumTable IntroWalktable hexcounter DarkList DarkSpeciesID   anewcounter   thousandcounter  subsetturtles  thousand caught blackspot newHabMortMulti newHabMulti HabMortExpTable newFOVList switch InterimFiles strHexNumber TurtleOut PatchesOut CharaList myoutHex CrashTestBlank templist TestBlank NOSt CountHist PopHist landcover_patch landcover_dataset ChosenWalk Walktable ChosenDenInterR ChosenDenIntraR aMaxAge amaxReproRate ChosenStartNum ChosenExtraMort ChosenInterDen ChosenIntraDen ChosenSpdCoe StartNumTable ExtraMortTable IntraDenTable InterDenTable SpeedCoefTable ChosenSpeed ChosenmaxReproRate chosenmax_age ChosenPopGrowExp ChosenHabMortExp ChosenBiasSlope MaxReproRateTable AgeTable newPopGrowExp PopGrowExpTable Gounumber recordage availablePatches speciescounter starting_species_no megalist MeasuredAllPatches mytemplist OutList counterlist oldColor EdgePatch Gate newHabPref SpecialistTable possible_patches reported_patches my-list2 targethab testMoveVal exit SpeedTable habAss counter HabLocList x y APatch OutXcor OutYcor patchcounter prob_possible_patches smallnp phi availableLCV blanklist proportional2 blanklist2 GlobalHabPref my-list mysublist tempblank_my-list phicounter outphilist IDCounter speciesIDList IDList FOV]
patches-own [pitfall landcoverClass patchID Pphi edge LcvPatch LcvPatchSize]

breed [AllAnimals Animal]
turtles-own [HabMortMulti MyHabMortExp FOVList HabMulti MyWalk MySpeedCoe SpeciesID HabPref MovePref speed reproR DensityIntra DenIntraR DensityInter DenInterR age MyMoveExp MyPopGrowExp myExtraMort]


to profile

  setup
  profiler:reset
  profiler:start
  repeat 1000 [ go ]
  profiler:stop
  let _fname "/temp/report.csv"
  carefully [file-delete _fname] []
  file-open _fname
  file-print profiler:report
  file-close
end

to profile_setup
  profiler:reset
  profiler:start
  setup

  let _fname "/temp/report.csv"
  carefully [file-delete _fname] []
  file-open _fname
  file-print profiler:report
  file-close
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This section loads in a raster landcover and a lookup table;;;
;;; and adds the information to patches.                       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup_landcover [Inlandcover_dataset Inlandcover_patch]

  ;set landcover_dataset gis:load-dataset Inlandcover_dataset
  set landcover_dataset gis:load-dataset Inlandcover_dataset
  ;set landcover_patch gis:load-dataset Inlandcover_patch
  set landcover_patch gis:load-dataset Inlandcover_patch


  gis:set-world-envelope (gis:envelope-of landcover_dataset)

  ; This is the preferred way of copying values from a raster dataset
  ; into a patch variable: in one step, using gis:apply-raster.
  gis:apply-raster landcover_dataset landcoverClass
  gis:apply-raster landcover_patch LcvPatch


  let min-landcover gis:minimum-of landcover_dataset
  let max-landcover gis:maximum-of landcover_dataset


  if RandomEdge = True[

    ask patches [if pxcor < -500 or pxcor > 500 or pycor < -500 or pycor > 500[set landcoverclass (random NumberHabs + 1) set lcvpatch 0 ]]
  ]

  ;add colours for landcover values
  ;let interval_landcover max-landcover - min-landcover
  let interval_landcover NumberHabs - 1
  let scaling 130 / interval_landcover

  ;set patchcounter 1
  ask patches [
    ;set patchID patchcounter
    if landcoverClass > 0[
      set pcolor (scaling * landcoverClass)
    ]
    ;set patchcounter (patchcounter + 1)
  ]

  set availableLCV []
  set availablePatches []
  ask patches[
    ifelse landcoverclass >= 0 or landcoverclass <= 0 [
      if not member? landcoverclass availableLCV[
        set availableLCV lput landcoverclass availableLCV
      ]

      if not member? LcvPatch availablePatches[
        set availablePatches lput LcvPatch availablePatches
      ]

    ]
    [
      set landcoverclass 17
    ]
  ]

  set availableLCV sort-by < availableLCV

  set availablePatches sort-by < availablePatches


  let sizePatches map [ ?1 -> count patches with [ LcvPatch = ?1 ]] availablePatches

  ask patches[
    if pxcor = max-pxcor or pxcor = (- max-pxcor) or pycor = max-pycor or pycor = (- max-pycor)[
      set edge 1
    ]
    set pitfall False
    if LcvPatch > 0[; or LcvPatch <= 0[

      set LcvPatchSize item (LcvPatch - 1) sizePatches
      ;set LcvPatchSize count patches with [ LcvPatch = [LcvPatch] of myself ]
    ]
  ]

  set EdgePatch patches with [edge = 1]





end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                      end of                                ;;;
;;;                      section                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report endtime
  report date-and-time
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                      Main                                  ;;;
;;;                      section                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to Setup

  clear-all
  ;reset-ticks

  set starttime date-and-time

  ifelse RandomEdge = TRUE[
    resize-world -510 510 -510 510
  ][

    resize-world -500 500 -500 500
  ]


  set thousand False

  set recordage 0

  ;set Leavers []

  set CharaList ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"]
  set strHexNumber HexNumber 20
  ;set landcover_dataset gis:load-dataset "/lcm100ha.asc"
  ;set landcover_dataset gis:load-dataset "/lcm_allhab2.asc"
  ;set landcover_patch gis:load-dataset "/lcm100ha_group.asc"
  ;set landcover_patch gis:load-dataset "/lcm_allhab2_group.asc"

  set habAss csv:from-file str_SpeciesPref_path


  set NumberHabs length(item 0 habAss)




  set Rangehabs (range 1 (NumberHabs + 1))


  ;setup_landcover "/lcm100ha.asc" "/lcm100ha_group.asc"
  ;setup_landcover "/home/users/zabados/SimpleIBM/netlogo/lcvsquares1_273.asc" "/home/users/zabados/SimpleIBM/netlogo/patchsquares1_273.asc"
  setup_landcover str_lcvpath str_patchespath


  ifelse HabInterest = 0 [
    set MeasuredAllPatches measureAllPatchSize patches
  ][
    set MeasuredAllPatches measureAllPatchSize patches with [landcoverclass = HabInterest]
  ]





  ;set habAss csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters.csv"



  if DiffBias = TRUE[
    ;set SpecialistTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/specialist_critters.csv"
    set SpecialistTable csv:from-file str_BiasSlope_path
  ]

  if DiffHabGrowth = TRUE[
    ;set PopGrowExpTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/specialist_critters.csv"
    set PopGrowExpTable csv:from-file str_HabGrowthSlope_path
  ]

  if DiffHabMort = TRUE[
    ;set PopGrowExpTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/specialist_critters.csv"
    set HabMortExpTable csv:from-file str_HabMortSlope_path
  ]

  if DiffAge = TRUE[
    ;set AgeTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters_age.csv"
    set AgeTable csv:from-file str_MaxAge_path
  ]

  if DiffMaxRepro = TRUE[
    ;set MaxReproRateTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters_maxRepro.csv"
    set MaxReproRateTable csv:from-file str_MaxReproRate_path
  ]



  if DiffSpeeds = TRUE[
    ;set SpeedTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/speed_critters.csv"
    set SpeedTable csv:from-file str_MaxSpeed_path
  ]


 if DiffInterDen = TRUE[
   ;set InterDenTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/interden.csv"
   set InterDenTable str_InterDen_path

 ]

 if DiffIntraDen = TRUE[
   ;set IntraDenTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/intraden.csv"
   set IntraDenTable csv:from-file str_IntraDen_path
 ]

  if DiffExtraMort = TRUE[
    ;set ExtraMortTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/extramort.csv"
    set ExtraMortTable csv:from-file str_ExtraMort_path
  ]

  if DiffStartNum = TRUE[
   ;set StartNumTable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/startNum.csv"
   set StartNumTable csv:from-file str_StartNum_path
  ]


  if DiffWalk = TRUE[
    ;set Walktable csv:from-file "C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/WalkStyle.csv"
    set Walktable csv:from-file str_Walk_path
  ]



  if UsePitfalls [
    set switch 0
    setup_pitfalls
    set caught []
  ]

  if Different_introductions = TRUE [
    set IntrohabAss csv:from-file Intro_str_SpeciesPref_path
    if DiffBias = TRUE[
      set IntroSpecialistTable csv:from-file Intro_str_BiasSlope_path
    ]
    if DiffHabGrowth = TRUE[
      set IntroPopGrowExpTable csv:from-file Intro_str_HabGrowthSlope_path
    ]
    if DiffHabMort = TRUE[
      set IntoHabMortExpTable csv:from-file Intro_str_HabMortSlope_path
    ]
    if DiffAge = TRUE[
      set IntroAgeTable csv:from-file Intro_str_MaxAge_path
    ]
    if DiffMaxRepro = TRUE[
      set IntroMaxReproRateTable csv:from-file Intro_str_MaxReproRate_path
    ]
    if DiffSpeeds = TRUE[
      set IntroSpeedTable csv:from-file Intro_str_MaxSpeed_path
    ]
    if DiffExtraMort = TRUE[
      set IntroExtraMortTable csv:from-file Intro_str_ExtraMort_path
    ]

    if DiffWalk = TRUE[
      set IntroWalktable csv:from-file Intro_str_Walk_path
    ]
  ]

  set speciesIDList []
  set IDCounter 1

  ;;;This section loops through each row of the habitat association table (with each row representing a species).

  foreach habAss[ ?1 ->

    let specieshabPref ?1

    chooseValues IDCounter



    ;              InSpeciesID InHabPref            InMoveExp     InPopGrowExp                     Inspeed         InreproR       InmaxAge   InDensityIntra     InDenIntraR  InDensityInter    InDenInterR     InExtraMort         number                   Colour                    InX      InY     Chosenwalk
    create_species IDCounter specieshabPref ChosenBiasSlope ChosenPopGrowExp ChosenHabMortExp ChosenSpeed  ChosenmaxReproRate chosenmax_age ChosenIntraDen ChosenDenIntraR ChosenInterDen ChosenDenInterR ChosenExtraMort ChosenStartNum ( ((random 14) * 10) + 5 + random 9 - 4) "random" "random" ChosenWalk



    ;####Do I understand how lput works

    set speciesIDList lput IDCounter speciesIDList

    set IDCounter (IDCounter + 1)
  ]



  set starting_species_no species-count

  set CountHist list starting_species_no starting_species_no

  ;After this point the species are set up. If introducing different species I need to check if these aditional species are really new. If so assign them a new ID.

  if Different_introductions = TRUE [
    set anewcounter 0
    set DarkList []
    set DarkSpeciesID []

    foreach IntrohabAss[ ?1 ->
      ;print anewcounter
      set subsetturtles turtles with [HabPref = ?1]

      if count subsetturtles > 0 and DiffBias = TRUE[
        let introGenSpecExp item anewcounter IntroSpecialistTable
        set subsetturtles subsetturtles with [MyMoveExp = introGenSpecExp]
      ]
      if count subsetturtles > 0 and DiffHabGrowth = TRUE[
        let introPopGrowExp item anewcounter IntroPopGrowExpTable
        set subsetturtles subsetturtles with [MyPopGrowExp = introPopGrowExp]
      ]
      if count subsetturtles > 0 and DiffHabMort = TRUE[
        let introHabMort item anewcounter IntoHabMortExpTable
        set subsetturtles subsetturtles with [MyHabMortExp = introHabMort]
      ]
      if count subsetturtles > 0 and DiffAge = TRUE[
        let introAge item anewcounter IntroAgeTable
        set subsetturtles subsetturtles with [maximumAge = introAge]

      ]
      if count subsetturtles > 0 and DiffMaxRepro = TRUE[
        let intromaxrepro item anewcounter IntroMaxReproRateTable
        set subsetturtles subsetturtles with [reproR = intromaxrepro]
      ]
      if count subsetturtles > 0 and DiffSpeeds = TRUE[
        let introspeed item anewcounter IntroSpeedTable
        set subsetturtles subsetturtles with [speed = introspeed]
      ]
      if count subsetturtles > 0 and DiffExtraMort = TRUE[
        let introextramort item anewcounter IntroExtraMortTable
        set subsetturtles subsetturtles with [myExtraMort = introextramort]
      ]

      if count subsetturtles > 0 and DiffWalk = TRUE[
        let introwalk item anewcounter IntroWalktable
        set subsetturtles subsetturtles with [MyWalk = introwalk]
      ]

      ;print DarkList
      set DarkList lput anewcounter DarkList




      ifelse count subsetturtles = 0 [
        set IDCounter (IDCounter + 1)
        set DarkSpeciesID lput IDCounter DarkSpeciesID

      ]
      [
        let IntroChosenSpecies one-of subsetturtles
        let IntroChosenID [SpeciesID] of IntroChosenSpecies
        set DarkSpeciesID lput IntroChosenID DarkSpeciesID

      ]
      set anewcounter (anewcounter + 1)
    ]

  ]



  RESET-TICKS

end

to setup_pitfalls


  foreach availablePatches[ ?1 ->



    let testpatch patches with [lcvpatch = ?1]

    if HabInterest = 0 or mean [landcoverclass] of testpatch = HabInterest[


      let minX min [pxcor] of testpatch
      let maxX max [pxcor] of testpatch

      let minY min [pycor] of testpatch
      let maxY max [pycor] of testpatch

      let xdif maxX - minX
      let ydif maxY - minY

      ;print xdif
      ;print ydif

      let averageDif (xdif + ydif) / 2
      ;print averageDif

      let avx mean [pxcor] of testpatch
      let avy mean [pycor] of testpatch

      let avmodx mean modes [pxcor] of testpatch
      let avmody mean modes [pycor] of testpatch

      ifelse [lcvpatch] of patch avx avy = ?1 [
        ask patch avx avy [
          set pitfall True
        ]
      ]
      [
        ifelse [lcvpatch] of patch avmodx avmody = ?1 [
          ask patch avmodx avmody[
            set pitfall True

          ]
        ]
        [
          set blanklist []
          set blackspot 0
          ask testpatch [
            let mycount count testpatch in-radius 20
            set blanklist lput mycount blanklist
            if mycount = max blanklist [
              set blackspot self
            ]

            ;print mycount

          ]
          ask blackspot[

            ifelse abs([pxcor] of blackspot) = max-pxcor or abs([pycor] of blackspot) = max-pycor[
              ;pass
            ][
              set pitfall True
            ]
          ]
        ]
      ]

    ]
  ]

  ask patches [
    if abs(pxcor) = max-pxcor or abs(pycor) = max-pycor[
            set pitfall False
          ]
  ]





  print "finished"

end

to chooseValues [InSpeciesID]


  ;;;;;;;;
  ;If different then pick values out of a table, otherwise use the common value.
  ;;;;;;;;;;


  ;carefully[
   ;set x mean [myx] of turtles with [speciesID = InSpeciesID]
  ;]
  ;[
  ; The if else statement
  ;]

  carefully[
    set ChosenBiasSlope mean [MyMoveExp] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffBias = TRUE[
      set ChosenBiasSlope item 0 item (InSpeciesID - 1) SpecialistTable
    ]
    [
      set ChosenBiasSlope BiasSlope
    ]
  ]


  carefully[
    set ChosenPopGrowExp mean [MyPopGrowExp] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffHabGrowth = TRUE[
      set ChosenPopGrowExp item 0 item (InSpeciesID - 1) PopGrowExpTable
    ]
    [
      set ChosenPopGrowExp HabGrowthSlope
    ]
  ]

  carefully[
    set ChosenHabMortExp mean [MyHabMortExp] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffHabMort = TRUE[
      set ChosenHabMortExp item 0 item (InSpeciesID - 1) HabMortExpTable
    ]
    [
      set ChosenHabMortExp HabMortSlope
    ]
  ]


  carefully[
    set ChosenSpeed mean [speed] of turtles with [speciesID = InSpeciesID]

  ]
  [
    ifelse DiffSpeeds = True[
      set ChosenSpeed item 0 item (InSpeciesID - 1) SpeedTable
    ]
    [
      set ChosenSpeed MaxSpeed
    ]
  ]





  carefully[
    set chosenmax_age mean [maximumAge] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffAge = TRUE[
      set chosenmax_age item 0 item (InSpeciesID - 1) AgeTable
    ]
    [
      set chosenmax_age MaxAge
    ]
  ]


  carefully[
    set ChosenmaxReproRate mean [reproR] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffMaxRepro = TRUE[
      set ChosenmaxReproRate item 0 item (InSpeciesID - 1) MaxReproRateTable
    ]
    [
      set ChosenmaxReproRate MaxReproRate
    ]
  ]



  carefully[
    set ChosenIntraDen mean [DensityIntra] of turtles with [speciesID = InSpeciesID]
    set ChosenDenIntraR mean [DenIntraR] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffIntraDen = TRUE[
      set ChosenIntraDen item 0 item (InSpeciesID - 1) IntraDenTable
      set ChosenDenIntraR item 1 item (InSpeciesID - 1) IntraDenTable

    ]
    [
      set ChosenIntraDen intradensity
      set ChosenDenIntraR intraRadius

    ]
  ]

  carefully[
    set ChosenInterDen mean [DensityInter] of turtles with [speciesID = InSpeciesID]
    set ChosenDenInterR mean [DenInterR] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffInterDen = TRUE[
      set ChosenInterDen item 0 item (InSpeciesID - 1) InterDenTable
      set ChosenDenInterR item 1 item (InSpeciesID - 1) InterDenTable

    ]
    [
      set ChosenInterDen interdensity
      set ChosenDenInterR interRadius


    ]
  ]

  carefully[
    set ChosenExtraMort mean [myExtraMort] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffExtraMort = TRUE[
      set ChosenExtraMort item 0 item (InSpeciesID - 1) ExtraMortTable
    ]
    [
      set ChosenExtraMort ExtraMort
    ]
  ]


  ifelse DiffStartNum = TRUE[
    set ChosenStartNum item 0 item (InSpeciesID - 1) StartNumTable
  ]
  [
    set ChosenStartNum StartingEachSpecies
  ]


  carefully[
   set ChosenWalk one-of [MyWalk] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffWalk = TRUE[
      set ChosenWalk item (InSpeciesID - 1)  Walktable
    ]
    [
      if WalkType = "RW"[
        set ChosenWalk list WalkType "NA"

      ]

      if WalkType = "CRW"[
        set ChosenWalk list WalkType CRW_multi

      ]

      if WalkType = "Exp"[
        set ChosenWalk list WalkType walk_exp
      ]

      if WalkType = "Logistic"[
        set ChosenWalk list WalkType walk_exp
        set ChosenWalk lput logiMidpoint ChosenWalk

      ]

    ]
  ]




end



to chooseIntroValues [InSpeciesID ListNumber]


  ;;;;;;;;
  ;If different then pick values out of a table, otherwise use the common value.
  ;;;;;;;;;;


  ;carefully[
   ;set x mean [myx] of turtles with [speciesID = InSpeciesID]
  ;]
  ;[
  ; The if else statement
  ;]

  carefully[
    set ChosenBiasSlope mean [MyMoveExp] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffBias = TRUE[
      set ChosenBiasSlope item 0 item ListNumber IntroSpecialistTable
    ]
    [
      set ChosenBiasSlope BiasSlope
    ]
  ]


  carefully[
    set ChosenPopGrowExp mean [MyPopGrowExp] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffHabGrowth = TRUE[
      set ChosenPopGrowExp item 0 item ListNumber IntroPopGrowExpTable
    ]
    [
      set ChosenPopGrowExp HabGrowthSlope
    ]
  ]

  carefully[
    set ChosenHabMortExp mean [MyHabMortExp] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffHabGrowth = TRUE[
      set ChosenHabMortExp item 0 item ListNumber IntoHabMortExpTable
    ]
    [
      set ChosenHabMortExp HabMortSlope
    ]
  ]


  carefully[
    set ChosenSpeed mean [speed] of turtles with [speciesID = InSpeciesID]

  ]
  [
    ifelse DiffSpeeds = True[
      set ChosenSpeed item 0 item ListNumber IntroSpeedTable
    ]
    [
      set ChosenSpeed MaxSpeed
    ]
  ]





  carefully[
    set chosenmax_age mean [maximumAge] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffAge = TRUE[
      set chosenmax_age item 0 item ListNumber IntroAgeTable
    ]
    [
      set chosenmax_age MaxAge
    ]
  ]


  carefully[
    set ChosenmaxReproRate mean [reproR] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffMaxRepro = TRUE[
      set ChosenmaxReproRate item 0 item ListNumber IntroMaxReproRateTable
    ]
    [
      set ChosenmaxReproRate MaxReproRate
    ]
  ]



  carefully[
    set ChosenIntraDen mean [DensityIntra] of turtles with [speciesID = InSpeciesID]
    set ChosenDenIntraR mean [DenIntraR] of turtles with [speciesID = InSpeciesID]
  ]
  [

      set ChosenIntraDen intradensity
      set ChosenDenIntraR intraRadius


  ]

  carefully[
    set ChosenInterDen mean [DensityInter] of turtles with [speciesID = InSpeciesID]
    set ChosenDenInterR mean [DenInterR] of turtles with [speciesID = InSpeciesID]
  ]
  [
      set ChosenInterDen interdensity
      set ChosenDenInterR interRadius



  ]

  carefully[
    set ChosenExtraMort mean [myExtraMort] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffExtraMort = TRUE[
      set ChosenExtraMort item 0 item ListNumber IntroExtraMortTable
    ]
    [
      set ChosenExtraMort ExtraMort
    ]
  ]




  carefully[
   set ChosenWalk one-of [MyWalk] of turtles with [speciesID = InSpeciesID]
  ]
  [
    ifelse DiffWalk = TRUE[
      set ChosenWalk item ListNumber  Walktable
    ]
    [
      if WalkType = "RW"[
        set ChosenWalk list WalkType "NA"

      ]

      if WalkType = "CRW"[
        set ChosenWalk list WalkType CRW_multi

      ]

      if WalkType = "Exp"[
        set ChosenWalk list WalkType walk_exp
      ]

      if WalkType = "Logistic"[
        set ChosenWalk list WalkType walk_exp
        set ChosenWalk lput logiMidpoint ChosenWalk

      ]

    ]
  ]




end


to-report agecalc [aSpeciesID]

  ifelse DiffAge = TRUE[
    set aMaxAge item 0 item (aSpeciesID - 1) AgeTable
  ]
  [
    set aMaxAge MaxAge
  ]


  ifelse DiffMaxRepro = TRUE[
    set amaxReproRate item 0 item (aSpeciesID - 1) MaxReproRateTable
  ]
  [
    set amaxReproRate MaxReproRate
  ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;
  ;;;;;;;;;;
  ;;;;;
  ;;
  ;
  ;If a tick is a minute then need to multiple 365 by 24*60
  ;elif hours then by 24
  ;elif days as is
  ;year /365

  if TimeStep = "day"[
    set OutAge 365 * aMaxAge
  ]

  if TimeStep = "hour"[
    set OutAge 24 * 365 * aMaxAge
  ]

  if TimeStep = "min"[
    set OutAge 60 * 24 * 365 * aMaxAge
  ]

  if TimeStep = "sec"[
    set OutAge 60 * 60 * 24 * 365 * aMaxAge
  ]



  report OutAge
end

to-report SelectItemsList[items itemsList]
  set blanklist []
  foreach items[ ?1 ->
    set blanklist lput item (?1 - 1) itemsList blanklist
  ]
  report blanklist
end

;;This isn't currentl being used
;to-report Calculate_start [ species1habPref n]
;
;
;  let probPatch map [ ?1 -> ?1 / sum(MeasuredAllPatches) ] MeasuredAllPatches
;  let newprobPatch map [ ?1 -> ?1 ^ StartingExp ]  species1habPref
;  set counter 0
;  set counterlist []
;  foreach species1habPref[
;    set counterlist lput counter counterlist
;    set counter (counter + 1)
;  ]
;
;  let probability map[ ?1 -> item ?1 probPatch * item ?1 newprobPatch ] counterlist
;  let normalProb map[ ?1 -> precision (?1 / sum(probability)) 2 ] probability
;  let Outnumber map[ ?1 -> round(?1 * n) ] normalProb
;  set OutList []
;  foreach counterlist[ ?1 ->
;    set mytemplist []
;    if item ?1 MeasuredAllPatches > 0[
;      let a (?1 + 1)
;      let b (item ?1 Outnumber)
;      set mytemplist lput a mytemplist
;      set mytemplist lput b mytemplist
;      set OutList lput mytemplist Outlist
;    ]
;  ]
;  report OutList
;end

to-report setFOV[locMyWalk habX]
  if item 0 locMyWalk = "Exp"[
    set FOV (360 * ((habX) ^ (- item 1 locMyWalk)))
    ;print FOV
  ]

  if item 0 locMyWalk = "Logistic"[
   set FOV (330 / ( 1 + exp (item 1 locMyWalk * ( (HabX) - item 2 locMyWalk)))) + 30
   ;print FOV
  ]
  report FOV
end

to create_species [InSpeciesID InHabPref InMoveExp InPopGrowExp InHabMortExp Inspeed InreproR InmaxAge InDensityIntra InDenIntraR InDensityInter InDenInterR InExtraMort number Colour InX InY InWalk]

  ;Calculation for later
  ;set newHabPref map [ ?1 -> ?1 ^ ( - InMoveExp) ] InHabPref
  set newHabPref map [ ?1 -> 1 / ( 1 + exp (InMoveExp * (?1 - BiasMid)))] InHabPref
  let tempAge agecalc InSpeciesID

  ifelse InPopGrowExp >= 0[

    set newHabMulti map [ ?1 -> 1 / ( 1 + exp (InPopGrowExp * (?1 - GrowthMid)))] InHabPref
  ][
    set newHabMulti map [1] InHabPref
  ]


  ifelse InHabMortExp >= 0[
    set newHabMortMulti map [ ?1 -> 1 - (1 / ( 1 + exp (InHabMortExp * (?1 - MortMid))))] InHabPref
  ][
    set newHabMortMulti map [0] InHabPref
  ]


  set newFOVList map [360] InHabPref
  set newFOVList map [ ?1 -> setFOV InWalk ?1]  InHabPref





  create-AllAnimals number[

    set size 10
    set SpeciesID InSpeciesID
    set HabPref InHabPref
    set MyMoveExp InMoveExp
    set MyHabMortExp InHabMortExp
    ;;This is derived only once, so that it doesn't need to be done everytime an individual of a species moves.
    set MovePref newHabPref
    set HabMulti newHabMulti

    set HabMortMulti newHabMortMulti




    set MyPopGrowExp InPopGrowExp
    set speed Inspeed

    set reproR InreproR
    set maximumAge tempAge
    set DensityIntra InDensityIntra
    set DenIntraR InDenIntraR

    set FOVList newFOVList

    set DensityInter InDensityInter
    set DenInterR InDenInterR
    set myExtraMort InExtraMort
    set age random maximumAge
    set color Colour
    set MyWalk InWalk

    ifelse InX = "random"[
      ;;;This is a really simplistic introduction of individuals. I may need to complicate this later.  Calculate_start isn't being used.
      set xcor (random ( 2 * max-pxcor ) - max-pxcor)
      ]
    [
      set xcor InX
      ]
    ifelse InY = "random"[
      set ycor (random ( 2 * max-pycor ) - max-pycor)
      ]
    [
      set ycor InY
      ]
    ]

end

to go
  if not any? turtles [ stop ]

  if ticks = 200000 [ stop ]
  ;print DevPop

  set counter 1

  while [counter <= DripFeedNumber][

    if random-float 1 <= DripFeedRate[
      introduce
    ]
    set counter (counter + 1)
  ]

  ask turtles[

    if Imortal_infert = False[

      mort
      reproduce
      density_intermort
      density_intramort
    ]






    move

    set age (age + 1)

  ]
  ;philist 2
  ;print sum(Leavers) / (ticks + 1)
  ;updateCountHist
  ;stablespecies


  if UsePitfalls [
    let turtlesinpitfalls getTurtlesPitfalls

    set caught lput turtlesinpitfalls caught

    if length caught > PitfallTime [
      set caught but-first caught
    ]
  ]



  tick
end

to calcProbHabs [Inpossible_patches]
    let countposspatches measureAllPatchSize2 Inpossible_patches
    ;print word "count poss patches: " countposspatches


    ;foreach countposspatches[ ?1 ->
    ;
    ;  set my-list lput (?1 * item counter MovePref) my-list
    ;  set counter (counter + 1)
    ;]

    set my-list (map * countposspatches MovePref)

    let summed sum(my-list)

    set my-list2 map [ ?1 -> ?1 / summed] my-list

end

to move

  let patch-under-me patch-here

  ;;;;;I found a way of adding a correlating to the random walk as well as hab choice, but they then don't spend anymore time in hab than anywhere else. I've therefore given the option of switching it
  ;;;;;off and reverting to random walk with habitat choice.
  set FOV 360
;
;  let pref-under-me item ([landcoverclass] of patch-under-me - 1) habpref
;
  if item 0 MyWalk = "CRW"[
    set FOV (item 1 MyWalk * random-gamma 1 2)
    while [FOV > 360][
      set FOV (item 1 MyWalk * random-gamma 1 2)
      ]
    ]
  ;print FOV

  if item 0 MyWalk = "Logistic"[
    set FOV item ([landcoverclass] of patch-under-me - 1) FOVList
  ]




;
;  if item 0 MyWalk = "Exp"[
;    set FOV (360 * ((pref-under-me) ^ (- item 1 MyWalk)))
;    ;print FOV
;  ]
;
;  if item 0 MyWalk = "Logistic"[
;   set FOV (360 / ( 1 + exp (item 1 MyWalk * ( (pref-under-me) - item 2 MyWalk))))
;   ;print FOV
;  ]


  ;;;;;;;;;;;;;;;;;;;;;;Not sure if this needs to be random, if randomly choosing from within;;;;;;;;;;;;;;;;;;;;;;;;;
  let random_dispersal ((random speed) + 1)
  ;print word "random dispersal: " random_dispersal


  carefully[

    carefully[
      set possible_patches patches in-cone random_dispersal FOV with[self != patch-under-me]
      calcProbHabs possible_patches
    ]
    [
      set possible_patches no-patches
      set counter 1
      while [counter <= random_dispersal][
        set possible_patches patch-set patch-ahead counter
        set counter (counter + 1)
      ]
      calcProbHabs possible_patches
    ]
;    let MyColor random-float 140
;    ask possible_patches[set pcolor MyColor  ]
    set exit 0
    set counter 0
    let MyRandom random-float 1
    ;print MyRandom
    set testMoveVal 0
    while [exit = 0][
      set testMoveVal (testMoveVal + item counter my-list2)
      ;print word "test val: " testMoveVal

      if MyRandom <= testMoveVal[
        set targethab (counter + 1)
        set exit 1
        ]
      set counter (counter + 1)
      ]
    set APatch possible_patches with [landcoverclass = targethab]
    let newPatchLocation one-of APatch
    face newPatchLocation


    if EdgeDeath = True and Imortal_infert = False and (abs([pxcor] of newPatchLocation - [pxcor] of patch-under-me) > 500 or abs([pycor] of newPatchLocation - [pycor] of patch-under-me) > 500) [
      ;set Leavers lput 1 Leavers
      die
    ]


    move-to newPatchLocation
    ]
  [
    ifelse Imortal_infert = True[
      ;set heading (heading + 180)
      ;
    ]
    [

      ;print Leavers
      ;set heading (heading + 180)

      ;die
    ]
    ]
    ;print 1
end

to density_intermort
  ifelse SimpleDensity = True[
    if count turtles in-radius DenIntraR with [age != 0] >= DensityIntra[
;      ask patches in-radius DenIntraR[
;       set pcolor red
;      ]
      die
    ]
  ]
  [
    if count turtles in-radius DenInterR with [SpeciesID != [SpeciesID] of myself ] >= DensityInter[
      ;print "eep"

;      ask patches in-radius DenInterR[
;        set pcolor blue
;      ]

      die
    ]
  ]
end

to density_intramort
  ifelse SimpleDensity = True[
    ;nothing
  ]
  [

    if count turtles in-radius DenIntraR with [SpeciesID = [SpeciesID] of myself AND age != 0] >= DensityIntra[

;      ask patches in-radius DenIntraR[
;        set pcolor  orange
;      ]
      ;print "eep"
      die
  ]
  ]
end

to mort
  if age > maximumAge [
    die
  ]

  if random-float 1 <= MyExtraMort[
    die
  ]

  let HabMortality reproR * item (landcoverclass - 1) HabMortMulti

  if random-float 1 <= HabMortality[
    die
  ]

  if CarryCap > 0 and count turtles > CarryCap [
   let propOver (count turtles - CarryCap) / CarryCap
   ;let propOver (reproR * count turtles) / CarryCap
   if random-float 1 <= propOver [
      die
    ]



  ]


end

;to-report mutationCalc[ value ]
;  let mutationVal (mutation * (10 ^ (log value 10)))
;
;  let randomMutation random-float(2 * mutationVal)
;
;  report (randomMutation - mutationVal)
;
;
;end

to reproduce

  let chance random-float 1

  let currenthab [landcoverclass] of patch-here



    ;SpeciesID HabPref MyMoveExp MovePref MyPopGrowExp speed MySpeedCoe reproR maxAge DensityIntra DensityInter myExtraMort age color

;  carefully[
;  set habMulti (((item (currenthab - 1) HabPref) ^ (- MyPopGrowExp)) * (speed ^ (- MySpeedCoe)))
;
;  let currentPref (item (currenthab - 1) HabPref)
;
;  set habMulti (1 / (1 + exp(MyPopGrowExp * (currentPref - 11))))
;  ]
;  [
;    die
;  ]

  let localHabMulti item (currenthab - 1) habMulti



  let reprorate (reproR * localHabMulti)

  if chance <= reprorate[
    ;print word "Mum heading" heading
    hatch 1[
      set age 0
      set heading random-float 360
      ;print heading




;      if Evolution = True [
;
;        carefully[
;            ;set SpeciesID (SpeciesID + mutationCalc mutation)
;            ;set HabPref  (HabPref + mutationCalc mutation)
;            set MyMoveExp (MyMoveExp + mutationCalc mutation)
;            ;;This is derived only once, so that it doesn't need to be done everytime an individual of a species moves.
;            ;set MovePref (MovePref + mutationCalc mutation)
;            set MyPopGrowExp  (MyPopGrowExp + mutationCalc mutation)
;            set speed (speed + mutationCalc mutation)
;            ;set MySpeedCoe (MySpeedCoe + mutationCalc mutation)
;            set reproR (reproR + mutationCalc mutation)
;            set maxAge (maxAge + mutationCalc mutation)
;            ;set DensityIntra (DensityIntra + mutationCalc mutation)
;            ;set DenIntraR (DenIntraR + mutationCalc mutation)
;
;
;
;            ;set DensityInter (DensityInter + mutationCalc mutation)
;            ;set DenInterR (DenInterR + mutationCalc mutation)
;            ;set myExtraMort (myExtraMort + mutationCalc mutation)
;        ]
;        [
;          die
;        ]
;
;
;      ]


      ]
  ]


end

to-report measurePatchSize[lcvClass Subpatches ]

  ;foreach [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21]
  ;[
  ;
  ;  show ?
    let Np count Subpatches with [landcoverClass = lcvClass]
    report Np
  ;]

end

to-report measureAllPatchSize [inpatches]

  set my-list []




  foreach Rangehabs [ ?1 ->

    let temp measurePatchSize ?1 inpatches

    ifelse temp > 0[

      set my-list lput temp my-list
    ]
    [
      set my-list lput 0 my-list
    ]
  ]
  report my-list
end


to-report measureAllPatchSize2 [inpatches]

  ;set my-list []


  let temp-my-list map [?1 -> measurePatchSize ?1 inpatches] Rangehabs


;
;  foreach Rangehabs [ ?1 ->
;
;    let temp measurePatchSize ?1 inpatches
;
;    ifelse temp > 0[
;
;      set my-list lput temp my-list
;    ]
;    [
;      set my-list lput 0 my-list
;    ]
;  ]
  report  temp-my-list
end


to-report species-count
  let _colors remove-duplicates ([SpeciesID] of turtles)
  let color_count length (_colors)
  report (color_count)
end

to numberofeach

  foreach remove-duplicates ([SpeciesID] of turtles)[ ?1 -> print word word ?1 ": " count turtles with[speciesid = ?1] ]

end

to introduce


  ;SpeciesID HabPref MyMoveExp MovePref MyPopGrowExp speed MySpeedCoe reproR maxAge DensityIntra DensityInter myExtraMort age color
    let chosenlocation one-of EdgePatch

    let chosenX [pxcor] of chosenlocation
    let chosenY [pycor] of chosenlocation

  ifelse Different_introductions = FALSE[



    let chosen1 one-of speciesIDList


    let specieshabPref item (chosen1 - 1) habAss

    carefully[
      set oldColor [color] of one-of turtles with [speciesID = chosen1]
    ][
      set oldColor ( ((random 14) * 10) + 5 + random 9 - 4)
    ]





    ;[InSpeciesID InHabPref MoveExp InPopGrowExp Inspeed SpeedCoe InreproR InmaxAge InDensityIntra InDensityInter InExtraMort number Colour]

    chooseValues chosen1
    ;            InSpeciesID InHabPref            InMoveExp     InPopGrowExp                   Inspeed        InreproR       InmaxAge   InDensityIntra     InDenIntraR  InDensityInter    InDenInterR  InExtraMort number Colour   InX     InY
    create_species chosen1 specieshabPref ChosenBiasSlope ChosenPopGrowExp ChosenHabMortExp ChosenSpeed ChosenmaxReproRate chosenmax_age ChosenIntraDen ChosenDenIntraR ChosenInterDen ChosenDenInterR ChosenExtraMort 1 oldColor chosenX chosenY ChosenWalk
  ]
  [
    ;I need to get a list of introducing species. They all need a speciesID, but that needs to be added in the setup... Within this I need to check that the species doesn't
    ;already exist and if it does it doesn't need a new ID but it still needs to be in the second list. In this way

    let chosen1 one-of DarkList
    let chosen1ID item chosen1 DarkSpeciesID

    set oldColor ( ((random 14) * 10) + 5 + random 9 - 4)


    let specieshabPref item chosen1 introhabAss

    chooseIntroValues chosen1ID chosen1

    create_species chosen1ID specieshabPref ChosenBiasSlope ChosenPopGrowExp ChosenHabMortExp ChosenSpeed ChosenmaxReproRate chosenmax_age ChosenIntraDen ChosenDenIntraR ChosenInterDen ChosenDenInterR ChosenExtraMort 1 oldColor chosenX chosenY ChosenWalk


  ]




end

;to-report zeta
;  ;let endnumber gis:maximum-of landcover_patch
;
;
;  set megalist []
;  set blanklist list "PatchID" "LCVclass"
;  set speciescounter 1
;  while [speciescounter <= starting_species_no][
;    set blanklist lput speciescounter blanklist
;    set speciescounter (speciescounter + 1)
;  ]
;  set megalist lput blanklist  megalist
;
;
;
;
;  foreach availablePatches[
;
;
;    let testpatch patches with [lcvpatch = ?]
;    ;print counter
;
;    let b [landcoverclass] of one-of testpatch
;
;
;    set blanklist list ? b
;
;
;    set speciescounter 1
;    while [speciescounter <= starting_species_no][
;      ;SpeciesPresenceCutOff
;
;      let c measureZeta testpatch speciescounter
;
;      ;print c
;      set blanklist lput c blanklist
;
;
;      set speciescounter (speciescounter + 1)
;
;
;    ]
;
;    set megalist lput blanklist  megalist
;
;
;  ]
;;
;;  csv:to-file "Zetamatrix.csv" megalist
;;
;;
;;  ;print measureAlphaOfPatch testpatch
;;  print "finished reporting zetamatrix"
;
;
;  report megalist
;
;
;end

;to-report measureZeta [ InPatches SpeciesIDent]
;
;  ;carefully[
;    let AllTurtleset turtles-on InPatches
;
;    let Turtleset AllTurtleset with [ SpeciesID = SpeciesIDent]
;
;
;    ifelse count Turtleset >= SpeciesPresenceCutOff [
;      report 1
;    ]
;    [
;      report 0
;    ]
;  ;]
;  ;[
;  ;  report 0
;  ;]
;
;
;end

;to rzeta
;  ;r:eval "out <- R.home(component = 'home')"
;  ;print r:get "out"
;
;;  r:put "matrix" zeta
;
;
;  r:put "InSpecies" getTurtlesPatches
;  r:put "InPatches" getAllPatches
;  r:put "InThreshold" SpeciesPresenceCutOff
;
;  r:put "InNoZetas" NumberZetas
;
;
;
;
;  ;r:interactiveShell
;
;  r:eval "oldWD <- getwd()"
;
;  ;r:eval "Rcpp::sourceCpp('C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/MatrixMulti.cpp')"
;
;  ;r:eval "setwd('C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/')"
;  ;r:eval "source('C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/Zeta.r')"
;  r:eval "library(NetLogoZeta)"
;
;  r:eval "setwd('C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/')"
;
;
;
;  ;r:eval "save(matrix,file='C:/Users/jorche/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/data.Rda')"
;  ;print("rsaved")
;
;
;  ifelse NumberZetas = 0[
;    r:eval "outdf <- ZetaOutput(InSpecies, InPatches, Threshold = InThreshold)"
;  ]
;  [
;    r:eval "outdf <- ZetaOutput(InSpecies, InPatches, Threshold = InThreshold, maxZetas = InNoZetas)"
;  ]
;
;  print("zeta saved to:")
;  print r:get "outdf"
;
;  r:eval "setwd(oldWD)"
;
;;  r:put "Np" Np
;;  r:put "n" n
;;  r:put "species1habPref" species1habPref
;;  r:eval "testout <- CalculateStartingnp(Np, species1habPref, n)"
;;  report r:get "testout"
;
;
;
;end

;to-report DevPop
;
;  ifelse PopHist = 0[
;    set PopHist []
;  ]
;  [
;    set  PopHist lput (count turtles) PopHist
;    while [length PopHist > Sample] [
;      set PopHist but-first PopHist
;      ]
;  ]
;
;  ifelse length PopHist > 2[
;    report standard-deviation PopHist
;  ]
;  [
;    report 0
;  ]
;
;
;end

to updatePopHist
  ifelse PopHist = 0[
    set PopHist []
  ]
  [
    set  PopHist lput (count turtles) PopHist
    while [length PopHist > MemLen] [
      set PopHist but-first PopHist
      ]
  ]
end

;to updateCountHist
;    ifelse CountHist = 0[
;    set CountHist []
;  ]
;  [
;    set  CountHist lput species-count CountHist
;    while [length CountHist > MemLen] [
;      set CountHist but-first CountHist
;      ]
;  ]
;end

to stablespecies

  let currentCount item (length CountHist - 1) CountHist
  let lastCount item (length CountHist - 2) CountHist


  ifelse DripFeedRate = 0[

    ifelse currentCount = lastCount AND currentCount < starting_species_no [
      set NOSt (NOSt + 1)
    ]
    [
      set NOSt 0
    ]

;    if NOSt >= 1000[
;      print currentCount
;    ]

  ]
  [


    let meanCount mean CountHist
    let SDCount standard-deviation CountHist

    ifelse currentCount <= (meanCount + 2 * SDCount) AND currentCount >= (meanCount - 2 * SDCount) [
      set NOSt (NOSt + 1)
    ]
    [
      set NOSt 0
    ]

;    if NOSt >= 1000[
;      print meanCount
;    ]


  ]

end

to-report StoppingStable


;  if NOSt = 2000 and switch = 0[
;    set InterimFiles InterimsaveOut
;    set switch 1
;  ]





  ifelse NOSt >= StableTime[
    report True
  ]
  [
    report False
  ]

end



to-report getTurtlesPatches
  set TestBlank []

  ifelse HabInterest = 0 [
    set SubTurtles turtles
  ][

    set SubTurtles turtles with [[landcoverclass] of patch-here = HabInterest]
  ]


  ask SubTurtles[
    set templist []
    set templist lput speciesid templist
    set templist lput landcoverClass templist
    set templist lput LcvPatch templist
    set TestBlank lput templist TestBlank
  ]
  report TestBlank
end

to-report getTurtlesPitfalls
  set TestBlank []

  ask turtles[

    if pitfall [

      set templist []
      set templist lput speciesid templist
      set templist lput landcoverClass templist
      set templist lput LcvPatch templist
      set TestBlank lput templist TestBlank
    ]
  ]
  report TestBlank
end


to-report getAllPatches
  set CrashTestBlank []

  ifelse HabInterest = 0[
    set tempPatches patches
  ][
    set tempPatches patches with [landcoverclass = HabInterest]
  ]

  ask tempPatches[
    if LcvPatch >= 0[
      set templist list landcoverClass LcvPatch
      set templist lput LcvPatchSize templist

      if not member? templist CrashTestBlank [

        set CrashTestBlank lput templist CrashTestBlank
        ;print templist
      ]
    ]
  ]
  report CrashTestBlank

end


to-report getTurtlesPatchesSingle


  set templist []
  set templist lput speciesid templist
  set templist lput landcoverClass templist
  set templist lput LcvPatch templist

  report templist
end


to-report getAllPatchesSingle

  set templist list landcoverClass LcvPatch
  report templist

end

to-report HexNumber [hexlength]
  set hexcounter 1
  set myoutHex ""
  while [hexcounter <= hexlength][
    set myoutHex word (one-of CharaList) myoutHex
    set hexcounter (hexcounter + 1)
  ]

  report myoutHex
end

to-report saveOut

  set TurtleOut word "turtle" strHexNumber
  set PatchesOut word "patches" strHexNumber

  while [file-exists? TurtleOut or file-exists? PatchesOut][
    set strHexNumber HexNumber 20

    set TurtleOut word "turtle" strHexNumber
    set PatchesOut word "patches" strHexNumber
  ]

;  file-open TurtleOut
;  file-write getTurtlesPatches
;  file-close


  csv:to-file TurtleOut getTurtlesPatches

;  file-open PatchesOut
;  file-write getAllPatches
;  file-close

  csv:to-file PatchesOut getAllPatches

  let FileList list TurtleOut PatchesOut
  report FileList


end


to-report saveOutPitfall

  set TurtleOut word "turtle" strHexNumber
  set PatchesOut word "patches" strHexNumber

  while [file-exists? TurtleOut or file-exists? PatchesOut][
    set strHexNumber HexNumber 20

    set TurtleOut word "turtle" strHexNumber
    set PatchesOut word "patches" strHexNumber
  ]

;  file-open TurtleOut
;  file-write getTurtlesPatches
;  file-close

  set processedCaught []
  foreach caught [?1 ->
    foreach ?1 [?2 ->

      set processedCaught lput ?2  processedCaught
    ]
  ]

  csv:to-file TurtleOut processedCaught

;  file-open PatchesOut
;  file-write getAllPatches
;  file-close

  csv:to-file PatchesOut getAllPatches

  let FileList list TurtleOut PatchesOut
  report FileList


end



to-report SinglespeciesLocation
  ask turtles[
    let myID who
    let mySpecies speciesID

    let mycurrentLocal patch-here

    let mycurrentLCV [landcoverclass] of mycurrentLocal
    let mycurrentPatch [lcvpatch] of mycurrentLocal
    let myX [pxcor] of mycurrentLocal
    let myY [pycor] of mycurrentLocal

    set output (list myID mySpecies mycurrentLCV mycurrentPatch myX myY)

  ]

  report output
end


to-report MultispeciesLocation
  set output []
  ask turtles[
    let myID who
    let mySpecies speciesID

    let mycurrentLocal patch-here

    let mycurrentLCV [landcoverclass] of mycurrentLocal
    let mycurrentPatch [lcvpatch] of mycurrentLocal
    let myX [pxcor] of mycurrentLocal
    let myY [pycor] of mycurrentLocal

    let tempoutput (list myID mySpecies mycurrentLCV mycurrentPatch myX myY)
    set output lput tempoutput output
  ]

  report output
end




;to-report InterimsaveOut
;
;  set TurtleOut word "Interim_turtle" strHexNumber
;  set PatchesOut word "Interim_patches" strHexNumber
;
;  while [file-exists? TurtleOut or file-exists? PatchesOut][
;    set strHexNumber HexNumber 20
;
;    set TurtleOut word "Interimturtle" strHexNumber
;    set PatchesOut word "Interimpatches" strHexNumber
;  ]
;
;;  file-open TurtleOut
;;  file-write getTurtlesPatches
;;  file-close
;
;
;  csv:to-file TurtleOut getTurtlesPatches
;
;;  file-open PatchesOut
;;  file-write getAllPatches
;;  file-close
;
;  csv:to-file PatchesOut getAllPatches
;
;  let FileList list TurtleOut PatchesOut
;  report FileList
;
;
;end

;to-report saveOutSingles
;
;  set TurtleOut word "turtle" strHexNumber
;  set PatchesOut word "patches" strHexNumber
;
;  while [file-exists? TurtleOut or file-exists? PatchesOut][
;    set strHexNumber HexNumber 20
;
;    set TurtleOut word "turtle" strHexNumber
;    set PatchesOut word "patches" strHexNumber
;  ]
;
;  file-open TurtleOut
;  ask turtles[
;    file-write csv:to-row getTurtlesPatchesSingle
;  ]
;  file-close
;
;  file-open PatchesOut
;  set CrashTestBlank []
;  ask patches[
;    if LcvPatch >= 0[
;      let myvalues getAllPatchesSingle
;
;      if not member? myvalues CrashTestBlank [
;
;        set CrashTestBlank lput myvalues CrashTestBlank
;        file-write csv:to-row  myvalues
;      ]
;    ]
;  ]
;  file-close
;
;  let FileList list TurtleOut PatchesOut
;  report FileList
;
;
;end





;to-report maximumage
;
;
;  let amaxage max[age] of turtles
;
;  if amaxage > recordage [
;    set recordage amaxage
;  ]
;  report recordage
;
;end


;to test
;  set counter 1
;  while [counter <= 10000][
;    set Gounumber (1800 * random-gamma 1 2)
;    while [Gounumber > 360][
;      set Gounumber (1800 * random-gamma 1 2)
;    ]
;    print Gounumber
;    set counter (counter + 1)
;  ]
;
;end
@#$#@#$#@
GRAPHICS-WINDOW
353
10
1382
1040
-1
-1
1.0
1
10
1
1
1
0
1
1
1
-510
510
-510
510
0
0
1
ticks
30.0

BUTTON
7
10
71
43
NIL
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
96
356
268
389
CRW_multi
CRW_multi
0
10000
200.0
1
1
NIL
HORIZONTAL

BUTTON
85
11
148
44
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1383
54
1634
316
Number of individuals
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" "ifelse DisplaySpecies = TRUE[\n\n\n  foreach speciesIDList[ ?1 ->\n\n    if count turtles with [SpeciesID = ?1] > 0 [\n\n\n      carefully[\n        set-current-plot-pen (word \"Species \" ?1)\n        set-plot-pen-color ( one-of[color] of turtles with[SpeciesID = ?1] )\n\n        plot count turtles with[SpeciesID = ?1]\n        ]\n      [\n        create-temporary-plot-pen (word \"Species \" ?1)\n        set-current-plot-pen (word \"Species \" ?1)\n        set-plot-pen-color ( one-of[color] of turtles with[SpeciesID = ?1] )\n        ;reset-ticks\n        plot count turtles with[SpeciesID = ?1]\n        ]\n      ]\n    ]\n  ]\n[\n  create-temporary-plot-pen (\"Total\")\n  set-current-plot-pen (\"Total\")\n  set-plot-pen-color Black\n  plot count turtles\n  ]"
PENS

SWITCH
3
461
120
494
SimpleDensity
SimpleDensity
0
1
-1000

MONITOR
1386
507
1499
552
number of species
species-count
17
1
11

SLIDER
114
56
260
89
BiasSlope
BiasSlope
0
5
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
115
92
260
125
HabGrowthSlope
HabGrowthSlope
-0.01
5
-0.01
0.01
1
NIL
HORIZONTAL

SWITCH
2
165
118
198
DiffSpeeds
DiffSpeeds
1
1
-1000

SLIDER
114
309
290
342
StartingEachSpecies
StartingEachSpecies
1
1000
10.0
1
1
NIL
HORIZONTAL

SLIDER
114
166
286
199
MaxSpeed
MaxSpeed
1
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
114
238
289
271
MaxReproRate
MaxReproRate
0
1
5.0E-4
0.00001
1
NIL
HORIZONTAL

SLIDER
121
494
235
527
intradensity
intradensity
2
10
3.0
1
1
/pixel
HORIZONTAL

SWITCH
0
57
106
90
DiffBias
DiffBias
1
1
-1000

SWITCH
1387
10
1526
43
DisplaySpecies
DisplaySpecies
1
1
-1000

BUTTON
1528
10
1630
44
SwitchGraph
set-current-plot \"Number of individuals\"\n\nifelse DisplaySpecies = FALSE[\nSet DisplaySpecies TRUE\nclear-plot\n]\n[\nSet DisplaySpecies FALSE\nclear-plot\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
3
572
139
605
DripFeedRate
DripFeedRate
0
1
0.0
0.01
1
/step
HORIZONTAL

SLIDER
156
572
267
605
DripFeedNumber
DripFeedNumber
1
100
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
145
583
295
601
X
11
0.0
1

PLOT
1383
318
1631
504
Number of species
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot species-count"

SLIDER
121
527
235
560
interdensity
interdensity
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
114
273
234
306
ExtraMort
ExtraMort
0
0.0005
0.0
0.000001
1
NIL
HORIZONTAL

SLIDER
114
202
287
235
MaxAge
MaxAge
0
100
3.0
1
1
years
HORIZONTAL

SWITCH
3
201
106
234
DiffAge
DiffAge
1
1
-1000

SWITCH
3
237
115
270
DiffMaxRepro
DiffMaxRepro
1
1
-1000

SWITCH
0
92
119
125
DiffHabGrowth
DiffHabGrowth
1
1
-1000

SWITCH
3
494
121
527
DiffIntraDen
DiffIntraDen
1
1
-1000

SWITCH
3
527
121
560
DiffInterDen
DiffInterDen
1
1
-1000

SWITCH
3
273
116
306
DiffExtraMort
DiffExtraMort
1
1
-1000

SWITCH
3
309
116
342
DiffStartNum
DiffStartNum
1
1
-1000

SLIDER
235
494
327
527
intraRadius
intraRadius
0
5
0.0
1
1
NIL
HORIZONTAL

SLIDER
235
527
327
560
interRadius
interRadius
0
5
0.0
1
1
NIL
HORIZONTAL

SWITCH
7
658
139
691
Imortal_infert
Imortal_infert
1
1
-1000

CHOOSER
5
387
97
432
WalkType
WalkType
"RW" "CRW" "Exp" "Logistic"
0

SLIDER
97
388
269
421
walk_exp
walk_exp
0
3
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
97
420
269
453
logiMidpoint
logiMidpoint
1
21
6.0
1
1
NIL
HORIZONTAL

SWITCH
5
355
98
388
DiffWalk
DiffWalk
1
1
-1000

SLIDER
1408
772
1580
805
MemLen
MemLen
0
10000
2000.0
1
1
NIL
HORIZONTAL

INPUTBOX
4
844
332
904
str_SpeciesPref_path
E:/FragMech_specgen/Critters/critters1.csv
1
0
String

INPUTBOX
8
724
331
784
str_lcvpath
E:/FragMech_specgen/Landcovers/LCV1.asc
1
0
String

INPUTBOX
8
784
331
844
str_patchespath
E:/FragMech_specgen/Landcovers/PATCHES1.asc
1
0
String

INPUTBOX
5
1140
328
1200
str_BiasSlope_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
6
1202
327
1262
str_HabGrowthSlope_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
8
1388
322
1448
str_MaxAge_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
14
1450
320
1510
str_MaxReproRate_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
7
1326
324
1386
str_MaxSpeed_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
12
1758
313
1818
str_InterDen_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
12
1696
315
1756
str_IntraDen_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
10
1511
318
1571
str_ExtraMort_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
10
1572
317
1632
str_StartNum_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
11
1634
316
1694
str_Walk_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

SWITCH
2
128
112
161
DiffHabMort
DiffHabMort
1
1
-1000

SLIDER
114
129
261
162
HabMortSlope
HabMortSlope
-0.01
5
-0.01
0.01
1
NIL
HORIZONTAL

INPUTBOX
6
1264
326
1324
str_HabMortSlope_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

SWITCH
6
618
118
651
UsePitfalls
UsePitfalls
1
1
-1000

SLIDER
139
619
283
652
PitfallTime
PitfallTime
0
10000
9988.0
1
1
NIL
HORIZONTAL

INPUTBOX
366
1079
666
1139
Intro_str_SpeciesPref_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2intro.csv
1
0
String

SWITCH
367
1046
551
1079
Different_introductions
Different_introductions
1
1
-1000

INPUTBOX
365
1389
661
1449
Intro_str_MaxAge_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
365
1203
662
1263
Intro_str_HabGrowthSlope_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
365
1450
660
1510
Intro_str_MaxReproRate_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
365
1141
663
1201
Intro_str_BiasSlope_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
365
1327
662
1387
Intro_str_MaxSpeed_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
363
1635
664
1695
Intro_str_Walk_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
365
1512
662
1572
Intro_str_ExtraMort_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

INPUTBOX
365
1265
663
1325
Intro_str_HabMortSlope_path
E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv
1
0
String

SWITCH
150
658
278
691
RandomEdge
RandomEdge
0
1
-1000

TEXTBOX
12
707
162
725
Necessary to run simulation:
11
0.0
1

TEXTBOX
8
1121
297
1139
Paths to tables specifying different values for each species:
11
0.0
1

SWITCH
193
695
310
728
EdgeDeath
EdgeDeath
0
1
-1000

SLIDER
260
55
352
88
BiasMid
BiasMid
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
260
90
352
123
GrowthMid
GrowthMid
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
260
129
352
162
MortMid
MortMid
0
100
6.0
1
1
NIL
HORIZONTAL

INPUTBOX
272
434
347
494
HabInterest
1.0
1
0
Number

SLIDER
732
1053
832
1086
StableTime
StableTime
0
10080
4000.0
1
1
NIL
HORIZONTAL

CHOOSER
185
9
323
54
TimeStep
TimeStep
"day" "hour" "min" "sec"
2

SLIDER
236
273
350
306
CarryCap
CarryCap
0
20000
4000.0
100
1
NIL
HORIZONTAL

@#$#@#$#@
# Multi-species landscape IBM
The model description follows the ODD (Overview, Design concepts, Details) protocol for describing individual- and agent-based models (Grimm et al., 2006, 2010). 

## Overview

### Purpose
The purpose of this IBM is to allow for the simulation of the interactions of multiple species with landscapes and record the habitat and patch at the end of the simulation, the species that pass a “pitfall” over a defined period of the simulation, or the full path of individuals within the simulation. This sort of simulation is necessary to go beyond single species, binary, few patch deterministic models and to allow for the creation and interaction of multiple species with multiple habitats within a landscape. This sort of simulation is also interesting as it allows the exploration of different walk types for the species. In this simulation, three walks can be set; random walk (RW), correlated random walk (CRW) and a negative logistic habitat dependent turning angle walk (LRW). Initially this simulation will be used in three studies, but the hope is that this simulation could be used to answer many different questions going into the future. The outputs of these simulations can be used to look at changes in abundance and diversity (alpha, beta, gamma and zeta) of different species or types of species. The outputs can also be used to look at the full movement path of individuals within the simulation. User of the simulation can either, define abstract species or, to a degree, real world species

### Entities, state variables, and scales 
The entities in this IBM are not based explicitly on any real species or sets of species, but can be parameterized to represent real species. Each entity type or species is defined primarily by its habitat preference (a ranking of all possible habitats) and optionally secondarily by the degree to which this preference influences bias in choosing habitat, reproductive probability, mortality probability and how the species walks in different habitats. Species can have different speeds, maximum ages, maximum reproductive rates, background mortality, inter and intra species density dependent mortality, walks and starting numbers. 
Each individual has a set of variables, with only some of them changing every turn.
These change in every turn:

* Heading
* X-coordinate
* Y-coordinate
* Age
These are different for offspring:
* Individual ID
Unchanging variables that are stored and inherited for each individual. 
* Species ID
* Walk information
	* Walk type – RW, CRW, LRW
	* LRW slope or a multiplier to the CRW angles
	* LRW midpoint
* Speed
* Maximum age
* Maximum reproductive rate
* Background mortality
* Intra species density
* Inter species density
* Habitat bias slope
* Habitat reproductive rate slope
* A habitat mortality slope

The following variables are lists giving a value for each habitat calculated using the LRW multiplier and habitat bias slope, reproductive rate and mortality slope respectively. These values are set for the species and do not change, they are calculated at the beginning and stored. Doing so makes the simulation run faster as it requires fewer calculations.
 
* Habitat field of view (these are only used for the LRW)
* Habitat Bias multiplier
* Habitat reproductive multiplier 
* Habitat mort multiplier

For all of the variables used by the individuals within the simulation, users of the simulation can either define that a variable is the same or differently for each species. If the values are different, they are loaded from tables. The tables have a row for each species. The rows in the different tables relate to the same species. 
The habitat bias, reproductive rate, and mortality slope multipliers are each the slope of a negative logistic relationship between habitat preference and these multiplying values. These multiplier values are less than one, reducing the probability of moving to a cell or the reproductive rate to be lower in less preferred habitat. The habitat mortality also multiples the maximum reproductive rate by one minus the multiplier value. In a simplistic way, the mortality and reproduction should therefore have the same effect on the number of individuals, although the emergent properties will likely be different. For example, changing only the reproduction allows more “tourist” individuals to move about the landscape, whereas using only habitat mortality instead will be more likely kill individuals in habitats to which they are ill suited.

The individuals can be set to either move using a RW, CRW or LRW. The LRW moves like a RW or CRW depending on the habitat. When moving using the random walk the individuals observe the cells around it and randomly up to a distance defined by the speed. The habitats are assigned a probability of being selected based on p_n  (1-1⁄((1+e^(-x(φ_n-11) ) ) ))  where p_n is the proportion of the circle that is habitat n and φ_n is the habitat preference for habitat n and x is the slope of the logistic equation. For the CRW a sector of the circle is chosen centered on the direction the individual is facing by choosing an angle from a gamma distribution (alpha = 1, lambda = 2) multiplied by a number greater than zero (low numbers increase correlation of walk, higher numbers give a more uniform distribution, but still giving a correlated walk. If the number generated is greater than 360°, the number is recalculated. The LRW uses an additional negative logistic equation multiplied by 330° and then adding 30°, to determine the range of angle the individual can choose from when walking. In preferred habitat the walk is therefore a RW and then becomes progressively more correlated. The minimum turning angle is 30° which stops individual moving in entirely straight lines in non-preferred habitat. 
The simulation can be set to introduce species at the edge of the simulation either from the species that were loaded at the start of the simulation or from tables that could include different species. The simulation compares this new list of species to the existing species and if they are different adds them to a list of possible species and then introduces only those species in the new tables. Species are introduced at a probabilistic rate of zero (not introducing) to one and from one individual upwards. If more than one individual is set, each individual has the same probability of introduction. For example, ten individual could each have a probability of 0.1 of introduction, on average in each time step one individual with enter the simulation, but none, or up to ten could be. With 100 individuals and a probability 0.01 on average one individual would be introduced, but up 100 could be introduced. This is useful to introduce more than one on average or if the number of individuals entering the simulation could be very high by chance. Each individual introduced is selected randomly from the list of species. Currently there is no way of specifying that a particular species is more likely.

The simulation has no inherent spatial or temporal scale. These can be defined using data on the species or genera of interest or by using approximations from allometric equations. So for example, if a species group of interest moved between 2 and 20 km-1 then, it would make sense for a cell to be a kilometer and the time step to be an hour as then individuals could be set to move between two and twenty cells per time step. As the simulation extent gets very large NetLogo struggles to handle the number of calculations for cells and individuals within the simulation. We use the simulation with a vertical and horizontal extent of either 1000 or 1020 cells (depending on if we have a buffer or not). We have run the simulation at 2000 cell extent, but do not think it is possible to run it with a size much larger than this. Changing the extent from the current one 1000-1020 would require a new version, as the extent is defined during setup.
A maximum age of individuals has been set to multiply up the number of years set for either all species or each species individually to the time steps based on the chosen unit of a time step. The intra includes the individual. So for intra species density this is the number of all individuals of the same species in a radius. Intra species density is used to give simply density if the simulation is set to simple density mode. In which case the number of all individuals within the radius. If not run in simple density more, inter species density does not include the observing individual and counts only individuals which are not the same species. If the radius is set to zero, only the cell of the individual making the observation is considered. 

The landscapes are loaded from two asci files, one containing the land cover which should match the possible preferences in the setup for the species (although not all habitats need to be present) and the other defining the habitat patches. 

![Example](file:table.jpg)

 
### Process overview and scheduling
The time is modeled as discrete time steps. 
In each time step:

1. Any introduced individuals are added at the edge. 
2. All individuals are cycled through in a random order.

	a.If the simulation is not in immortal-infertile mode:

		i. Each individuals is asked their age and die if over the maximum
		ii. Die if a uniform random draw is less than a background mortality rate (which can be set to zero).
		iii. Die if a uniform random draw is less than habitat based mortality (if the simulation has this setting turned on).
		iv. Reproduce if a uniform random draw is less than the maximum reproduction (multiplied by habitat-based reproduction if this is turned on).
		v. To count the number of individuals in a radius of their self and if higher than the threshold to die (inter and intra species density).

	b. To assess its surroundings and move.
	c. To increase its age by one. 

3. Finally, the time is moved forward one step.

All random numbers used above are between zero and one. Reproducing individuals spawns an individual at its location sharing all variables, but setting a new individual ID, the age to zero and the heading randomly. 
The simulation is toroidal to allow the circle or sector of the individuals to be complete and not interfere with the movement of individuals. So that the habitat on the other edge of the landscape does not influence the individuals, causing them to pass over the edge of the simulation more or less probably, a 10-cell random habitat edge buffer is included. If an individual passes over the edge of the simulation and the simulation is not in immortal-infertile mode or the edge death is not turned off the individual dies. The random land cover edge can be turned off, for example if the land cover used is simplistic, with the same habitat along all edges, then the random edge is not necessary. 
# Design concepts
## Emergence

The simulation can use several different modes to output results.

* SinglespeciesLocation and MultispeciesLocation –these report functions can be used for a single individual or multiple, to record in every time step:
* Individual ID
* Species ID
* Current location

	* Land cover
	* Patch ID
	* X 
	* Y
* count turtles - the NetLogo default, to count the overall population either every time step or at the end of the simulation
* species-count – is the number of species. Can report either every time step or at the end of the simulation.
* saveOutPitfall and saveOut – these two reporter functions output two csv files, turtle and patches. The turtle csv file contains three unlabeled columns, with correspond to species id, land cover class and patch ID. The patches csv contain two unlabeled columns, land cover class and patch ID. The pitfall function records the individuals that cross the approximate central cell of a patch for a defined period before the simulation end and outputs the files. The non-pitfall version records every individual at any location. These two functions can both be used together at the end of a simulation. If a habitat if interest is defined then (HabInterest) the pitfalls are only set up in this habitat and for both output types the species are only recorded in the habitat of interest.

Reproductive and mortality rates overall and in each habitat, the patterns of land covers and species preference and the way the individuals move will influence the number of individuals and their distribution within each simulation. 

## Adaptation
The individuals in the simulation randomly select where to move to within a circle or sector of a circle. This random choice can be biased by preference. Density based mortality is based on individual observation of the cell they are in or those in an area around them. The order the individuals are cycled through is random, therefore an individual dies if it observes there are too many individuals in its vicinity. 

## Fitness
Fitness is not usually sought. Increasing bias towards preferred habitat when habitat based reproduction and or mortality is implemented could be considered seeking out habitat that optimizes fitness, but there is still a lot of randomness. They also can only perceive up to the maximum distance they can move in a time step and they have no memory for where they have been. 

## Predictions
Individuals do not predict future conditions. 
## Sensing
Individuals are aware of the habitat they are in, how many other individuals are in the same cell or the surrounding cells (zero or more respectively). They are aware of the cells up to the maximum distance they can move within either a circle or a sector depending on the walk.

## Interaction
Individuals only interact with density dependent mortality. If they see more individuals in their cell they die. 

## Stochasticity

* If the random edge is turned on then the cells in this zone are randomly assigned habitat – this is to avoid influencing individuals with the habitat on the other side of the simulation, but still let the circle or sector of a circle include cell across the edge of the simulation. This makes them leave the simulation randomly.
* Individuals start at a random location. 
* New individuals have a random heading assigned.
* The starting age of individuals is randomly chosen up to the maximum for the species. 
* If species are introduced at the edge (drip feed rate is greater than zero), the drip feed rate is compared to a random number and individuals introduced only when less than the drip feed rate. The rate is therefore on average. This removes cyclical waves of predefined introductions.
* The species that is introduced at the edge is randomly chosen from a list of available species.
* When the walk is set to CRW an angle is selected from a random gamma distribution and is used to define the sector of a circle the individual observes and can move into.
* The maximum distance the individual observes and can move into is randomly selected up to the maximum speed for the species. 
* A random number between zero and one is used to decide which habitat to move to weighted by bias and proportion. A cell within this habitat is then randomly chosen. 
* A random fraction is compared to the extra mortality and another to the habitat mortality for each individual meaning that on average the mortality is that specified by extra mortality or habitat mortality. 
* A random fraction compared to the reproduction rate adjusted by habitat.

## Collective
Individuals are assigned and inherit a species ID, but do not act as a collective.

## Observation
If the user is using the simulation with the graphic user interface, they can see the land cover and different colour individuals, coloured by species. This allows species clumping and movement to be observed. Sometime it is useful to ask turtles to set their pens down as you can then see where individuals have been. A graph of the population and number of species can be seen on the right. The population graph can be set to show the numbers of each species. 

# Details

## Initialization
The simulation does not have a single set of initialization values. The values that are kept the same are defined by testing for the individual study by doing a parameter sweep to ensure population does not grow too high or fail. 

## Input data
 The model does not use input data to represent time-varying processes. Land cover data is loaded for each simulation.

## Submodels
Individuals having different habitat preferences came out of currently unpublished work on habitat association of carabids using the Phi coefficient of association (De Cáceres and Legendre 2009). This work gave a value between one and negative one defining positive and negative association of the habitat to the species. At this stage, we do not know to what extent this association is driven by the choices of the individuals or reproductive success and mortality of the species within each habitat. The relationship between the ranked habitat association and the association value is similar to a sideways s shape. For simplicity, it was decided therefore to use a negative logistic equation to relate the ranked association of each species to the bias towards preferred habitat, habitat growth rate, and mortality. The values calculated for each habitat are used as a multiplier to the probability of choosing a habitat or reproduction and mortality values for individuals of an individual while it is in that habitat. The multiplying values are between zero (equation 1). To calculate the habitat bias of a habitat, the proportion of the circle or sector that is each habitat is calculated and then the proportion of the area that is each habitat is multiplied by the multiplier value these are then normalized and cumulatively summed. A single random number can then be used to select the habitat using the cumulative sum value for each habitat.  
The habitat reproductive rate is calculated by multiplying the mean reproductive rate multiplier values and habitat mortality by multiplying the mean reproductive rate by one minus the multiplier.

〖Multiplier〗_n=  2/(1+e^(x(φ_n-11)) )* (1)

Where x is the slope value assigned for the habitat bias, reproduction or mortality and n is the habitat and φ_n is the habitat preference rank. The midpoint of the negative logistic equation can be set based on the number of habitats, for example we set it as 6 as we have 11 habitats. Another advantage to using a logistic equation is that on average over all habitats if they all had equal proportions in the landscape the total bias, reproduction or mortality would be the same.
For the LRW, the calculated value is multiplied by 330° and 30° is added so that values vary between 30° and 360°, in this way no individual walks in a perfectly straight line. For the LRW the midpoint can be changed. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment_oldTest" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>StoppingStable</exitCondition>
    <metric>species-count</metric>
  </experiment>
  <experiment name="experiment_example" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="DiffIntraDen">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffWalk">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_PopGrowExppath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxReproRate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_AgeTableagepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberZetas">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_InterDenTablepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interdensity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intraRadius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interRadius">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffSpeeds">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffMaxRepro">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffSpdCoe">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffInterDen">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffStartNum">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_MaxReproRatepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PopGrowExp">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExtraMort">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GenSpec">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SameSpeed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="logiMidpoint">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Imortal_infert">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_SpeedTablepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisplaySpecies">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DripFeedRate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffExtraMort">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StartingExp">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SimpleDensity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_Walktablepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_critterpath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_specialistpath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_StartNumTablepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_IntraDenTablepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intradensity">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_SpeedCoefTablepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_age">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_lcvpath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/lcvsquares1_273.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_patchespath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/patchsquares1_273.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WalkType">
      <value value="&quot;Logistic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffAge">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DripFeedNumber">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SpeciesPresenceCutOff">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SpeedCoef">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffPopGrExp">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_ExtraMortTablepath">
      <value value="&quot;/home/users/zabados/SimpleIBM/netlogo/critters.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="walk_exp">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CRW_multi">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MemLen">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PrefMoveExp">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StartingEachSpecies">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment_pitfall" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>thousand</exitCondition>
    <metric>saveOutPitfall</metric>
    <metric>saveOut</metric>
  </experiment>
  <experiment name="location" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>MultispeciesLocation</metric>
  </experiment>
  <experiment name="Variables" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200000"/>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="DiffIntraDen">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffBias">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffWalk">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_BiasSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExtraMort">
      <value value="3.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interdensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffHabGrowth">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interRadius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UsePitfalls">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Different_introductions">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffInterDen">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffStartNum">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_MaxAge_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StableTime">
      <value value="4000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="logiMidpoint">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RandomEdge">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DripFeedRate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxSpeed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intradensity">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_HabGrowthSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_patchespath">
      <value value="&quot;E:/LargeLCV_squares/fourpatch.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="BiasSlope">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_StartNum_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WalkType">
      <value value="&quot;Logistic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffAge">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_InterDen_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DripFeedNumber">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_Walk_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HabGrowthSlope">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_SpeciesPref_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2intro.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_MaxReproRate_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_HabMortSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="walk_exp">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CRW_multi">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_Walk_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MemLen">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_MaxSpeed_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxAge">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_HabGrowthSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_BiasSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_ExtraMort_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffHabMort">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxReproRate">
      <value value="5.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffSpeeds">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intraRadius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffMaxRepro">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Imortal_infert">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HabMortSlope">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisplaySpecies">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffExtraMort">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SimpleDensity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_SpeciesPref_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters_binary2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PitfallTime">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_lcvpath">
      <value value="&quot;E:/LargeLCV_squares/fourlcv.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_MaxSpeed_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_MaxAge_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_MaxReproRate_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StartingEachSpecies">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_HabMortSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_ExtraMort_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_IntraDen_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200000"/>
    <metric>count turtles</metric>
    <metric>starttime</metric>
    <metric>endtime</metric>
    <enumeratedValueSet variable="DiffIntraDen">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffBias">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffWalk">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_BiasSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffHabGrowth">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interdensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UsePitfalls">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Different_introductions">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="interRadius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExtraMort">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffInterDen">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffStartNum">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_MaxAge_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StableTime">
      <value value="4000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="logiMidpoint">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RandomEdge">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DripFeedRate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxSpeed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GrowthMid">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intradensity">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_HabGrowthSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_patchespath">
      <value value="&quot;/home/users/zabados/MethodsTest/Patch_test.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="BiasSlope">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_StartNum_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WalkType">
      <value value="&quot;RW&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffAge">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_InterDen_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DripFeedNumber">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_Walk_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HabGrowthSlope">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_SpeciesPref_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2intro.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_MaxReproRate_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_HabMortSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="walk_exp">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CRW_multi">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_Walk_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MemLen">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="EdgeDeath">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_MaxSpeed_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HabInterest">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxAge">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_HabGrowthSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_BiasSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_ExtraMort_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CarryCap">
      <value value="4000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffHabMort">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="BiasMid">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxReproRate">
      <value value="5.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffSpeeds">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffMaxRepro">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intraRadius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TimeStep">
      <value value="&quot;min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Imortal_infert">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HabMortSlope">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisplaySpecies">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DiffExtraMort">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SimpleDensity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_SpeciesPref_path">
      <value value="&quot;/home/users/zabados/MethodsTest/Single_Neutral_species.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PitfallTime">
      <value value="9995"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_MaxSpeed_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_lcvpath">
      <value value="&quot;/home/users/zabados/MethodsTest/LCV_test.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_MaxAge_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MortMid">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_MaxReproRate_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StartingEachSpecies">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_HabMortSlope_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Intro_str_ExtraMort_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str_IntraDen_path">
      <value value="&quot;E:/OneDrive - University of Leeds/Analysis/SimpleIBM/netlogo/critters2.csv&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
